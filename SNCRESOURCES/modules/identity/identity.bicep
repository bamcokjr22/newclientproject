param managedIdentityName string
param location string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: managedIdentityName
  location: location
}

output objectId string = managedIdentity.properties.principalId
