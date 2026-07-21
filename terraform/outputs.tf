output "public_ip_address" {
  description = "Public IP of the VM."
  value       = azurerm_public_ip.main.ip_address
}

output "ssh_command" {
  description = "Convenience SSH command (write the key out first - see ssh_private_key)."
  value       = "ssh -i .priv/harmonic-mix-engine-vm_key.pem ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "ssh_private_key" {
  description = "Generated private key. Retrieve on any machine with: terraform output -raw ssh_private_key > .priv/harmonic-mix-engine-vm_key.pem && chmod 400 .priv/harmonic-mix-engine-vm_key.pem"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}

output "app_url" {
  description = "Application endpoint (available a few minutes after apply, once cloud-init finishes)."
  value       = "http://${azurerm_public_ip.main.ip_address}/songs?key=C"
}
