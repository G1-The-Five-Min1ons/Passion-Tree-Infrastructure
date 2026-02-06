# สร้างโครงข่ายเสมือนหลัก
resource "azurerm_virtual_network" "main_vnet" {
  name                = "passiontree-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.project_rg.location
  resource_group_name = azurerm_resource_group.project_rg.name
}

# Subnet สำหรับ Azure Container Apps (ต้องว่างและไม่มีบริการอื่น)
resource "azurerm_subnet" "aca_subnet" {
  name                 = "aca-infrastructure-subnet"
  resource_group_name  = azurerm_resource_group.project_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.1.0/23"] # จองพื้นที่สำหรับ Container
}

# Subnet สำหรับ Database (Private Zone)
resource "azurerm_subnet" "db_subnet" {
  name                 = "private-db-subnet"
  resource_group_name  = azurerm_resource_group.project_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}