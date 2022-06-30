param location string = resourceGroup().location
param environmentName string = 'dev-stable-container-app-environment'

param virtualNetworkName string = 'dev-stable-vnet'

param minReplicas int = 1

param testServiceImage string = 'mcr.microsoft.com/azuredocs/aci-helloworld'
param testServicePort int = 80
var testServiceAppName = 'test-app'

param isPrivateRegistry bool = false

param containerRegistryName string = ''
param registryPassword string = 'registry-password'



module network 'modules/network.bicep' = {
  name: virtualNetworkName
  params: {
    location: location
  }
}

module environment 'modules/environment.bicep' = {
  name: 'dev-stable-container-app-environment'
  dependsOn: [
    network
  ]
  params: {
    environmentName: environmentName
    location: location
    appInsightsName: '${environmentName}-ai'
    logAnalyticsWorkspaceName: '${environmentName}-la'
    containerAppEnvSubnetId: network.outputs.containerAppEnvSubnetId
    containerAppRuntimeSubnetId: network.outputs.containerAppRuntimeSubnetId
  }
}

module privateDNS 'modules/privatedns.bicep' = {
  name: 'dev-stable-private-dns'
  dependsOn: [
    environment
  ]
  params: {
    domainName: environment.outputs.environmentDefaultDomain
    staticIp: environment.outputs.environmentStaticIp
    vNetId: network.outputs.vNetId
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: containerRegistryName
  scope: resourceGroup('Noreja-Dev')  
}


module testService 'modules/container-http.bicep' = {
  name: 'dev-stable-container-test-app'
  dependsOn: [
    environment
  ]
  params: {
    enableIngress: true
    isExternalIngress: false
    allowInsecure: true
    location: location
    environmentName: environmentName
    containerAppName: testServiceAppName
    containerImage: testServiceImage
    containerPort: testServicePort
    isPrivateRegistry: isPrivateRegistry 
    minReplicas: minReplicas
    resourcesCpu: 1 
    resourcesMemory: '2Gi'
    containerRegistry: '${containerRegistry.name}.azurecr.io'
    registryPassword: registryPassword
    containerRegistryUsername: containerRegistry.listCredentials().username

    env: []
    secrets: [
      {
        name: registryPassword
        value: containerRegistry.listCredentials().passwords[0].value
      }
    ]
  }
}

module appgw 'modules/appgw.bicep' = {
  name: 'dev-stable-app-gateway'
  dependsOn: [
    testService
  ]
  params: {
    backendFqdn: testService.outputs.fqdn
    subnetId: network.outputs.appGatewaySubnetId
    location: location
  }
}
