#!/bin/bash

# environment="dev"
# location="eastus"
# action="create"
deploymentName="wordpress-site"

if [[ -z $root_path ]]; then
    root_path=".."
fi


echo "Setting subsciption"
az account set --subscription $subscriptionId

echo "Creating resource group [${resourceGroup}]"
az group create \
    --location $location \
    --name $resourceGroup

echo "Deploying [${deploymentName}]..."
az deployment group $action \
    --resource-group $resourceGroup \
    --name $deploymentName \
    --template-file $root_path/templates/wordpress-app.bicep \
    --parameters @$root_path/parameters/$environment/wordpress-app.json \
    --parameters location=$location