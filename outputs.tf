output "instance1_dns" {
  value = aws_eip.ip-manning-beta-env-1.public_dns
}

output "instance1_ips" {
  value = aws_eip.ip-manning-beta-env-1.public_ip
}