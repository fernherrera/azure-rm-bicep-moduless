/*
  author: Fernando Herrera <fherrera@intermexusa.com>
  type: Module
  description: This module creates a Redis Cache.
*/

// parameters
@description('Required. The name of the Redis cache resource.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
param tags object = {}

@allowed([
  ''
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string = ''

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments array = []

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Optional. The type of Redis cache to deploy. Valid values: (Basic, Standard, Premium)')
param skuName string = 'Standard'

@allowed([
  'C'
  'P'
])
@description('Optional. The SKU family to use. Valid values: (C, P). (C = Basic/Standard, P = Premium).')
param family string = 'C'

@allowed([
  0
  1
  2
  3
  4
  5
  6
])
@description('Optional. The size of the Redis cache to deploy. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4).')
param capacity int = 1

@description('Optional. Specifies whether the non-ssl Redis server port (6379) is enabled.')
param enableNonSslPort bool = false

@allowed([
  '1.0'
  '1.1'
  '1.2'
])
@description('Optional. Specify the type of lock.')
param minimumTlsVersion string = '1.2'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Control permission for data plane traffic coming from public networks while private endpoint is enabled.')
param publicNetworkAccess string = 'Enabled'

@description('Optional. All Redis Settings. Few possible keys: rdb-backup-enabled,rdb-storage-connection-string,rdb-backup-frequency,maxmemory-delta,maxmemory-policy,notify-keyspace-events,maxmemory-samples,slowlog-log-slower-than,slowlog-max-len,list-max-ziplist-entries,list-max-ziplist-value,hash-max-ziplist-entries,hash-max-ziplist-value,set-max-intset-entries,zset-max-ziplist-entries,zset-max-ziplist-value etc.')
param redisConfiguration object = {}

@allowed([
  '4'
  '6'
])
@description('Optional. Redis version. Only major version will be used in PUT/PATCH request with current valid values: (4, 6)')
param redisVersion string = '6'

@minValue(1)
@description('Optional. The number of replicas to be created per primary.')
param replicasPerMaster int = 1

@minValue(1)
@description('Optional. The number of replicas to be created per primary.')
param replicasPerPrimary int = 1

@minValue(1)
@description('Optional. The number of shards to be created on a Premium Cluster Cache.')
param shardCount int = 1

@description('Optional. Static IP address. Optionally, may be specified when deploying a Redis cache inside an existing Azure Virtual Network; auto assigned by default.')
param staticIP string = ''

@description('Optional. The full resource ID of a subnet in a virtual network to deploy the Redis cache in. Example format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/Microsoft.{Network|ClassicNetwork}/VirtualNetworks/vnet1/subnets/subnet1')
param subnetId string = ''

@description('Optional. A dictionary of tenant settings.')
param tenantSettings object = {}

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticEventHubName string = ''

@description('Optional. The name of logs that will be streamed.')
@allowed([
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayPerformanceLog'
  'ApplicationGatewayFirewallLog'
])
param diagnosticLogCategoriesToEnable array = [
  'ApplicationGatewayAccessLog'
  'ApplicationGatewayPerformanceLog'
  'ApplicationGatewayFirewallLog'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]


// variables
var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var diagnosticsLogs = [for category in diagnosticLogCategoriesToEnable: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]


// resources
resource redisCache 'Microsoft.Cache/redis@2021-06-01' = {
  name: name
  location: location
  tags: tags
  identity: identity
  properties: {
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: minimumTlsVersion
    publicNetworkAccess: publicNetworkAccess
    redisConfiguration: !empty(redisConfiguration) ? redisConfiguration : null
    redisVersion: redisVersion
    replicasPerMaster: skuName == 'Premium' ? replicasPerMaster : null
    replicasPerPrimary: skuName == 'Premium' ? replicasPerPrimary : null
    shardCount: family == 'P' ? shardCount : null // Not supported in free tier
    sku: {
      name: skuName
      family: family
      capacity: capacity
    }
    staticIP: !empty(staticIP) ? staticIP : null
    subnetId: !empty(subnetId) ? subnetId : null
    tenantSettings: tenantSettings
  }
  zones: skuName == 'Premium' ? pickZones('Microsoft.Cache', 'redis', location, 1) : null
}

resource redisCache_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock)) {
  name: '${redisCache.name}-${lock}-lock'
  properties: {
    level: any(lock)
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: redisCache
}

resource redisCache_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    workspaceId: empty(diagnosticWorkspaceId) ? null : diagnosticWorkspaceId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    metrics: empty(diagnosticStorageAccountId) && empty(diagnosticWorkspaceId) && empty(diagnosticEventHubAuthorizationRuleId) && empty(diagnosticEventHubName) ? null : diagnosticsMetrics
    logs: empty(diagnosticStorageAccountId) && empty(diagnosticWorkspaceId) && empty(diagnosticEventHubAuthorizationRuleId) && empty(diagnosticEventHubName) ? null : diagnosticsLogs
  }
  scope: redisCache
}

module redisCache_rbac '.bicep/nested_roleAssignments.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-AppGateway-Rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principalIds: roleAssignment.principalIds
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : ''
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: redisCache.id
  }
}]


// outputs
@description('The name of the deployed Redis cache.')
output name string = redisCache.name

@description('The resource ID of the deployed Redis cache.')
output resourceId string = redisCache.id

@description('The resource group of the deployed Redis cache.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = redisCache.location

@description('Redis host name.')
output hostName string = redisCache.properties.hostName

@description('Redis SSL port.')
output sslPort int = redisCache.properties.sslPort

@description('The full resource ID of a subnet in a virtual network where the Redis cache was deployed in.')
output subnetId int = redisCache.properties.subnetId
