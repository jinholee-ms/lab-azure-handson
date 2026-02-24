# IaC: Microsoft Foundry + Document Intelligence + AI Search

지정한 사용자 한 명을 위한 Azure 리소스 구성입니다.

- **Resource Group** 1개
- **Microsoft Foundry** (Cognitive Services AIServices) + 프로젝트 1개  
  - 동일 계정으로 **Document Intelligence** API 사용 가능 (multi-service)
- **Azure AI Search** 1개
- 해당 **사용자**에게 리소스 그룹 수준 **Contributor** 역할 부여

## 사전 요구 사항

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) 설치 및 `az login` 완료
- [Bicep CLI](https://learn.microsoft.com/azure/azure-resource-manager/bicep/install) (선택, `az deployment group create` 시 자동 사용)
- **사용자 생성 시**: Entra ID에서 사용자 생성 권한 (예: User Administrator)
- **RBAC 할당 시**: 구독 또는 해당 리소스 그룹에 대한 Owner(또는 역할 할당 권한 보유)

## 배포 방법

### 1) 스크립트로 한 번에 (사용자 생성 + 배포)

지정한 사용자 이름으로 Entra ID 사용자를 만들고, 그 사용자에게 Contributor를 부여한 뒤 리소스를 배포합니다. **USER_NAME은 필수**이며, 비어 있으면 실행되지 않습니다.

```bash
cd personal/github/lab-azure-handson/iac/001_fundamental_azure_ai
# 또는 해당 iac 하위 폴더의 scripts

# USER_NAME 필수 (미지정 시 에러)
USER_NAME=tiger make deploy
# 또는
./scripts/deploy.sh --user-name tiger

# 사용자 이름 + 테넌트 도메인 지정
./scripts/deploy.sh --user-name tiger --domain mytenant.onmicrosoft.com

# 이미 있는 사용자 Object ID로만 배포 (사용자 생성 생략, USER_NAME 불필요)
./scripts/deploy.sh --user-object-id "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

환경 변수 예시:

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `USER_NAME` | 사용자 이름 (표시 이름·UPN에 사용). 사용자 생성 시 **필수** | (없음, 미지정 시 실행 안 함) |
| `DOMAIN` | Entra ID 도메인 (UPN용) | 테넌트 기본 도메인 |
| `LOCATION` | 리전 | `koreacentral` |
| `RG_NAME` | 리소스 그룹 이름 | `rg-foundry-docs-search` |
| `FOUNDRY_NAME` | Foundry 계정 이름 | `foundry-docs-search` |
| `SEARCH_NAME` | AI Search 서비스 이름 | `srch-foundry-docs` |
| `SEARCH_SKU` | AI Search SKU | `standard` |

### 2) Bicep만 직접 배포 (사용자는 이미 있을 때)

사용자 Object ID를 알고 있을 때:

```bash
cd personal/github/lab-azure-handson/iac/001_fundamental_azure_ai

az group create --name rg-foundry-docs-search --location koreacentral

az deployment group create \
  --resource-group rg-foundry-docs-search \
  --template-file main.bicep \
  --parameters parameters.json
```

`parameters.json`에는 `userPrincipalId`에 해당 사용자의 Object ID를 넣습니다.  
Object ID 조회:

```bash
az ad user show --id "tiger@mytenant.onmicrosoft.com" --query id -o tsv
```

## 출력값 (Outputs)

배포 후 다음 값들이 출력됩니다.

- `foundryEndpoint` / `documentIntelligenceEndpoint`: Foundry·Document Intelligence 공통 엔드포인트
- `foundryId`, `foundryProjectId`: Foundry 리소스/프로젝트 ID
- `searchEndpoint`, `searchServiceName`: AI Search 엔드포인트 및 서비스 이름

Document Intelligence와 Foundry는 **같은 Cognitive Services 계정**을 쓰므로 엔드포인트와 API 키가 동일합니다.  
키는 Azure Portal → 해당 Cognitive Services 리소스 → **Keys and Endpoint**에서 확인할 수 있습니다.

## 리소스 정리

```bash
az group delete --name rg-foundry-docs-search --yes --no-wait
```

Entra ID에 생성한 사용자를 삭제하려면:

```bash
az ad user delete --id "tiger@mytenant.onmicrosoft.com"
```
