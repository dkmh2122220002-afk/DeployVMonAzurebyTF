terraform {
  required_version = "~>1.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
  name     = "1-0a0e4573-playground-sandbox"
  location = "East US"
}

resource "azurerm_virtual_network" "VNET01" {
  name                = "VNET01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "VNET01_SUBNET1" {
  name                 = "VNET01_SUBNET1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNET01.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "VNET01_SUBNET2" {
  name                 = "VNET01_SUBNET2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VNET01.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_interface" "name" {
  name                = "VM01_NIC"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "VM01_NIC_IP01"
    subnet_id                     = azurerm_subnet.VNET01_SUBNET1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.100"
  }
}

resource "azurerm_linux_virtual_machine" "VM01" {
  name                            = "VM01"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "hien"
  admin_password                  = "xinchao1A"
  disable_password_authentication = "false"
  network_interface_ids           = [azurerm_network_interface.name.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.SA.primary_blob_endpoint
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
  custom_data = base64encode(file("./init_script"))
}

resource "azurerm_network_security_group" "NSG_Allow_Web" {
  name                = "NSG_Allow_Web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    Type      = "NSG"
    ManagedBy = "Terraform"
  }

}

resource "azurerm_network_security_rule" "Allow_FTP" {
  name                        = "Allow_FTP"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.NSG_Allow_Web.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "21"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_network_interface.name.private_ip_address
}

resource "azurerm_network_interface_security_group_association" "VM01_NIC_NSG_Allow_Web" {
  network_interface_id      = azurerm_network_interface.name.id
  network_security_group_id = azurerm_network_security_group.NSG_Allow_Web.id
}

resource "azurerm_storage_account" "SA" {
  name                     = "sadkmh2122220002"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_interface" "VM02_NIC" {
  name                = "VM02_NIC"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "VM02_NIC_IP01"
    subnet_id                     = azurerm_subnet.VNET01_SUBNET2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.100"
  }
}

resource "azurerm_linux_virtual_machine" "VM02" {
  name                            = "VM02"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_D2s_v3"
  admin_username                  = "hien"
  admin_password                  = "xinchao1A"
  disable_password_authentication = "false"
  network_interface_ids           = [azurerm_network_interface.VM02_NIC.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.SA.primary_blob_endpoint
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
  custom_data = base64encode(file("./init_script"))
}

resource "azurerm_managed_disk" "VM02_Data" {
  name                 = "VM02_Data_Disk"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 25
  create_option        = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "VM02_attach" {
  managed_disk_id    = azurerm_managed_disk.VM02_Data.id
  virtual_machine_id = azurerm_linux_virtual_machine.VM02.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_network_interface_security_group_association" "VM02_NIC_NSG_Allow_Web" {
  network_interface_id      = azurerm_network_interface.VM02_NIC.id
  network_security_group_id = azurerm_network_security_group.NSG_Allow_Web.id
}