
resource "aws_instance" "resizable-ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  tags = {
    Name = "ResizableInstance"
  }
}

output "instance_id" {
  value = aws_instance.resizable-ec2.id
}
