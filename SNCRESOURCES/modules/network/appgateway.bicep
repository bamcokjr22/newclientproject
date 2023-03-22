param publicIPName string
param location string
param publicIPAllocationMethod string 
param appGWName string
param appGWSKU string
param appGWTier string
param appGWCapacity int
param appGWFrontendIPConfigurationName string
param appGWIPConfigurationName string
param subnetId string
param appGWFrontendPortsName string
param appGWFrontendPorts int
param appGWFrontendIPConfigurationId string
param appGWBackendAddressPoolsName string
param appGWBackendHttpSettingsCollectionName string
param appGWBackendHttpSettingsCollectionPort int
param appGWHttpListenersPort string
param appGWHttpListenersProtocol string
param appGWBackendHttpSettingsCollectionProtocol string
param appGWBackendHttpSettingsCollectionCookieBasedAffinity string
param appGWHttpListenersName string
param appGWRequestRoutingRulesName string
param appGWHttpListenerId string
param appGWBackendAddressPoolId string
param appGWBackendHttpSettingsId string

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    // dnsSettings: {
    //   domainNameLabel: 'dnsname'
    // }
  }
}


resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: appGWName
  location: location
  properties: {
    sku: {
      name: appGWSKU
      tier: appGWTier
      capacity: appGWCapacity
    }
    gatewayIPConfigurations: [
      {
        name: appGWIPConfigurationName
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: appGWFrontendIPConfigurationName
        properties: {
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: appGWFrontendPortsName
        properties: {
          port: appGWFrontendPorts
        }
      }
    ]
    backendAddressPools: [
      {
        name: appGWBackendAddressPoolsName
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: appGWBackendHttpSettingsCollectionName
        properties: {
          port: appGWBackendHttpSettingsCollectionPort
          protocol: appGWBackendHttpSettingsCollectionProtocol
          cookieBasedAffinity: appGWBackendHttpSettingsCollectionCookieBasedAffinity
        }
      }
    ]
    httpListeners: [
      {
        name: appGWHttpListenersName
        properties: {
          frontendIPConfiguration: {
            id: appGWFrontendIPConfigurationId
          }
          frontendPort: {
            id: appGWHttpListenersPort
          }
          protocol: appGWHttpListenersProtocol
          sslCertificate: null
        }
      }
    ]
    requestRoutingRules: [
      {
        name: appGWRequestRoutingRulesName
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: appGWHttpListenerId
          }
          backendAddressPool: {
            id: appGWBackendAddressPoolId
          }
          backendHttpSettings: {
            id: appGWBackendHttpSettingsId
          }
        }
      }
    ]
  }
}
