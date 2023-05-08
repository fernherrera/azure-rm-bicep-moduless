/*
  author: Fernando Herrera <fherrera@intermexusa.com>
  type: Module
  description: This module imports a BACPAC into an existing SQL database.
*/

// parameters
@description('The name of the SQL logical server.')
param serverName string

@description('The name of the SQL Database.')
param databaseName string

@description('The administrator username of the SQL logical server.')
param administratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

@description('Specifies the key of the storage account where the BACPAC file is stored.')
@secure()
param storageAccountKey string

@description('Specifies the URL of the BACPAC file.')
param bacpacUrl string


// resources
resource sqlDatabase_import 'Microsoft.Sql/servers/databases/extensions@2014-04-01' = {
  name: '${serverName}/${databaseName}/Import'
  properties: {
    storageKeyType: 'StorageAccessKey'
    storageKey: storageAccountKey
    storageUri: bacpacUrl
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    operationMode: 'Import'
  }
}

output sqlDatabaseImportId string = sqlDatabase_import.id
