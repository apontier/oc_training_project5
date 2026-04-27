Role Name
=========

Install and configure Nginx on ubuntu server

Role Variables
--------------

The vars used by this role are :
- nginx_app_name : the app name in nginx configuration (no default)
- nginx_listen_port : the listening port for the app (default : 80)


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - role: nginx

License
-------

MIT