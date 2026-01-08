#!/bin/bash

# --- 1. Configuration ---
RESOURCE_GROUP="Passion-Tree"
SERVER_NAME="passion-tree-db-server"
STORAGE_ACCOUNT_NAME="treeimage"

# --- 2. Select Option ---
echo "Select update option:"
echo "1) Update Azure SQL Firewall only"
echo "2) Update Azure Blob Storage Network Rule only"
echo "3) Update Both"
read -p "Enter choice (1-3): " CHOICE

# --- 3. Get Prefix & IP ---
read -p "Enter Firewall Rule Prefix: " RULE_PREFIX
if [ -z "$RULE_PREFIX" ]; then
    echo "Rule prefix is required. Exiting."
    exit 1
fi
RULE_NAME="${RULE_PREFIX}-IP"

CURRENT_IP=$(curl -s https://api.ipify.org)
if [ -z "$CURRENT_IP" ]; then
    echo "Unable to retrieve IP address. Please check your internet connection."
    exit 1
fi

echo "Your current IP address is: $CURRENT_IP"

# --- 4. Execution Logic ---

# Function for SQL Update
update_sql() {
    echo "Updating Azure SQL Firewall rule '$RULE_NAME'..."
    az sql server firewall-rule create \
        --resource-group "$RESOURCE_GROUP" \
        --server "$SERVER_NAME" \
        --name "$RULE_NAME" \
        --start-ip-address "$CURRENT_IP" \
        --end-ip-address "$CURRENT_IP"
}

# Function for Storage Update
update_storage() {
    echo "Updating Storage Account network rule for '$STORAGE_ACCOUNT_NAME'..."
    az storage account network-rule add \
        --resource-group "$RESOURCE_GROUP" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --ip-address "$CURRENT_IP"
}

case $CHOICE in
    1)
        update_sql
        ;;
    2)
        update_storage
        ;;
    3)
        update_sql
        update_storage
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# --- 5. Final Check ---
if [ $? -eq 0 ]; then
    echo "-------------------------------------------"
    echo "Success! Your IP has been whitelisted."
    echo "Project: Passion Tree"
else
    echo "Update failed! Have you run 'az login'?"
    exit 1
fi