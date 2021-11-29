provider "azurerm" {
  features {}
  subscription_id = "fcd4d0d9-59c4-451c-9665-a0001f80e9e2"
  skip_provider_registration = "true"
}
# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name = "nithin19terraSubnet"
    resource_group_name = "AZRG-USE2-CON-NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    virtual_network_name = "hu19-tf-vnet"
    address_prefixes = ["10.1.212.0/23"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name = "nithinterraPublicIP"
    location = "eastus"
    resource_group_name = "AZRG-USE2-CON-NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    allocation_method = "Dynamic"
    tags = {
        environment = "HU-19"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name = "nithinhu19NSG"
    location = "eastus"
    resource_group_name = "AZRG-USE2-CON-NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    security_rule {
        name = "SSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
    tags = {
        environment = "Terraform Demo"
    }
}
# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name = "nithinhu19NIC"
    location = "eastus"
    resource_group_name = "AZRG-USE2-CON-NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    ip_configuration {
        name = "nithinNicConfiguration"
        subnet_id = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.myterraformpublicip.id
    }
    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name = "hu19nithinstorageaccount"
    resource_group_name = "AZRG-USE2-CON-NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    location = "eastus"
    account_tier = "Standard"
    account_replication_type = "LRS"
    tags = {
        environment = "Terraform Demo"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "nithinhu19_ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}



output "tls_private_key" {
    value = tls_private_key.nithinhu19_ssh.private_key_pem
    sensitive = true
}



# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name = "nithinhu19terraVM"
    location = "eastus"
    resource_group_name = "AZRG-USE2-CON-NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size = "Standard_DS1_v2"
    os_disk {
            name              = "nithinOsDisk"
            caching           = "ReadWrite"
            storage_account_type = "Standard_LRS"
        }
        source_image_reference {
            publisher = "Canonical"
            offer     = "UbuntuServer"
            sku       = "18.04-LTS"
            version   = "latest"
        }
        computer_name  = "nithinhu19vm"
        admin_username = "azureuser"
        disable_password_authentication = true

        admin_ssh_key {
            username       = "azureuser"
            public_key     = tls_private_key.nithinhu19_ssh.public_key_openssh
        }
        boot_diagnostics {
            storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
            }

        tags = {
            environment = "Terraform Demo"
        }
}
data "template_file" "linux-vm-cloud-init" {
    template = file("userdata.sh")
}
