@description('Conditional. The name of the parent Private DNS zone. Required if the template is used in a standalone deployment.')
param privateDnsZoneName string

@description('Required. The name of the A record.')
param name string

@description('Optional. The list of A records in the record set.')
param aRecords array = []

@description('Optional. The metadata attached to the record set.')
param metadata object = {}

@description('Optional. The TTL (time-to-live) of the records in the record set.')
param ttl int = 3600

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []



resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource A 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: name
  parent: privateDnsZone
  properties: {
    aRecords: aRecords
    metadata: metadata
    ttl: ttl
  }
}

module A_rbac '.bicep/nested_roleAssignments.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name)}-PDNSA-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: A.id
  }
}]

@description('The name of the deployed A record.')
output name string = A.name

@description('The resource ID of the deployed A record.')
output resourceId string = A.id

@description('The resource group of the deployed A record.')
output resourceGroupName string = resourceGroup().name