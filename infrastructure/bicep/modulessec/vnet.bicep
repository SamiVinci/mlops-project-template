// Creates a virtual network
@description('Azure region of the deployment')
param location string = resourceGroup().location

@description('Tags to add to the resources')
param tags object = {}

@description('Name of the virtual network resource')
param virtualNetworkName string

@description('Group ID of the network security group')
param networkSecurityGroupId string

@description('Virtual network address prefix')
param vnetAddressPrefix string = '192.168.0.0/16'

@description('Training subnet address prefix')
param trainingSubnetPrefix string = '192.168.0.0/24'

@description('Scoring subnet address prefix')
param scoringSubnetPrefix string = '192.168.1.0/24'

@description('The address prefix to use for the Bastion subnet')
param azureBastionSubnetPrefix string = '192.168.250.0/27'

var bastionSubnetName  = 'AzureBastionSubnet'


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-07-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      { 
        name: 'snet-training'
        properties: {
          addressPrefix: trainingSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
      { 
        name: 'snet-scoring'
        properties: {
          addressPrefix: scoringSubnetPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
            {
              service: 'Microsoft.ContainerRegistry'
            }
            {
              service: 'Microsoft.Storage'
            }
          ]
          networkSecurityGroup: {
            id: networkSecurityGroupId
          }
        }
      }
      {
        name: bastionSubnetName
        properties:{
          addressPrefix: azureBastionSubnetPrefix
          privateEndpointNetworkPolicies:'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output id string = virtualNetwork.id
output name string = virtualNetwork.name
output bastionid string = virtualNetwork.properties.subnets[2].id