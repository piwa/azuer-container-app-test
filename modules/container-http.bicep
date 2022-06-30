param containerAppName string
param location string 
param environmentName string 
param containerImage string
param containerPort int
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param isPrivateRegistry bool
param enableIngress bool 
param allowInsecure bool = false
param registryPassword string
param minReplicas int = 0
param resourcesCpu int = 1
param resourcesMemory string = '1Gi'
param secrets array = []
param env array = []
param containerCommand array = []
param containerArgs array = []

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: environmentName
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      secrets: secrets
      registries: isPrivateRegistry ? [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: registryPassword
        }
      ] : null
      ingress: enableIngress ? {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
        allowInsecure: allowInsecure
      } : null
      dapr: {
        enabled: false
        appPort: containerPort
        appId: containerAppName
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          command: containerCommand
          args: containerArgs    
          env: env
          resources: {
            cpu: resourcesCpu
            memory: resourcesMemory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 1
      }
    }
  }
}

output fqdn string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : 'Ingress not enabled'
