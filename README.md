# azuer-container-app-test

Minimal example test for Azure Container Apps and Application Gateway. The Bicep configuration deploys the mcr.microsoft.com/azuredocs/aci-helloworld via the Container App Service. The service is configured to be accessable only from the VNet. For the public access an Application Gateway is deployed in the same VNet as well. However, the Application Gateway can not connect to the Service. 

Deployment: `az deployment group create --resource-group <RESOURCE GROUP> --template-file main.bicep`
