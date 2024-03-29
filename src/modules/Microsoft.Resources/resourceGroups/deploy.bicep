/*
  author: Fernando Herrera <fherrera@intermexusa.com>
  type: Module
  description: This module is a subscription level template that will create a Resource Group.
*/

// set the target scope for this file
targetScope = 'subscription'


// parameters
@description('Required. The name of the Resource Group.')
param name string

@description('Optional. Location of the Resource Group. It uses the deployment\'s location when not provided.')
param location string = deployment().location

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Tags of the storage account resource.')
param tags object = {}


// resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: name
  tags: tags
  properties: {}
}

module resourceGroup_lock '../../Microsoft.Authorization/locks/resourceGroup/deploy.bicep' = if (!empty(lock)) {
  name: '${uniqueString(deployment().name, location)}-${lock}-Lock'
  params: {
    level: any(lock)
    name: '${resourceGroup.name}-${lock}-lock'
  }
  scope: resourceGroup
}

module resourceGroup_rbac '.bicep/nested_roleAssignments.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-RG-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: resourceGroup.id
  }
  scope: resourceGroup
}]


// outputs
@description('The name of the resource group.')
output name string = resourceGroup.name

@description('The resource ID of the resource group.')
output resourceId string = resourceGroup.id

@description('The location the resource was deployed into.')
output location string = resourceGroup.location
