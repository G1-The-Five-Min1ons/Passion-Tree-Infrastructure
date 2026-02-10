# ─── Import existing resources into Terraform state ───
# Resource เหล่านี้ถูกสร้างจาก apply ก่อนหน้า (ตอนยังไม่มี remote backend)
# Terraform ไม่รู้จัก → ต้อง import เข้า state ก่อน
# หลัง apply สำเร็จครั้งแรก สามารถลบไฟล์นี้ออกได้

import {
  to = azurerm_user_assigned_identity.aca_identity
  id = "/subscriptions/37a4a9ac-d61a-48ce-a165-92e989e945f3/resourceGroups/Passion-Tree/providers/Microsoft.ManagedIdentity/userAssignedIdentities/passion-tree-aca-identity"
}

import {
  to = azurerm_log_analytics_workspace.logs
  id = "/subscriptions/37a4a9ac-d61a-48ce-a165-92e989e945f3/resourceGroups/Passion-Tree/providers/Microsoft.OperationalInsights/workspaces/passiontree-log-workspace"
}

import {
  to = azurerm_virtual_network.main_vnet
  id = "/subscriptions/37a4a9ac-d61a-48ce-a165-92e989e945f3/resourceGroups/Passion-Tree/providers/Microsoft.Network/virtualNetworks/passiontree-vnet"
}

import {
  to = azurerm_network_security_group.aca_nsg
  id = "/subscriptions/37a4a9ac-d61a-48ce-a165-92e989e945f3/resourceGroups/Passion-Tree/providers/Microsoft.Network/networkSecurityGroups/aca-nsg"
}
