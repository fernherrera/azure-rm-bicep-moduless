@description('Conditional. The name of the parent API Management service. Required if the template is used in a standalone deployment.')
param apiManagementServiceName string

@description('Conditional. The name of the parent Product. Required if the template is used in a standalone deployment.')
param productName string

@description('Required. Name of the product API.')
param name string



resource service 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apiManagementServiceName

  resource product 'products@2021-04-01-preview' existing = {
    name: productName
  }
}

resource api 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: name
  parent: service::product
}

@description('The resource ID of the product API.')
output resourceId string = api.id

@description('The name of the product API.')
output name string = api.name

@description('The resource group the product API was deployed into.')
output resourceGroupName string = resourceGroup().name