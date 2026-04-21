terraform {
  # Définition des providers utilisés par le déploiement
  # avec la version souhaitée
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.41"
    }
  }

  # Définition de la version de Terraform requise
  required_version = ">= 1.14.0"
}
