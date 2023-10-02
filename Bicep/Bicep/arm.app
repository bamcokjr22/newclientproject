{
	"$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"App_Services_Name": {
			"defaultValue": "",
			"type": "String"
		},
		"SubscriptionID": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "SubscriptionID"
			}
		},
		"Resource_Group_Name": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Resource_Group_Name"
			}
		},
		"App_Service_Plan_name": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "App_Service_Plan_name"
			}
		},
		"Managed_Identity": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Managed_Identity"
			}
		},
		"Netwrok_RG_Name": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Netwrok_RG_Name"
			}
		},
		"AppService_VNet": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "AppService_VNet"
			}
		},
		"AppService_SubNet": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "AppService_SubNet"
			}
		},
		"location": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Location, Currently, only East US, East US 2, and West Europe are supported."
			}
		},
		"Environment": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Environments_name"
			}
		},
		"Application": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Application_name"
			}
		},
		"Cost_Center": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Cost_Center_Number"
			}
		},
		"Data_Classification": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Data_Classification"
			}
		},
		"Portfolio_Group": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Portfolio_Group"
			}
		},
		"Project_Number": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Project_Number"
			}
		},
		"Business_Unit": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Business_Unit"
			}
		},
		"Name": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Name_Resource_Group"
			}
		},
		"DR_Tier": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "DR_Tier"
			}
		},
		"Role": {
			"type": "string",
			"defaultValue": "",
			"metadata": {
				"description": "Role"
			}
		}
	},
	"variables": {},
	"resources": [{
			"type": "Microsoft.Web/sites",
			"apiVersion": "2022-03-01",
			"name": "[parameters('App_Services_Name')]",
			"location": "East US",
			"tags": {
				"Role": "[parameters('Role')]",
				"Name": "[parameters('Name')]",
				"Application": "[parameters('Application')]",
				"Business Unit": "[parameters('Business_Unit')]",
				"Cost Center": "[parameters('Cost_Center')]",
				"Data Classification": "[parameters('Data_Classification')]",
				"DR Tier": "[parameters('DR_Tier')]",
				"Environment": "[parameters('Environment')]",
				"Portfolio Group": "[parameters('Portfolio_Group')]",
				"Project Number": "[parameters('Project_Number')]"
			},
			"kind": "app",
			"identity": {
				"type": "UserAssigned",
				"userAssignedIdentities": {
					"[concat('/subscriptions/', parameters('SubscriptionID'), '/resourceGroups/', parameters('Resource_Group_Name'), '/providers/Microsoft.ManagedIdentity/userAssignedIdentities/', parameters('Managed_Identity'))]": {}
				}
			},
			"properties": {
				"enabled": true,
				"hostNameSslStates": [{
						"name": "[concat(parameters('App_Services_Name'), '.azurewebsites.net')]",
						"sslState": "Disabled",
						"hostType": "Standard"
					},
					{
						"name": "[concat(parameters('App_Services_Name'), '.scm.azurewebsites.net')]",
						"sslState": "Disabled",
						"hostType": "Repository"
					}
				],
				"serverFarmId": "[concat('/subscriptions/', parameters('SubscriptionID'), '/resourceGroups/', parameters('Resource_Group_Name'), '/providers/Microsoft.Web/serverfarms/', parameters('App_Service_Plan_name'))]",
				"reserved": false,
				"isXenon": false,
				"hyperV": false,
				"vnetRouteAllEnabled": true,
				"vnetImagePullEnabled": false,
				"vnetContentShareEnabled": false,
				"siteConfig": {
					"numberOfWorkers": 1,
					"acrUseManagedIdentityCreds": false,
					"alwaysOn": false,
					"http20Enabled": false,
					"functionAppScaleLimit": 0,
					"minimumElasticInstanceCount": 0
				},
				"scmSiteAlsoStopped": false,
				"clientAffinityEnabled": true,
				"clientCertEnabled": false,
				"clientCertMode": "Required",
				"hostNamesDisabled": false,
				"customDomainVerificationId": "E0C25D71EAE32B0EB712C7894372F800F6A475895ADE1D9C55B3E4C461A78353",
				"containerSize": 0,
				"dailyMemoryTimeQuota": 0,
				"httpsOnly": true,
				"redundancyMode": "None",
				"storageAccountRequired": false,
				"virtualNetworkSubnetId": "[concat('/subscriptions/', parameters('SubscriptionID'), '/resourceGroups/', parameters('Netwrok_RG_Name'), '/providers/Microsoft.Network/virtualNetworks/', parameters('AppService_VNet'), '/subnets/', parameters('AppService_SubNet'))]",
				"keyVaultReferenceIdentity": "SystemAssigned"
			}
		},
		{
			"type": "Microsoft.Web/sites/basicPublishingCredentialsPolicies",
			"apiVersion": "2022-03-01",
			"name": "[concat(parameters('App_Services_Name'), '/ftp')]",
			"location": "East US",
			"dependsOn": [
				"[resourceId('Microsoft.Web/sites', parameters('App_Services_Name'))]"
			],
			"tags": {
				"Role": "[parameters('Role')]",
				"Name": "[parameters('Name')]",
				"Application": "[parameters('Application')]",
				"Business Unit": "[parameters('Business_Unit')]",
				"Cost Center": "[parameters('Cost_Center')]",
				"Data Classification": "[parameters('Data_Classification')]",
				"DR Tier": "[parameters('DR_Tier')]",
				"Environment": "[parameters('Environment')]",
				"Portfolio Group": "[parameters('Portfolio_Group')]",
				"Project Number": "[parameters('Project_Number')]"
			},
			"properties": {
				"allow": true
			}
		},
		{
			"type": "Microsoft.Web/sites/basicPublishingCredentialsPolicies",
			"apiVersion": "2022-03-01",
			"name": "[concat(parameters('App_Services_Name'), '/scm')]",
			"location": "East US",
			"dependsOn": [
				"[resourceId('Microsoft.Web/sites', parameters('App_Services_Name'))]"
			],
			"tags": {
				"Role": "[parameters('Role')]",
				"Name": "[parameters('Name')]",
				"Application": "[parameters('Application')]",
				"Business Unit": "[parameters('Business_Unit')]",
				"Cost Center": "[parameters('Cost_Center')]",
				"Data Classification": "[parameters('Data_Classification')]",
				"DR Tier": "[parameters('DR_Tier')]",
				"Environment": "[parameters('Environment')]",
				"Portfolio Group": "[parameters('Portfolio_Group')]",
				"Project Number": "[parameters('Project_Number')]"
			},
			"properties": {
				"allow": true
			}
		},
		{
			"type": "Microsoft.Web/sites/config",
			"apiVersion": "2022-03-01",
			"name": "[concat(parameters('App_Services_Name'), '/web')]",
			"location": "East US",
			"dependsOn": [
				"[resourceId('Microsoft.Web/sites', parameters('App_Services_Name'))]"
			],
			"tags": {
				"Role": "[parameters('Role')]",
				"Name": "[parameters('Name')]",
				"Application": "[parameters('Application')]",
				"Business Unit": "[parameters('Business_Unit')]",
				"Cost Center": "[parameters('Cost_Center')]",
				"Data Classification": "[parameters('Data_Classification')]",
				"DR Tier": "[parameters('DR_Tier')]",
				"Environment": "[parameters('Environment')]",
				"Portfolio Group": "[parameters('Portfolio_Group')]",
				"Project Number": "[parameters('Project_Number')]"
			},
			"properties": {
				"numberOfWorkers": 1,
				"defaultDocuments": [
					"Default.htm",
					"Default.html",
					"Default.asp",
					"index.htm",
					"index.html",
					"iisstart.htm",
					"default.aspx",
					"index.php",
					"hostingstart.html"
				],
				"netFrameworkVersion": "v4.0",
				"phpVersion": "5.6",
				"requestTracingEnabled": false,
				"remoteDebuggingEnabled": false,
				"remoteDebuggingVersion": "VS2019",
				"httpLoggingEnabled": true,
				"acrUseManagedIdentityCreds": false,
				"logsDirectorySizeLimit": 35,
				"detailedErrorLoggingEnabled": false,
				"publishingUsername": "[parameters('App_Services_Name')]",
				"scmType": "None",
				"use32BitWorkerProcess": true,
				"webSocketsEnabled": false,
				"alwaysOn": false,
				"managedPipelineMode": "Integrated",
				"virtualApplications": [{
					"virtualPath": "/",
					"physicalPath": "site\\wwwroot",
					"preloadEnabled": false
				}],
				"loadBalancing": "LeastRequests",
				"experiments": {
					"rampUpRules": []
				},
				"autoHealEnabled": false,
				"vnetName": "[concat('a5f0fbfc-c97d-40f9-9bc4-dbed13f1ba5d_', parameters('AppService_SubNet'))]",
				"vnetRouteAllEnabled": true,
				"vnetPrivatePortsCount": 0,
				"localMySqlEnabled": false,
				"xManagedServiceIdentityId": 40372,
				"ipSecurityRestrictions": [{
						"ipAddress": "146.88.224.0/23",
						"action": "Allow",
						"tag": "Default",
						"priority": 1,
						"name": "CE_NET_146",
						"description": "CE_NET_146"
					},
					{
						"ipAddress": "67.59.60.0/23",
						"action": "Allow",
						"tag": "Default",
						"priority": 2,
						"name": "67_NET",
						"description": "67_NET"
					},
					{
						"ipAddress": "149.19.42.44/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 100,
						"name": "iboss01"
					},
					{
						"ipAddress": "149.19.33.235/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 101,
						"name": "iboss02"
					},
					{
						"ipAddress": "97.64.57.108/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 102,
						"name": "iboss03"
					},
					{
						"ipAddress": "149.19.33.111/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 103,
						"name": "iboss04"
					},
					{
						"ipAddress": "163.120.81.40/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 104,
						"name": "iboss05"
					},
					{
						"ipAddress": "149.19.40.160/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 105,
						"name": "iboss06"
					},
					{
						"ipAddress": "163.120.80.34/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 106,
						"name": "iboss07"
					},
					{
						"ipAddress": "149.19.33.99/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 107,
						"name": "iboss08"
					},
					{
						"ipAddress": "149.19.41.30/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 108,
						"name": "iboss09"
					},
					{
						"ipAddress": "149.19.40.85/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 109,
						"name": "iboss10"
					},
					{
						"ipAddress": "163.120.64.39/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 110,
						"name": "iboss11"
					},
					{
						"ipAddress": "149.19.42.69/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 111,
						"name": "iboss12"
					},
					{
						"ipAddress": "163.120.64.201/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 112,
						"name": "iboss13"
					},
					{
						"ipAddress": "149.19.59.212/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 113,
						"name": "iboss14"
					},
					{
						"ipAddress": "149.19.58.245/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 114,
						"name": "iboss15"
					},
					{
						"ipAddress": "149.19.58.226/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 115,
						"name": "iboss16"
					},
					{
						"ipAddress": "149.19.43.14/32",
						"action": "Allow",
						"tag": "Default",
						"priority": 116,
						"name": "iboss17"
					},
					{
						"ipAddress": "Any",
						"action": "Deny",
						"priority": 2147483647,
						"name": "Deny all",
						"description": "Deny all access"
					}
				],
				"scmIpSecurityRestrictions": [{
					"ipAddress": "Any",
					"action": "Allow",
					"priority": 1,
					"name": "Allow all",
					"description": "Allow all access"
				}],
				"scmIpSecurityRestrictionsUseMain": true,
				"http20Enabled": false,
				"minTlsVersion": "1.2",
				"ftpsState": "AllAllowed",
				"reservedInstanceCount": 0
			}
		},
		{
			"type": "Microsoft.Web/sites/hostNameBindings",
			"apiVersion": "2022-03-01",
			"name": "[concat(parameters('App_Services_Name'), '/', parameters('App_Services_Name'), '.azurewebsites.net')]",
			"location": "East US",
			"dependsOn": [
				"[resourceId('Microsoft.Web/sites', parameters('App_Services_Name'))]"
			],
			"properties": {
				"siteName": "[parameters('App_Services_Name')]",
				"hostNameType": "Verified"
			}
		},
		{
			"type": "Microsoft.Web/sites/virtualNetworkConnections",
			"apiVersion": "2022-03-01",
			"name": "[concat(parameters('App_Services_Name'), '/a5f0fbfc-c97d-40f9-9bc4-dbed13f1ba5d_', parameters('AppService_SubNet'))]",
			"location": "East US",
			"dependsOn": [
				"[resourceId('Microsoft.Web/sites', parameters('App_Services_Name'))]"
			],
			"properties": {
				"vnetResourceId": "[concat('/subscriptions/', parameters('SubscriptionID'), '/resourceGroups/', parameters('Netwrok_RG_Name'), '/providers/Microsoft.Network/virtualNetworks/', parameters('AppService_VNet'), '/subnets/', parameters('AppService_SubNet'))]",
				"isSwift": true
			}
		}
	]
}
