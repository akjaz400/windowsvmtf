
resource "azurerm_resource_group" "rgvmw" {
  name     = "rgvmw-25may"
  location = var.location
}

resource "azurerm_virtual_network" "vn" {
  name                = "vn-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgvmw.location
  resource_group_name = azurerm_resource_group.rgvmw.name
}

resource "azurerm_subnet" "sn" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rgvmw.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "ni" {
  name                = "ni-nic"
  location            = azurerm_resource_group.rgvmw.location
  resource_group_name = azurerm_resource_group.rgvmw.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id

  }


}

resource "azurerm_public_ip" "pip" {
  name                = "vm_public_ip"
  resource_group_name = azurerm_resource_group.rgvmw.name
  location            = azurerm_resource_group.rgvmw.location
  allocation_method   = "Dynamic"
}


resource "azurerm_windows_virtual_machine" "wvm" {
  name                = "wvm-machine"
  resource_group_name = azurerm_resource_group.rgvmw.name
  location            = azurerm_resource_group.rgvmw.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.ni.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}