output "public_ip" {
  value = resource.azurerm_public_ip.infra_dev_weu_app_pubip.ip_address

}
