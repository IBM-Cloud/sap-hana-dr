resource "null_resource" "id_rsa_validation" {
  provisioner "local-exec" {
    command = "ssh-keygen -l -f ${var.ID_RSA_FILE_PATH}"
    on_failure = fail
  }
}

resource "null_resource" "ansible-exec" {

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "root"
      host = var.IP_PRIMARY
      private_key = file(var.ID_RSA_FILE_PATH)
      timeout = "2m"
    }
    inline = ["echo 'Connection established to the PRIMARY HANA DB!'"]
  }

}
