# Récupération de l'identifiant de l'AMI (modèle d'image disque) à utiliser pour le déploiement
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical - éditeur officiel d'Ubuntu sur AWS
}

# Définit d'une ressource de type
# "aws_instance" permettant de créer un serveur
# sur l'infrastructure Amazon EC2
resource "aws_instance" "olympic_games_app_server" {
  # Définition de l'AMI (identifiant du modèle d'image disque)
  # et du type d'instance (i.e. caractéristiques de performance)
  # de la machine virtuelle à créer
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # Définition des étiquettes à associer à la machine
  # virtuelle, ici "Name" pour définir un nom
  tags = {
    Name = "Olympic-Games-App-Server"
  }

  # Optionnel - Définition des éléments permettant une connexion SSH
  # sur la machine déployée
  vpc_security_group_ids = ["${aws_security_group.olympic_games_app_security_group.id}"]
  key_name               = aws_key_pair.generated_key.key_name
}

// La suite de la configuration permet de configurer un accès SSH
// sur la machine AWS. 
// Cette section n'est pas demandée pour ce premier exercice car
// un peu technique mais sera nécessaire pour la seconde partie.

resource "aws_security_group" "olympic_games_app_security_group" {
  name = "allow-ssh"
  ingress {
    cidr_blocks = [
      "${var.my_pc_public_ip}/32"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
