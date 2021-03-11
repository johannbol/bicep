param adminUserName string

@secure()
param adminPassword string

param dnsLabelPrefix string

//@allowed([
//  '20h2-ent'
//  '20h2-ent-g2'
//  '20h2-entn'
//  '20h2-entn-g2'
//])
@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
param windowsOSVersion array = [
  '20h2-ent'
  '20h2-ent-g2'
  '20h2-entn'
  '20h2-entn-g2'
]

@description('Size of the virtual machine.')
param vmSize string = 'Standard_DS1_v2'

@description('location for all resources')
param location string = resourceGroup().location

var storageAccountName = concat(uniqueString(resourceGroup().id), 'sawinvm')
var nicName = 'myVMNic'
var subnetName = 'Q901-WE-subnet'
var vmName = 'SimpleWinVM'
var virtualNetworkName = 'Q901-WE-vnet'
var subnetRef = '${vn.id}/subnets/${subnetName}'
var networkSecurityGroupName = 'default-NSG'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

resource vn 'Microsoft.Network/virtualNetworks@2020-06-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup('Q901-WE-network') 
}
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'myNSG'
  location: location
  properties: {
    securityRules:[
      {
        name: 'MySecurityRule'
        properties:{
          priority: 1000
          protocol: 'Tcp'
          direction:'Inbound'
          sourcePortRange: '22'
          destinationPortRange: '22'
          access:'Deny'
          sourceAddressPrefix: '10.0.0.0/28'
          destinationAddressPrefix: '10.0.0.0/28'
        }
      }
    ]
  }
}
resource nInter 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0, length(windowsOSVersion)): {
  name: '${nicName}${i}'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig${i}'
        properties: {
          privateIPAllocationMethod: 'Dynamic'

          subnet: {
            id: subnetRef
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}]

resource VM 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0, length(windowsOSVersion)): {
  name: '${vmName}-${windowsOSVersion[i]}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: windowsOSVersion[i]
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nInter[i].id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: stg.properties.primaryEndpoints.blob
      }
    }
  }
}]
