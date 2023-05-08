/*
  author: Fernando Herrera <fherrera@intermexusa.com>
  type: Module
  description: This module creates a notification hub.
*/

// parameters
@description('Location where the resource will be created.')
param location string = resourceGroup().location

@description('Resource tags.')
param tags object = {}

param name string
param namespaceName string
param sku object = {
  name: 'Free'
}


// resources
resource ntfns 'Microsoft.NotificationHubs/namespaces@2017-04-01' = {
  name: namespaceName
  location: location
  tags: tags
  sku: sku
  properties: {
    name: namespaceName
    namespaceType: 'NotificationHub'
    region: location
    status: 'Active'
  }
}

resource ntf 'Microsoft.NotificationHubs/namespaces/notificationHubs@2017-04-01' = {
  dependsOn: [
    ntfns
  ]
  name: '${namespaceName}/${name}'
  location: location
  tags: tags
  sku: sku
  properties: {
    name: name
  }
}


// output
output ntfnsId string = ntfns.id
output nftId string = ntf.id
