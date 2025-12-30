RESOURCE_GROUP="Passion-Tree"
SERVER_NAME="passion-tree-db-server"


# บังคับให้กรอก Rule name
read -p "Enter Firewall Rule Prefix: " RULE_PREFIX
if [ -z "$RULE_PREFIX" ]; then
    echo "Rule prefix is required. Exiting."
    exit 1
fi
# เติม -IP ต่อท้าย
RULE_NAME="${RULE_PREFIX}-IP"

CURRENT_IP=$(curl -s https://api.ipify.org)

if [ -z "$CURRENT_IP" ]; then
    echo "Unable to retrieve IP address. Please check your internet connection."
    exit 1
fi

echo "Your current IP address is: $CURRENT_IP"

# --- 4. Update Firewall on Azure ---
echo "Updating Firewall rule '$RULE_NAME' on Azure..."

# Use Azure CLI to create or update the rule
az sql server firewall-rule create \
    --resource-group "$RESOURCE_GROUP" \
    --server "$SERVER_NAME" \
    --name "$RULE_NAME" \
    --start-ip-address "$CURRENT_IP" \
    --end-ip-address "$CURRENT_IP"

if [ $? -eq 0 ]; then
    echo ""
    echo "Success! Your IP has been whitelisted successfully."
    echo "You can now connect to the database via code or GUI."
else
    echo "Update failed! Have you run 'az login'?"
    exit 1
fi