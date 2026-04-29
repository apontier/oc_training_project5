global
	log /dev/log	local0
	log /dev/log	local1 notice
	chroot /var/lib/haproxy
	stats socket /run/haproxy/admin.sock mode 660 level admin
	stats timeout 30s
	user haproxy
	group haproxy
	daemon

	# Default SSL material locations
	ca-base /etc/ssl/certs
	crt-base /etc/ssl/private

	# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
	log	global
	mode	http
	option	httplog
	option	dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
	errorfile 400 /etc/haproxy/errors/400.http
	errorfile 403 /etc/haproxy/errors/403.http
	errorfile 408 /etc/haproxy/errors/408.http
	errorfile 500 /etc/haproxy/errors/500.http
	errorfile 502 /etc/haproxy/errors/502.http
	errorfile 503 /etc/haproxy/errors/503.http
	errorfile 504 /etc/haproxy/errors/504.http

frontend web_frontend
    bind *:80
    default_backend web_backend

	# Table de suivi des requêtes par IP (jusqu'à 100k IPs, une IP expire après 30s sans activité, et on stocke le taux de requêtes HTTP sur une fenêtre de 10s)
    stick-table type ip size 100k expire 30s store http_req_rate(10s)

    # Comptabilise les requêtes par IP
    http-request track-sc0 src

    # Bloque si plus de 50 requêtes en 10 secondes
    http-request deny deny_status 429 if { sc_http_req_rate(0) gt 50 }

	# Headers de sécurité
	## Empêche le clickjacking en interdisant l'affichage de la page dans un cadre (frame) ou une iframe
	http-response set-header X-Frame-Options "SAMEORIGIN"
	## Empêche les navigateurs de tenter de deviner le type de contenu d'une réponse, ce qui peut aider à prévenir les attaques de type MIME sniffing. 
	http-response set-header X-Content-Type-Options "nosniff"
	## Permet de contrôler les informations de référent envoyées avec les requêtes
	http-response set-header Referrer-Policy "strict-origin-when-cross-origin"
	## CSP pour limiter les sources de contenu et réduire les risques d'attaques de type Cross-Site Scripting (XSS) et autres attaques de contenu malveillant.
	http-response set-header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; frame-ancestors 'self'"
	## Limite les permissions pour les fonctionnalités sensibles comme la géolocalisation, le microphone et la caméra.
	http-response set-header Permissions-Policy "geolocation=(), microphone=(), camera=()"

backend web_backend
    balance roundrobin
    option httpchk
    http-check send meth GET uri /
    http-check expect status 200
%{ for i in backend_servers }
    server ${i.tags.Name} ${i.public_dns}:80 check inter 5s fall 3 rise 2
%{ endfor }
