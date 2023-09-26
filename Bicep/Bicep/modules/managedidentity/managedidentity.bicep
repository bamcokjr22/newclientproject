metadata name = 'Managed Identity Module'
metadata description = 'Module used to create Managed Identity'

@description('Managed Identity Name')
param managedidentityName string
@description('Location of Managed Identity')
param location string

resource managedidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedidentityName
  location: location
}

output mangedidentityClientId string = managedidentity.properties.clientId
