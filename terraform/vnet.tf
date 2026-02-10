# 1. สร้าง Virtual Network หลัก
resource "azurerm_virtual_network" "main_vnet" {
  name                = "passiontree-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.aca_location
  resource_group_name = data.azurerm_resource_group.passion_tree.name
}

# 2. Subnet สำหรับ Azure Container Apps (ต้องทำ Delegation)
resource "azurerm_subnet" "aca_subnet" {
  name                 = "aca-infrastructure-subnet"
  resource_group_name  = data.azurerm_resource_group.passion_tree.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.0.0/23"] # ขนาด /23 ตามมาตรฐาน Azure สำหรับ ACA

  # สำคัญมาก: ต้องมอบอำนาจให้ Microsoft.App/environments
  delegation {
    name = "container-app-delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# 3. Subnet สำหรับ Database (Private Zone)
resource "azurerm_subnet" "db_subnet" {
  name                 = "private-db-subnet"
  resource_group_name  = data.azurerm_resource_group.passion_tree.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 4. Subnet สำหรับ Application Gateway (ถ้าจะทำ Load Balancer ชั้นนอก)
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = data.azurerm_resource_group.passion_tree.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

# 5. Network Security Group (NSG) เพื่อควบคุมความปลอดภัย
resource "azurerm_network_security_group" "aca_nsg" {
  name                = "aca-nsg"
  location            = var.aca_location
  resource_group_name = data.azurerm_resource_group.passion_tree.name

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# เชื่อม NSG เข้ากับ ACA Subnet
resource "azurerm_subnet_network_security_group_association" "aca_nsg_assoc" {
  subnet_id                 = azurerm_subnet.aca_subnet.id
  network_security_group_id = azurerm_network_security_group.aca_nsg.id
}