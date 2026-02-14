resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = "ami-0b6c6ebed2801a5cb"
  instance_type = "t3.micro"
  key_name      = "web1-key" # Substitua pelo nome da sua chave SSH

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = file("${path.module}/user_data.sh")


  # Configuração do disco raiz de 20GB
  root_block_device {
    volume_size           = 20    # Tamanho em GB
    volume_type           = "gp3" # Tipo de volume (gp3 é recomendado)
    delete_on_termination = true  # Deleta o disco ao deletar a instância
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-web-${count.index + 1}"
    }
  )
}

