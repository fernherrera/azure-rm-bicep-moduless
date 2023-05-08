// set the target scope for this file
targetScope = 'resourceGroup'


// parameters
param location string = 'eastus'
param tags object = {}
param orgCode string = 'org'
param product string = 'product'
param env string = 'dev'
param name string

// param serverName string
param serverUsername string
param serverPassword string
param serverEdition string = 'GeneralPurpose'
param vCores int = 2
param skuFamily string = 'Gen5'
param skuSizeMB string = '131072'
param vmName string = 'GP_Gen5_2'

// param databaseName string
param databaseVersion string = '5.7'
param charset string = 'utf8'
param collation string = 'utf8_general_ci'

// param hostingPlanName string
param kind string = 'app'
param sslEnforcement string = 'Enabled'
param minimalTlsVersion string = 'TLS1_2'
param storageSizeMB int = 131072
param backupRetentionDays int = 7
param geoRedundantBackup string = 'Disabled'
param storageAutoGrow string = 'Enabled'
param appSettings array = []
param properties object = {}
param webProperties object = {}
param repoUrl string = 'https://github.com/azureappserviceoss/wordpress-azure'


// variables
var serverName = '${orgCode}-${env}-${product}-${name}-mysql'
var databaseName = '${orgCode}-${env}-${product}-${name}-mysql-db'
var hostingPlanName = '${orgCode}-${env}-${product}-${name}-plan'
var appServiceName = '${orgCode}-${env}-${product}-${name}-wp-app'
var storageAccountName = '${orgCode}${env}${product}${name}sa'

var defaultAppSettings = [
  {
    name: 'PHPMYADMIN_EXTENSION_VERSION'
    value: 'latest'
  }
]

var defaultProperties = {
  serverFarmId: resourceId('Microsoft.Web/serverFarms/', hostingPlanName)
  enabled: true
  httpsOnly: true
  clientAffinityEnabled: false
  siteConfig: {
    appSettings: combinedAppSettings
    connectionStrings: [
      {
        name: 'defaultConnection'
        type: 'MySql'
        ConnectionString: 'Database=${databaseName};Data Source=${serverName}.mysql.database.azure.com;User Id=${serverUsername};Password=${serverPassword}'
      }
    ]
    alwaysOn: true
    http20Enabled: false
  }
}

var defaultWebProperties = {
  numberOfWorkers: 1
  netFrameworkVersion: 'v4.0'
  phpVersion: '7.4'
}

var combinedAppSettings = concat(defaultAppSettings, appSettings)
var combinedProperties = union(defaultProperties, properties)
var combinedWebProperties = union(defaultWebProperties, webProperties)


// resources
// Create database server
resource dbServer 'Microsoft.DBforMySQL/servers@2017-12-01-preview' = {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: vmName
    tier: serverEdition
    capacity: vCores
    size: skuSizeMB
    family: skuFamily
  }
  properties: {
    version: databaseVersion
    administratorLogin: serverUsername
    administratorLoginPassword: serverPassword
    createMode: 'Default'
    sslEnforcement: sslEnforcement
    minimalTlsVersion: minimalTlsVersion
    storageProfile: {
      storageMB: storageSizeMB
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
      storageAutogrow: storageAutoGrow
    }
  }
}

// Firewall rules for MySql server
resource fwRules 'Microsoft.DBforMySQL/servers/firewallRules@2017-12-01-preview' = {
  name: '${serverName}/AllowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
  dependsOn: [
    dbServer
  ]
}

// Create database
resource db 'Microsoft.DBforMySQL/servers/databases@2017-12-01-preview' = {
  parent: dbServer
  name: databaseName
  properties: {
    charset: charset
    collation: collation
  }
}

// Create hosting plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  location: location
  tags: tags
  name: hostingPlanName
  kind: ''
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    reserved: false
  }
}

// Create App Service
resource appService 'Microsoft.Web/sites@2021-01-01' = {
  location: location
  tags: tags
  name: appServiceName
  kind: kind
  properties: combinedProperties
  dependsOn: [
    appServicePlan
    dbServer
    db
  ]
}

// Configure app service
resource appService_config 'Microsoft.Web/sites/config@2021-03-01' = {
  parent: appService
  name: 'web'
  properties: combinedWebProperties
}

// Set wordpress repo
resource scm 'Microsoft.Web/sites/sourcecontrols@2021-03-01' = {
  parent: appService
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: 'master'
    isManualIntegration: true
  }
}

// Create storage account
resource sa 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
