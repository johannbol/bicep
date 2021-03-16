param location string = resourceGroup().location
param namePrefix string = 'stg'
param storageAccountName string 

param containerNames array = [
  'dogs'
  'cats'
  'fish'
]

var storageSku = 'Standard_LRS'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  kind: 'Storage'
  sku: {
    name: storageSku
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for name in containerNames: {
  name: '${stg.name}/default/${name}'
  
}]

output storageId string = stg.id
output computerStorageName string = stg.name
output blobEndpoint string = stg.properties.primaryEndpoints.blob