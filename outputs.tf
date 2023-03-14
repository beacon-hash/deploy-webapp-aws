output "webapp-public-ip" {
    value = aws_instance.webapp-server.public_ip
}