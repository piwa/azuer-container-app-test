param domainName string
param staticIp string
param vNetId string


resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: domainName
  location: 'Global'
}

resource privateDnsZoneEntry 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '*'
  parent: privateDnsZone
  properties: {
    aRecords: [
      {
        ipv4Address: staticIp
      }
    ]
    ttl: 3600
  }
}

resource vnetLinkHub 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${privateDnsZone.name}/${domainName}-link'
  location: 'Global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNetId
    }
  }
}
