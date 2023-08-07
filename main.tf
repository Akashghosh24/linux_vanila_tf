resource   "azurerm_resource_group"   "rg"   {
  name   =   "linuxvm-rg"
  location   =   "eastus2"
}


resource "azurerm_network_security_group" "linuxvm-nsg" {
    name                = "linuxvmnsg"
    location            = "eastus2"
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Test"
    }
}

resource   "azurerm_virtual_network"   "linuxvmvnet"   {
  name   =   "linuxvmvnet"
  address_space   =   [ "10.0.0.0/16" ]
  location   =   "eastus2"
  resource_group_name   =   azurerm_resource_group.rg.name
}

resource   "azurerm_subnet"   "frontendsubnet"   {
  name   =   "frontendSubnet"
  resource_group_name   =    azurerm_resource_group.rg.name
  virtual_network_name   =   azurerm_virtual_network.linuxvmvnet.name
  address_prefixes   =   ["10.0.1.0/24"]
}

resource   "azurerm_public_ip"   "azurevm1publicip"   {
  name   =   "pip1"
  location   =   "eastus2"
  resource_group_name   =   azurerm_resource_group.rg.name
  allocation_method   =   "Dynamic"
  sku   =   "Basic"
}

resource   "azurerm_network_interface"   "azurevm1nic"   {
  name   =   "azurevm1-nic"
  location   =   "eastus2"
  resource_group_name   =   azurerm_resource_group.rg.name

  ip_configuration   {
    name   =   "ipconfig1"
    subnet_id   =   azurerm_subnet.frontendsubnet.id
    private_ip_address_allocation   =   "Dynamic"
    public_ip_address_id   =   azurerm_public_ip.azurevm1publicip.id
  }
}

resource   "azurerm_linux_virtual_machine"   "myterraformvm"   {
  name                    =   "linuxVM-test"
  location                =   "eastus2"
  resource_group_name     =   azurerm_resource_group.rg.name
  network_interface_ids   =   [ azurerm_network_interface.azurevm1nic.id ]
  size                    =   "Standard_D2s_v3"
 disable_password_authentication = false
  computer_name           =   "linuxVM-test"
  admin_username          =   "adminuser"
  admin_password          =   "Admin@123456"

  source_image_reference   {
       publisher = "canonical"
       offer     = "0001-com-ubuntu-server-focal"
       sku       = "20_04-lts-gen2"
       version   = "latest"
  }

  os_disk   {
    caching             =   "ReadWrite"
    storage_account_type   = "Standard_LRS"
  }
}