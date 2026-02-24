// =============================================================================
// Microsoft Foundry + Document Intelligence + AI Search + Grounding with Bing Search
// 동물 이름 사용자용 리소스 그룹, Foundry, Document Intelligence, AI Search, Bing Grounding 및 Contributor RBAC
// =============================================================================

@description('리소스 그룹 이름')
param resourceGroupName string

@description('Azure 리전 (예: koreacentral, eastus2)')
param location string = 'koreacentral'

@description('Foundry(AI Services) 계정 이름. 소문자, 숫자, 하이픈만 허용')
param foundryName string

@description('Foundry 프로젝트 이름')
param foundryProjectName string

@description('Document Intelligence(AI Services) 계정 이름. prefix: doc-')
param docName string

@description('Azure AI Search 서비스 이름. prefix: search-, 소문자, 숫자, 하이픈, 2~60자')
@minLength(2)
@maxLength(60)
param searchServiceName string

@description('Grounding with Bing Search 리소스 이름. prefix: bing-, Foundry 연결용')
param bingName string

@description('Resource Group에 Contributor 권한을 부여할 사용자의 Object (Principal) ID. 스크립트로 생성 후 전달')
param userPrincipalId string

@description('AI Search SKU (free | basic | standard | standard2 | standard3)')
@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param searchSku string = 'standard'

// Built-in role IDs
var contributorRoleId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var azureAiUserRoleId = '53ca6127-db72-4b80-b1b0-d745d6d5456d'

// -----------------------------------------------------------------------------
// Microsoft Foundry (Cognitive Services AIServices), prefix: foundry-
// -----------------------------------------------------------------------------
resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: foundryName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    allowProjectManagement: true
    customSubDomainName: foundryName
    disableLocalAuth: false
  }
}

resource foundryProject 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  name: foundryProjectName
  parent: foundry
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

// -----------------------------------------------------------------------------
// Document Intelligence (Form Recognizer), prefix: doc-
// kind: FormRecognizer 로 Document Intelligence 전용 리소스 생성 (Foundry와 구분)
// -----------------------------------------------------------------------------
resource docIntelligence 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: docName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'FormRecognizer'
  properties: {
    customSubDomainName: docName
    disableLocalAuth: false
  }
}

// -----------------------------------------------------------------------------
// Azure AI Search, prefix: search-
// -----------------------------------------------------------------------------
resource searchService 'Microsoft.Search/searchServices@2020-08-01' = {
  name: searchServiceName
  location: location
  sku: {
    name: searchSku
  }
  properties: {
    replicaCount: 1
    partitionCount: searchSku == 'free' ? 1 : 1
    hostingMode: 'default'
  }
}

// -----------------------------------------------------------------------------
// Grounding with Bing Search (Foundry 연결용). location: global, kind: Bing.Grounding
// 사전에 az provider register --namespace 'Microsoft.Bing' 필요할 수 있음
// BCP081: Microsoft.Bing 리소스 타입 정의가 Bicep에 없어 검증 불가. 배포는 정상 동작.
// -----------------------------------------------------------------------------
@suppress('BCP081')
resource bingGrounding 'Microsoft.Bing/accounts@2020-06-10' = {
  name: bingName
  location: 'global'
  sku: {
    name: 'G1'
  }
  kind: 'Bing.Grounding'
  properties: {
    statisticsEnabled: false
  }
}

// -----------------------------------------------------------------------------
// RBAC: 해당 사용자에게 Resource Group 수준 Contributor 부여
// -----------------------------------------------------------------------------
resource rgContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userPrincipalId, contributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: userPrincipalId
    principalType: 'User'
  }
}

// -----------------------------------------------------------------------------
// RBAC: 해당 사용자에게 Resource Group 수준 Azure AI User 부여
// -----------------------------------------------------------------------------
resource rgAzureAiUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, userPrincipalId, azureAiUserRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAiUserRoleId)
    principalId: userPrincipalId
    principalType: 'User'
  }
}

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------
output foundryEndpoint string = foundry.properties.endpoint
output foundryId string = foundry.id
output foundryProjectId string = foundryProject.id
output documentIntelligenceEndpoint string = docIntelligence.properties.endpoint
output docIntelligenceId string = docIntelligence.id
output searchEndpoint string = 'https://${searchService.name}.search.windows.net'
output searchServiceName string = searchService.name
output bingGroundingId string = bingGrounding.id
output bingGroundingName string = bingGrounding.name
output resourceGroupName string = resourceGroupName
output location string = location
