output "ssh_login_command" {
  description = "SSH login command for convenience"
  value       = "ssh -i <your-key>.pem ec2-user@${aws_instance.app.public_ip}"
}

output "frontend_url" {
  description = "Frontend URL (React/Express on port 3000)"
  value       = "http://${aws_instance.app.public_ip}:3000"
}

output "backend_url" {
  description = "Backend API URL (Flask/Express on port 5000)"
  value       = "http://${aws_instance.app.public_ip}:5000"
}
