
$RESOURCE_GROUP = "Passion-Tree"
$SERVER_NAME = "passion-tree-db-server"

$RULE_NAME = "Student-IP"

$CURRENT_IP = (Invoke-RestMethod -Uri "https://api.ipify.org").Content

if (-not $CURRENT_IP) {
    Write-Host "Unable to retrieve IP address. Please check your internet connection."
    exit 1
}

Write-Host "Your current IP address is: $CURRENT_IP"

# --- 4. Update Firewall on Azure ---
Write-Host "Updating Firewall rule '$RULE_NAME' on Azure..."

# Use Azure CLI to create or update the rule
az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SERVER_NAME `
    --name $RULE_NAME `
    --start-ip-address $CURRENT_IP `
    --end-ip-address $CURRENT_IP

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Success! Your IP has been whitelisted successfully."
    Write-Host "You can now connect to the database via code or GUI."
} else {
    Write-Host "Update failed! Have you run 'az login'?"
    exit 1
}
