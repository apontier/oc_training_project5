variable "authorized_public_ips" {
  description = "Public IP address of the machine from which you will connect to the AWS instance. This variable is used to restrict access to the instance to only your machine."
  type        = list(string)
  sensitive = true
  default     = []
}