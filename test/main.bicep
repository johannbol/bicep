targetScope = 'subscription'


module stg 'storage.bicep'= {
  name: 'storageDeploy'
  scope: resourceGroup(rg.name)
  params:{
    storageAccountName: 'stgffdocx5eypn2k'
    containerNames: [
      'heida'
      'dagur'
      'thordis'
    ]
  }

}

resource rg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: 'jolaf'
  location: 'westeurope'
}