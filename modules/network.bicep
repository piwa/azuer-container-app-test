param location string

param virtualNetworkName string = 'dev-stable-vnet'
param virtualNetworkNameAddressPrefix string = '11.0.0.0/19'

param containerAppEnvSubnetName string = 'container-app-env-subnet'
param containerAppEnvSubnetAddressPrefix string = '11.0.2.0/23'

param containerAppRuntimeSubnetName string = 'container-app-runtime-subnet'
param containerAppRuntimeSubnetAddressPrefix string = '11.0.4.0/23'

param appGatewaySubnetName string = 'app-gateway-subnet'
param appGatewaySubnetAddressPrefix string = '11.0.1.0/24'



resource vNet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkNameAddressPrefix
      ]
    }
  }
}


resource containerAppEnvSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vNet
  name: containerAppEnvSubnetName
  properties: {
    addressPrefix: containerAppEnvSubnetAddressPrefix
  }
}

resource containerAppRuntimeSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vNet
  name: containerAppRuntimeSubnetName
  dependsOn: [
    containerAppEnvSubnet
  ]
  properties: {
    addressPrefix: containerAppRuntimeSubnetAddressPrefix
  }
}

resource appGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' = {
  parent: vNet
  name: appGatewaySubnetName
  dependsOn: [
    containerAppRuntimeSubnet
  ]
  properties: {
    addressPrefix: appGatewaySubnetAddressPrefix
  }
}

output containerAppEnvSubnetId string = containerAppEnvSubnet.id
output containerAppRuntimeSubnetId string = containerAppRuntimeSubnet.id
output appGatewaySubnetId string = appGatewaySubnet.id
output vNetId string = vNet.id

