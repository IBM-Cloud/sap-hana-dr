variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "KIT_SAPHANA_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPHANA_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

variable "IP_PRIMARY" {
  type        = string
  description = "IP"
}

variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "Input your id_rsa private key file path in OpenSSH format with 0600 permissions."
    validation {
    	condition = fileexists("${var.ID_RSA_FILE_PATH}") == true
    	error_message = "The id_rsa file does not exist."
	}
}