// =============================================================================
// Foundry에 Grounding with Bing Search 연결 생성
// main.bicep 배포 후 Bing 리소스 키를 조회하여 실행
// =============================================================================

@description('Foundry(AI Services) 계정 이름')
param foundryName string

@description('Bing Grounding 리소스 이름')
param bingName string

@description('Bing Grounding API 키 (Azure Portal Keys and Endpoint 또는 az rest listKeys로 조회)')
@secure()
param bingApiKey string

// Foundry 계정 참조
resource foundry 'Microsoft.CognitiveServices/accounts@2025-06-01' existing = {
  name: foundryName
  scope: resourceGroup()
}

// Foundry에 Bing Grounding 연결 등록
resource bingConnection 'Microsoft.CognitiveServices/accounts/connections@2025-04-01-preview' = {
  parent: foundry
  name: '${foundryName}-bing-grounding'
  properties: {
    category: 'ApiKey'
    target: 'https://api.bing.microsoft.com/'
    authType: 'ApiKey'
    isSharedToAll: true
    credentials: {
      key: bingApiKey
    }
    metadata: {
      ApiType: 'Azure'
      Type: 'bing_grounding'
      ResourceId: resourceId('Microsoft.Bing/accounts', bingName)
    }
  }
}
