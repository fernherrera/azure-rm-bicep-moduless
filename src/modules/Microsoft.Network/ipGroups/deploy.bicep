@description('Required. The name of the ipGroups.')
@minLength(1)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. IpAddresses/IpAddressPrefixes in the IpGroups resource.')
param ipAddresses array = []

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Resource tags.')
param tags object = {}



resource ipGroup 'Microsoft.Network/ipGroups@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    ipAddresses: ipAddresses
  }
}

resource ipGroup_lock 'Microsoft.Authorization/locks@2017-04-01' = if (!empty(lock)) {
  name: '${ipGroup.name}-${lock}-lock'
  properties: {
    level: any(lock)
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: ipGroup
}

module ipGroup_rbac '.bicep/nested_roleAssignments.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-IPGroup-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: ipGroup.id
  }
}]

@description('The resource ID of the IP group.')
output resourceId string = ipGroup.id

@description('The resource group of the IP group was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the IP group.')
output name string = ipGroup.name

@description('The location the resource was deployed into.')
output location string = ipGroup.location
