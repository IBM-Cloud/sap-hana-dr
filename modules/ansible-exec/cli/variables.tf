variable "PLAYBOOK" {
    type = string
    description = "Path to the Ansible Playbook"
}

variable "HANA_MAIN_PASSWORD" {
    type = string
    description = "HANA_MAIN_PASSWORD"
}

variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "id_rsa private key file path in OpenSSH format."
}

variable "IP" {
    type = string
    description = "IP used by ansible"
}
