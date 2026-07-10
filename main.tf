terraform {
  required_version = "~>1.15.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=3.112.0"
    }
  }
  cloud {
    
    organization = "dkmh2122220002"

    workspaces {
      name = "DeployVMonAzurebyTF"
    }
  }

}
provider "azurerm" {
  features {
    
  }
  #resource_provider_registrations = false
  skip_provider_registration = true
}
resource "azurerm_resource_group" "rg" {
  name = "1-0a0e4573-playground-sandbox"
  location = "East US"
}

resource "azurerm_virtual_network" "VNET01" {
  name = "VNET01"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "VNET01_SUBNET1" {
  name = "VNET01_SUBNET1"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNET01.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "VNET01_SUBNET2" {
  name = "VNET01_SUBNET2"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNET01.name
  address_prefixes = ["10.0.2.0/24"]
}


resource "azurerm_network_interface" "name" {
  name = "VM01_NIC"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  ip_configuration {
    name = "VM01_NIC_IP01"
    subnet_id = azurerm_subnet.VNET01_SUBNET1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.1.100"
  }
}

resource "azurerm_linux_virtual_machine" "VM01" {
  name = "VM01"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  size = "Standard_D2_v3"
  admin_username = "hien"
  admin_password = "xinchao1A"
  network_interface_ids = [azurerm_network_interface.name.id]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
  publisher = "canonical"
  offer     = "ubuntu-24_04-lts"
  sku       = "ubuntu-pro-gen1"
  version   = "latest"
  }
  tags = {
    ManagedBy = "Hien"
  }
}

