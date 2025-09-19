resource "azurerm_resource_group" "infra_dev_rg" {
  name     = "infrastructure-rg"
  location = "West Europe"
}


resource "azurerm_virtual_network" "infra_dev_weu_vnet" {
  name                = "infra-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.infra_dev_rg.location
  resource_group_name = azurerm_resource_group.infra_dev_rg.name
}

resource "azurerm_subnet" "infra_dev_weu_app_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.infra_dev_rg.name
  virtual_network_name = azurerm_virtual_network.infra_dev_weu_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "infra_dev_weu_app_nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.infra_dev_rg.location
  resource_group_name = azurerm_resource_group.infra_dev_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.infra_dev_weu_app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "infra_dev_weu_app_vm" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.infra_dev_rg.name
  location            = azurerm_resource_group.infra_dev_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.infra_dev_weu_app_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/home/chuks/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }
}
