@description('Application gateway name')
param applicationGatewayName string

@description('Application gateway location')
param location string = resourceGroup().location

@description('Application gateway tier')
@allowed([
  'Standard'
  'WAF'
  'Standard_v2'
  'WAF_v2'
])
param tier string

@description('Application gateway sku')
@allowed([
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'WAF_Medium'
  'WAF_Large'
  'Standard_v2'
  'WAF_v2'
])
param sku string

@description('Enable HTTP/2 support')
param http2Enabled bool = true

@description('Capacity (instance count) of application gateway')
@minValue(1)
@maxValue(32)
param capacity int = 2

@description('Autoscale capacity (instance count) of application gateway')
@minValue(1)
@maxValue(32)
param autoScaleMaxCapacity int = 10

@description('Enable Azure availabilty zone redundancy')
param zoneRedundant bool = false

@description('Public ip address name')
param publicIpAddressName string

@description('Virutal network subscription id')
param vNetSubscriptionId string = subscription().subscriptionId

@description('Virutal network resource group')
param vNetResourceGroup string

@description('Virutal network name')
param vNetName string

@description('Application gateway subnet name')
param subnetName string

@description('Array containing ssl certificates')
@metadata({
  name: 'Certificate name'
  keyVaultResourceId: 'Key vault resource id'
  secretName: 'Secret name'
})
param sslCertificates array = []

@description('Array containing trusted root certificates')
@metadata({
  name: 'Certificate name'
  keyVaultResourceId: 'Key vault resource id'
  secretName: 'Secret name'
})
param trustedRootCertificates array = []

@description('Array containing http listeners')
@metadata({
  name: 'Listener name'
  protocol: 'Listener protocol'
  frontEndPort: 'Front end port name'
  sslCertificate: 'SSL certificate name' // only required for https listeners
  hostNames: 'Array containing host names'
  firewallPolicy: 'Enabled/Disabled. Configures firewall policy on listener'
})
param httpListeners array

@description('Array containing backend address pools')
@metadata({
  name: 'Backend address pool name'
  backendAddresses: 'Array containing backend addresses'
})
param backendAddressPools array = []

@description('Array containing backend http settings')
@metadata({
  name: 'Backend http setting name'
  port: 'integer containing port number'
  protocol: 'Backend http setting protocol'
  cookieBasedAffinity: 'Enabled/Disabled. Configures cookie based affinity.'
  requestTimeout: 'Integer containing backend http setting request timeout'
  connectionDraining: {
    drainTimeoutInSec: 'Integer containing connection drain timeout in seconds'
    enabled: 'Bool to enable connection draining'
  }
  trustedRootCertificate: 'Trusted root certificate name'
  hostName: 'Backend http setting host name'
  probeName: 'Custom probe name'
})
param backendHttpSettings array = []

@description('Array containing request routing rules')
@metadata({
  name: 'Rule name'
  ruleType: 'Rule type'
  listener: 'Http listener name'
  backendPool: 'Backend pool name'
  backendHttpSettings: 'Backend http setting name'
  redirectConfiguration: 'Redirection configuration name'
})
param rules array

@description('Array containing redirect configurations')
@metadata({
  name: 'Redirecton name'
  redirectType: 'Redirect type'
  targetUrl: 'Target URL'
  includePath: 'Bool to include path'
  includeQueryString: 'Bool to include query string'
  requestRoutingRule: 'Name of request routing rule to associate redirection configuration'
})
param redirectConfigurations array = []

@description('Array containing front end ports')
@metadata({
  name: 'Front port name'
  port: 'Integer containing port number'
})
param frontEndPorts array

@description('Array containing custom probes')
@metadata({
  name: 'Custom probe name'
  protocol: 'Custom probe protocol'
  host: 'Host name'
  path: 'Probe path'
  interval: 'Integer containing probe interval'
  timeout: 'Integer containing probe timeout'
  unhealthyThreshold: 'Integer containing probe unhealthy threshold'
  pickHostNameFromBackendHttpSettings: 'Bool to enable pick host name from backend settings'
  minServers: 'Integer containing min servers'
  match: {
    statusCodes: [
      'Custom probe status codes'
    ]
  }
})
param customProbes array = []

@description('Resource id of an existing user assigned managed identity to associate with the application gateway')
param managedIdentityResourceId string = ''

@description('Enable web application firewall')
param enableWebApplicationFirewall bool = false

@description('Name of the firewall policy. Only required if enableWebApplicationFirewall is set to true')
param firewallPolicyName string = ''

@description('Array containing the firewall policy settings. Only required if enableWebApplicationFirewall is set to true')
@metadata({
  requestBodyCheck: 'Bool to enable request body check'
  maxRequestBodySizeInKb: 'Integer containing max request body size in kb'
  fileUploadLimitInMb: 'Integer containing file upload limit in mb'
  state: 'Enabled/Disabled. Configures firewall policy settings'
  mode: 'Sets the detection mode'
})
param firewallPolicySettings object = {
  requestBodyCheck: true
  maxRequestBodySizeInKb: 128
  fileUploadLimitInMb: 100
  state: 'Enabled'
  mode: 'Detection'
}

@description('Array containing the firewall policy custom rules. Only required if enableWebApplicationFirewall is set to true')
@metadata({
  action: 'Type of actions'
  matchConditions: 'Array containing match conditions'
  name: 'Custom rule name'
  priority: 'Integer containing priority'
  ruleType: 'Rule type'
})
param firewallPolicyCustomRules array = []

@description('Array containing the firewall policy managed rule sets. Only required if enableWebApplicationFirewall is set to true')
@metadata({
  ruleSetType: 'Rule set type'
  ruleSetVersion: 'Rule set version'
})
param firewallPolicyManagedRuleSets array = [
  {
    ruleSetType: 'OWASP'
    ruleSetVersion: '3.2'
  }
]

@description('Array containing the firewall policy managed rule exclusions. Only required if enableWebApplicationFirewall is set to true')
@metadata({
  matchVariable: 'Variable to be excluded'
  selector: 'String specifying exclusions'
  selectorMatchOperator: 'Exclusion operator'
})
param firewallPolicyManagedRuleExclusions array = []

@description('Enable delete lock')
param enableDeleteLock bool = false

@description('Enable diagnostic logs')
param enableDiagnostics bool = false

@description('Storage account resource id. Only required if enableDiagnostics is set to true')
param diagnosticStorageAccountId string = ''

@description('Log analytics workspace resource id. Only required if enableDiagnostics is set to true')
param logAnalyticsWorkspaceId string = ''

var publicIpLockName = '${publicIpAddress.name}-lck'
var publicIpDiagnosticsName = '${publicIpAddress.name}-dgs'
var appGatewayLockName = '${applicationGateway.name}-lck'
var appGatewayDiagnosticsName = '${applicationGateway.name}-dgs'
var gatewayIpConfigurationName = 'appGatewayIpConfig'
var frontendIpConfigurationName = 'appGwPublicFrontendIp'

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource publicIpAddressDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: publicIpAddress
  name: publicIpDiagnosticsName
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        category: 'DDoSProtectionNotifications'
        enabled: true
      }
      {
        category: 'DDoSMitigationFlowLogs'
        enabled: true
      }
      {
        category: 'DDoSMitigationReports'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource publicIpAddressLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: publicIpAddress
  name: publicIpLockName
  properties: {
    level: 'CanNotDelete'
  }
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2021-03-01' = {
  name: applicationGatewayName
  location: location
  zones: zoneRedundant ? [
    '1'
    '2'
    '3'
  ] : []
  identity: !empty(managedIdentityResourceId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResourceId}': {}
    }
  } : null
  properties: {
    sku: {
      name: sku
      tier: tier
    }
    autoscaleConfiguration: {
      minCapacity: capacity
      maxCapacity: autoScaleMaxCapacity
    }
    enableHttp2: http2Enabled
    webApplicationFirewallConfiguration: enableWebApplicationFirewall ? {
      enabled: firewallPolicySettings.state == 'Enabled' ? true : false
      firewallMode: firewallPolicySettings.mode
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    } : null
    gatewayIPConfigurations: [
      {
        name: gatewayIpConfigurationName
        properties: {
          subnet: {
            id: resourceId(vNetSubscriptionId, vNetResourceGroup, 'Microsoft.Network/virtualNetworks/subnets', vNetName, subnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: frontendIpConfigurationName
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [for frontEndPort in frontEndPorts: {
      name: frontEndPort.name
      properties: {
        port: frontEndPort.port
      }
    }]
    probes: [for probe in customProbes: {
      name: probe.name
      properties: {
        protocol: probe.protocol
        host: probe.host
        path: probe.path
        interval: probe.interval
        timeout: probe.timeout
        unhealthyThreshold: probe.unhealthyThreshold
        pickHostNameFromBackendHttpSettings: probe.pickHostNameFromBackendHttpSettings
        minServers: probe.minServers
        match: probe.match
      }
    }]
    backendAddressPools: [for backendAddressPool in backendAddressPools: {
      name: backendAddressPool.name
      properties: {
        backendAddresses: backendAddressPool.backendAddresses
      }
    }]
    firewallPolicy: enableWebApplicationFirewall ? {
      id: firewallPolicy.id
    } : null
    trustedRootCertificates: [for trustedRootCertificate in trustedRootCertificates: {
      name: trustedRootCertificate.name
      properties: {
        keyVaultSecretId: '${reference(trustedRootCertificate.keyVaultResourceId, '2021-10-01').vaultUri}secrets/${trustedRootCertificate.secretName}'
      }
    }]
    sslCertificates: [for sslCertificate in sslCertificates: {
      name: sslCertificate.name
      properties: {
        keyVaultSecretId: '${reference(sslCertificate.keyVaultResourceId, '2021-10-01').vaultUri}secrets/${sslCertificate.secretName}'
      }
    }]
    backendHttpSettingsCollection: [for backendHttpSetting in backendHttpSettings: {
      name: backendHttpSetting.name
      properties: {
        port: backendHttpSetting.port
        protocol: backendHttpSetting.protocol
        cookieBasedAffinity: backendHttpSetting.cookieBasedAffinity
        affinityCookieName: contains(backendHttpSetting, 'affinityCookieName') ? backendHttpSetting.affinityCookieName : null
        requestTimeout: backendHttpSetting.requestTimeout
        connectionDraining: backendHttpSetting.connectionDraining
        probe: contains(backendHttpSetting, 'probeName') ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, backendHttpSetting.probeName)}"}') : null
        trustedRootCertificates: contains(backendHttpSetting, 'trustedRootCertificate') ? json('[{"id": "${resourceId('Microsoft.Network/applicationGateways/trustedRootCertificates', applicationGatewayName, backendHttpSetting.trustedRootCertificate)}"}]') : null
        hostName: contains(backendHttpSetting, 'hostName') ? backendHttpSetting.hostName : null
        pickHostNameFromBackendAddress: contains(backendHttpSetting, 'pickHostNameFromBackendAddress') ? backendHttpSetting.pickHostNameFromBackendAddress : false
      }
    }]
    httpListeners: [for httpListener in httpListeners: {
      name: httpListener.name
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, frontendIpConfigurationName)
        }
        frontendPort: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, httpListener.frontEndPort)
        }
        protocol: httpListener.protocol
        sslCertificate: contains(httpListener, 'sslCertificate') ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, httpListener.sslCertificate)}"}') : null
        hostNames: contains(httpListener, 'hostNames') ? httpListener.hostNames : null
        hostName: contains(httpListener, 'hostName') ? httpListener.hostName : null
        requireServerNameIndication: contains(httpListener, 'requireServerNameIndication') ? httpListener.requireServerNameIndication : false
        firewallPolicy: contains(httpListener, 'firewallPolicy') ? json('{"id": "${firewallPolicy.id}"}') : null
      }
    }]
    requestRoutingRules: [for rule in rules: {
      name: rule.name
      properties: {
        ruleType: rule.ruleType
        httpListener: contains(rule, 'listener') ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, rule.listener)}"}') : null
        backendAddressPool: contains(rule, 'backendPool') ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, rule.backendPool)}"}') : null
        backendHttpSettings: contains(rule, 'backendHttpSettings') ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, rule.backendHttpSettings)}"}') : null
        redirectConfiguration: contains(rule, 'redirectConfiguration') ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, rule.redirectConfiguration)}"}') : null
      }
    }]
    redirectConfigurations: [for redirectConfiguration in redirectConfigurations: {
      name: redirectConfiguration.name
      properties: {
        redirectType: redirectConfiguration.redirectType
        targetUrl: redirectConfiguration.targetUrl
        targetListener: contains(redirectConfiguration, 'targetListener') ? json('{"id": "${resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, redirectConfiguration.targetListener)}"}') : null
        includePath: redirectConfiguration.includePath
        includeQueryString: redirectConfiguration.includeQueryString
        requestRoutingRules: [
          {
            id: resourceId('Microsoft.Network/applicationGateways/requestRoutingRules', applicationGatewayName, redirectConfiguration.requestRoutingRule)
          }
        ]
      }
    }]
  }
}

resource applicationGatewayDiagnostics 'microsoft.insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: applicationGateway
  name: appGatewayDiagnosticsName
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceId) ? null : logAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    logs: [
      {
        category: 'ApplicationGatewayAccessLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayPerformanceLog'
        enabled: true
      }
      {
        category: 'ApplicationGatewayFirewallLog'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource applicationGatewayLock 'Microsoft.Authorization/locks@2017-04-01' = if (enableDeleteLock) {
  scope: applicationGateway
  name: appGatewayLockName
  properties: {
    level: 'CanNotDelete'
  }
}

resource firewallPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-03-01' = if (enableWebApplicationFirewall) {
  name: firewallPolicyName == '' ? 'placeholdervalue' : firewallPolicyName // placeholder value required as name cannot be empty/null when enableWebApplicationFirewall equals false 
  location: location
  properties: {
    customRules: firewallPolicyCustomRules
    policySettings: firewallPolicySettings
    managedRules: {
      managedRuleSets: firewallPolicyManagedRuleSets
      exclusions: firewallPolicyManagedRuleExclusions
    }
  }
}

output name string = applicationGateway.name
output id string = applicationGateway.id



























// param publicIPName string
// param location string
// param publicIPAllocationMethod string 
// param appGWName string
// param appGWSKU string
// param appGWTier string
// param appGWCapacity int
// param appGWFrontendIPConfigurationName string
// param appGWIPConfigurationName string
// param subnetId string
// param appGWFrontendPortsName string
// param appGWFrontendPorts int
// param appGWFrontendIPConfigurationId string
// param appGWBackendAddressPoolsName string
// param appGWBackendHttpSettingsCollectionName string
// param appGWBackendHttpSettingsCollectionPort int
// param appGWHttpListenersPort string
// param appGWHttpListenersProtocol string
// param appGWBackendHttpSettingsCollectionProtocol string
// param appGWBackendHttpSettingsCollectionCookieBasedAffinity string
// param appGWHttpListenersName string
// param appGWRequestRoutingRulesName string
// param appGWHttpListenerId string
// param appGWBackendAddressPoolId string
// param appGWBackendHttpSettingsId string

// resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
//   name: publicIPName
//   location: location
//   properties: {
//     publicIPAllocationMethod: publicIPAllocationMethod
//     // dnsSettings: {
//     //   domainNameLabel: 'dnsname'
//     // }
//   }
// }

// resource applicationGateway 'Microsoft.Network/applicationGateways@2020-11-01' = {
//   name: appGWName
//   location: location
//   properties: {
//     sku: {
//       name: appGWSKU
//       tier: appGWTier
//       capacity: appGWCapacity
//     }
//     gatewayIPConfigurations: [
//       {
//         name: appGWIPConfigurationName
//         properties: {
//           subnet: {
//             id: subnetId
//           }
//         }
//       }
//     ]
//     frontendIPConfigurations: [
//       {
//         name: appGWFrontendIPConfigurationName
//         properties: {
//           publicIPAddress: {
//             id: publicIPAddress.id
//           }
//         }
//       }
//     ]
//     frontendPorts: [
//       {
//         name: appGWFrontendPortsName
//         properties: {
//           port: appGWFrontendPorts
//         }
//       }
//     ]
//     backendAddressPools: [
//       {
//         name: appGWBackendAddressPoolsName
//       }
//     ]
//     backendHttpSettingsCollection: [
//       {
//         name: appGWBackendHttpSettingsCollectionName
//         properties: {
//           port: appGWBackendHttpSettingsCollectionPort
//           protocol: appGWBackendHttpSettingsCollectionProtocol
//           cookieBasedAffinity: appGWBackendHttpSettingsCollectionCookieBasedAffinity
//         }
//       }
//     ]
//     httpListeners: [
//       {
//         name: appGWHttpListenersName
//         properties: {
//           frontendIPConfiguration: {
//             id: appGWFrontendIPConfigurationId
//           }
//           frontendPort: {
//             id: applicationGateway.frton appGWHttpListenersPort
//           }
//           protocol: appGWHttpListenersProtocol
//           sslCertificate: null
//         }
//       }
//     ]
//     requestRoutingRules: [
//       {
//         name: appGWRequestRoutingRulesName
//         properties: {
//           ruleType: 'Basic'
//           httpListener: {
//             id: appGWHttpListenerId
//           }
//           backendAddressPool: {
//             id: appGWBackendAddressPoolId
//           }
//           backendHttpSettings: {
//             id: appGWBackendHttpSettingsId
//           }
//         }
//       }
//     ]
//   }
// }
