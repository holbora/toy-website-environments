#!/bin/sh

githubOrganizationName='holbora'
githubRepositoryName='toy-website-environments'

testApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-environments-test')
testApplicationRegistrationObjectId=$(echo $testApplicationRegistrationDetails | jq -r '.id')
testApplicationRegistrationAppId=$(echo $testApplicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
  --id $testApplicationRegistrationObjectId \
  --parameters "{\"name\":\"toy-website-environments-test\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Test\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
  --id $testApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments-test-branch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"


productionApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-environments-production')
productionApplicationRegistrationObjectId=$(echo $productionApplicationRegistrationDetails | jq -r '.id')
productionApplicationRegistrationAppId=$(echo $productionApplicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
  --id $productionApplicationRegistrationObjectId \
  --parameters "{\"name\":\"toy-website-environments-production\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Production\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $productionApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments-production-branch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"


testResourceGroupResourceId=$(az group create --name ToyWebsiteTest --location westus3 --query id --output tsv)

az ad sp create --id $testApplicationRegistrationObjectId
az role assignment create \
  --assignee $testApplicationRegistrationAppId \
  --role Contributor \
  --scope $testResourceGroupResourceId


productionResourceGroupResourceId=$(az group create --name ToyWebsiteProduction --query id --output tsv)

az ad sp create --id $productionApplicationRegistrationObjectId
az role assignment create \
  --assignee $productionApplicationRegistrationAppId \
  --role Contributor \
  --scope $productionResourceGroupResourceId

echo "AZURE_CLIENT_ID_TEST: $testApplicationRegistrationAppId"
echo "AZURE_CLIENT_ID_PRODUCTION: $productionApplicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"