@description('Specifies whether to deploy Azure Databricks workspace with Secure Cluster Connectivity (No Public IP) enabled or not')
param disablePublicIp bool = true
@description('The name of the Azure Databricks workspace to create.')
param workspaceName string
@description('The pricing tier of workspace.')
@allowed([
  'standard'
  'premium'
])
param pricingTier string = 'premium'

@description('Location for all resources.')
param location string

param managedResourceGroupId string

param privateSubnetName string

param publicSubnetName string

param virtualNetworkId string

// var managedResourceGroupName = 'databricks-rg-${workspaceName}-${uniqueString(workspaceName, resourceGroup().id)}'

resource databricks 'Microsoft.Databricks/workspaces@2022-04-01-preview' = {
  name: workspaceName
  location: location
  // tags: {
  //   tagName1: 'tagValue1'
  //   tagName2: 'tagValue2'
  // }
  sku: {
    name: pricingTier
    // tier: 'string'
  }
  properties: {
  //   authorizations: [
  //     {
  //       principalId: 'string'
  //       roleDefinitionId: 'string'
  //     }
  //   ]
  //   createdBy: {}
  //   encryption: {
  //     entities: {
  //       managedDisk: {
  //         keySource: 'Microsoft.Keyvault'
  //         keyVaultProperties: {
  //           keyName: 'string'
  //           keyVaultUri: 'string'
  //           keyVersion: 'string'
  //         }
  //         rotationToLatestKeyVersionEnabled: bool
  //       }
  //       managedServices: {
  //         keySource: 'Microsoft.Keyvault'
  //         keyVaultProperties: {
  //           keyName: 'string'
  //           keyVaultUri: 'string'
  //           keyVersion: 'string'
  //         }
  //       }
  //     }
  //   }
  //   managedDiskIdentity: {}
    managedResourceGroupId: managedResourceGroupId
    parameters: {
  //     amlWorkspaceId: {
  //       value: 'string'
  //     }
      customPrivateSubnetName: {
        value: privateSubnetName
      }
      customPublicSubnetName: {
        value: publicSubnetName
      }
      customVirtualNetworkId: {
        value: virtualNetworkId
      }
      enableNoPublicIp: {
        value: disablePublicIp
      }
  //     encryption: {
  //       value: {
  //         KeyName: 'string'
  //         keySource: 'string'
  //         keyvaulturi: 'string'
  //         keyversion: 'string'
  //       }
  //     }
  //     loadBalancerBackendPoolName: {
  //       value: 'string'
  //     }
  //     loadBalancerId: {
  //       value: 'string'
  //     }
  //     natGatewayName: {
  //       value: 'string'
  //     }
  //     prepareEncryption: {
  //       value: bool
  //     }
  //     publicIpName: {
  //       value: 'string'
  //     }
  //     requireInfrastructureEncryption: {
  //       value: bool
  //     }
  //     storageAccountName: {
  //       value: 'string'
  //     }
  //     storageAccountSkuName: {
  //       value: 'string'
  //     }
  //     vnetAddressPrefix: {
  //       value: 'string'
  //     }
    }
    publicNetworkAccess: 'Disabled'
    requiredNsgRules: 'NoAzureDatabricksRules'
  //   storageAccountIdentity: {}
  //   uiDefinitionUri: 'string'
  //   updatedBy: {}
  }
}

output workspaceId string = databricks.id
