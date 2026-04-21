// On créait une nouvelle paire de clés SSH
// afin que celle ci soit utilisable pour se connecter
// à notre serveur
resource "tls_private_key" "my_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.my_ssh_key.public_key_openssh
}

// On stocke notre clé SSH privée localement dans le répertoire
// ~/.ssh.
resource "local_sensitive_file" "pem_file" {
  filename             = pathexpand("~/.ssh/aws_${aws_key_pair.generated_key.key_name}.pem")
  file_permission      = "600"
  directory_permission = "700"

  content = tls_private_key.my_ssh_key.private_key_pem
}
