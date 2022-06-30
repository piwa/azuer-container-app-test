param location string
param appGatewayName string = 'dev-stable-app-gateway'

param protocol string = 'Http'
param appGatewayMinCapacity int = 1
param appGatewayMaxCapacity int = 2

param backendFqdn string
param subnetId string



resource publicIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: '${appGatewayName}-public-ip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: appGatewayName
    }
  }
}

resource appGateway 'Microsoft.Network/applicationGateways@2021-08-01' = {
  name: appGatewayName
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    autoscaleConfiguration: {
      minCapacity: appGatewayMinCapacity
      maxCapacity: appGatewayMaxCapacity
    }
    gatewayIPConfigurations: [
      {
        name: 'default'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'default'
        properties: {
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'default'
        properties: {
          port: 80
        }
      }
    ]
    httpListeners: [
      {
        name: 'default'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'default')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'default')
          }
          protocol: protocol
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backend'
        properties: {
          backendAddresses: [
            {
              fqdn: backendFqdn
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'backend'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          hostName: backendFqdn
          requestTimeout: 30
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', appGatewayName, 'backend-probe')
          }
        }
      }
    ]
    probes: [
      {
        name: 'backend-probe'
        properties: {
          protocol: 'Http'
          port: 80
          path: '/'
          interval: 15
          timeout: 15
          host: backendFqdn
          unhealthyThreshold: 3
          match: {
            statusCodes: [
              '200'
            ]
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'backend-rule'
        properties: {
          priority: 1000
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName, 'backend')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName, 'backend')
          }
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'default')
          }
          ruleType: 'Basic'
        }
      }
    ]
  }
}

output publicIpId string = publicIP.id
