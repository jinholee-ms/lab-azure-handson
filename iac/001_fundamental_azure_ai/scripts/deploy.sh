#!/usr/bin/env bash
# =============================================================================
# 배포 스크립트: Entra ID 사용자 생성 → RG 생성 → Bicep 배포
# - 사용자 생성에는 Azure AD 권한(예: User Administrator) 필요
# - RBAC 할당에는 구독/리소스 그룹 Owner 필요
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IAC_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# 기본값 (USER_NAME은 사용자 생성 시 필수)
USER_NAME="${USER_NAME:-}"
DOMAIN="${DOMAIN:-}"
LOCATION="${LOCATION:-koreacentral}"
# 아래 리소스 이름은 USER_NAME 있으면 rg-{user}-fundamental-ai-{4자리}, foundry-{user}-{4자리} 등으로 자동 설정됨
RG_NAME="${RG_NAME:-}"
FOUNDRY_NAME="${FOUNDRY_NAME:-}"
FOUNDRY_PROJECT="${FOUNDRY_PROJECT:-}"
DOC_NAME="${DOC_NAME:-}"
SEARCH_NAME="${SEARCH_NAME:-}"
BING_NAME="${BING_NAME:-}"
SEARCH_SKU="${SEARCH_SKU:-standard}"
USE_EXISTING_USER="${USE_EXISTING_USER:-}"
USER_OBJECT_ID="${USER_OBJECT_ID:-}"

usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options (환경변수로도 지정 가능):"
  echo "  --user-name NAME       사용자 이름 (필수, 사용자 생성 시). 표시 이름 및 UPN에 사용"
  echo "  --domain DOMAIN        테넌트 도메인 (예: contoso.onmicrosoft.com). 생략 시 az account show 로 조회"
  echo "  --user-object-id ID    이미 있는 사용자 Object ID 지정 시 사용자 생성 생략"
  echo "  --location LOC         리전 (기본: koreacentral)"
  echo "  --rg-name NAME         리소스 그룹 이름 (미지정 시 USER_NAME 기반 자동 생성)"
  echo "  --foundry-name NAME    Foundry 계정 이름"
  echo "  --doc-name NAME        Document Intelligence 계정 이름"
  echo "  --search-name NAME     AI Search 서비스 이름"
  echo "  --bing-name NAME       Grounding with Bing Search 리소스 이름"
  echo "  --search-sku SKU       AI Search SKU (free|basic|standard)"
  echo "  -h, --help             이 도움말"
  echo ""
  echo "Example:"
  echo "  USER_NAME=tiger ./deploy.sh"
  echo "  ./deploy.sh --user-name tiger --domain mytenant.onmicrosoft.com"
  echo "  ./deploy.sh --user-object-id 12345678-1234-1234-1234-123456789012"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --user-name)      USER_NAME="$2"; shift 2 ;;
    --domain)         DOMAIN="$2"; shift 2 ;;
    --user-object-id) USER_OBJECT_ID="$2"; USE_EXISTING_USER=1; shift 2 ;;
    --location)       LOCATION="$2"; shift 2 ;;
    --rg-name)        RG_NAME="$2"; shift 2 ;;
    --foundry-name)   FOUNDRY_NAME="$2"; shift 2 ;;
    --doc-name)       DOC_NAME="$2"; shift 2 ;;
    --search-name)    SEARCH_NAME="$2"; shift 2 ;;
    --bing-name)      BING_NAME="$2"; shift 2 ;;
    --search-sku)     SEARCH_SKU="$2"; shift 2 ;;
    -h|--help)        usage; exit 0 ;;
    *)                echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# 사용자 생성 경로일 때 USER_NAME 필수 (USER_OBJECT_ID 없으면 새 사용자 생성)
if [[ -z "${USER_OBJECT_ID}" ]]; then
  if [[ -z "${USER_NAME}" ]] || [[ "${USER_NAME}" =~ ^[[:space:]]*$ ]]; then
    echo "ERROR: USER_NAME is required when creating a new user. Set USER_NAME or use --user-name."
    echo "       Or use --user-object-id to deploy for an existing user without creating one."
    usage
    exit 1
  fi
fi

# 리소스 이름 자동 생성: rg-{user_name}-fundamental-ai-{4자리}, foundry-*, doc-*, search-*
# (USER_NAME 없으면 deploy-existing-user 경로; 기본 접미사만 사용)
SHORT_UUID=$(openssl rand -hex 2)
if [[ -n "${USER_NAME}" ]] && [[ "${USER_NAME}" =~ [^[:space:]] ]]; then
  USER_NAME_LOWER=$(echo "${USER_NAME}" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
  [[ -z "${RG_NAME}" ]] && RG_NAME="rg-${USER_NAME_LOWER}-fundamental-ai-${SHORT_UUID}"
  [[ -z "${FOUNDRY_NAME}" ]] && FOUNDRY_NAME="foundry-${USER_NAME_LOWER}-${SHORT_UUID}"
  [[ -z "${FOUNDRY_PROJECT}" ]] && FOUNDRY_PROJECT="foundry-${USER_NAME_LOWER}-${SHORT_UUID}-proj"
  [[ -z "${DOC_NAME}" ]] && DOC_NAME="doc-${USER_NAME_LOWER}-${SHORT_UUID}"
  [[ -z "${SEARCH_NAME}" ]] && SEARCH_NAME="search-${USER_NAME_LOWER}-${SHORT_UUID}"
  [[ -z "${BING_NAME}" ]] && BING_NAME="bing-${USER_NAME_LOWER}-${SHORT_UUID}"
else
  [[ -z "${RG_NAME}" ]] && RG_NAME="rg-fundamental-ai-${SHORT_UUID}"
  [[ -z "${FOUNDRY_NAME}" ]] && FOUNDRY_NAME="foundry-fundamental-ai-${SHORT_UUID}"
  [[ -z "${FOUNDRY_PROJECT}" ]] && FOUNDRY_PROJECT="foundry-fundamental-ai-${SHORT_UUID}-proj"
  [[ -z "${DOC_NAME}" ]] && DOC_NAME="doc-fundamental-ai-${SHORT_UUID}"
  [[ -z "${SEARCH_NAME}" ]] && SEARCH_NAME="search-fundamental-ai-${SHORT_UUID}"
  [[ -z "${BING_NAME}" ]] && BING_NAME="bing-fundamental-ai-${SHORT_UUID}"
fi

# 도메인 미지정 시 테넌트 기본 도메인 조회 (filter 없이 목록 조회 후 기본 도메인 선택)
if [[ -z "${DOMAIN}" ]]; then
  echo "DOMAIN not set. Resolving tenant default domain..."
  DOMAIN=$(az rest --method get --url "https://graph.microsoft.com/v1.0/domains" --query 'value[?isDefault==`true`].id | [0]' -o tsv)
  if [[ -z "${DOMAIN}" ]]; then
    # isDefault 필드가 없거나 다른 형식인 경우 첫 번째 도메인 사용
    DOMAIN=$(az rest --method get --url "https://graph.microsoft.com/v1.0/domains" --query "value[0].id" -o tsv)
  fi
  if [[ -z "${DOMAIN}" ]]; then
    echo "ERROR: Could not get tenant domain. Set DOMAIN (e.g. contoso.onmicrosoft.com)."
    exit 1
  fi
  echo "Using domain: ${DOMAIN}"
fi

# 사용자 Principal ID 결정: 기존 ID 사용 또는 새 사용자 생성
if [[ -n "${USER_OBJECT_ID}" ]]; then
  echo "Using existing user Object ID: ${USER_OBJECT_ID}"
  PRINCIPAL_ID="${USER_OBJECT_ID}"
else
  # USER_NAME으로 UPN 생성 (소문자, 공백 제거)
  UPN_NAME=$(echo "${USER_NAME}" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
  UPN="${UPN_NAME}@${DOMAIN}"
  DISPLAY_NAME="User ${USER_NAME}"

  echo "Creating Entra ID user: ${DISPLAY_NAME} (${UPN})"
  if az ad user show --id "${UPN}" &>/dev/null; then
    echo "User already exists: ${UPN}"
    PRINCIPAL_ID=$(az ad user show --id "${UPN}" --query id -o tsv)
  else
    # 초기 비밀번호 (최초 로그인 시 변경 권장). 실제 운영에서는 보안 정책에 맞게 설정.
    TEMP_PASSWORD="@Zoo12345"
    az ad user create \
      --display-name "${DISPLAY_NAME}" \
      --user-principal-name "${UPN}" \
      --password "${TEMP_PASSWORD}" \
      --force-change-password-next-sign-in true
    PRINCIPAL_ID=$(az ad user show --id "${UPN}" --query id -o tsv)
    echo "Created user. Object ID: ${PRINCIPAL_ID}"
    echo "Temporary password was set; user must change on first sign-in."
  fi
fi

echo "Resource Group: ${RG_NAME}, Location: ${LOCATION}"
az group create --name "${RG_NAME}" --location "${LOCATION}" --output none

# Microsoft.Bing 리소스 프로바이더 등록 (이미 등록된 경우 무시)
echo "Ensuring Microsoft.Bing provider is registered..."
az provider register --namespace 'Microsoft.Bing' --wait 2>/dev/null || true

DEPLOYMENT_NAME="foundry-docs-search-$(date +%Y%m%d-%H%M%S)"
echo "Deploying Bicep (Foundry + Document Intelligence + AI Search + Bing Grounding + RBAC)..."
az deployment group create \
  --name "${DEPLOYMENT_NAME}" \
  --resource-group "${RG_NAME}" \
  --template-file "${IAC_ROOT}/main.bicep" \
  --parameters \
    resourceGroupName="${RG_NAME}" \
    location="${LOCATION}" \
    foundryName="${FOUNDRY_NAME}" \
    foundryProjectName="${FOUNDRY_PROJECT}" \
    docName="${DOC_NAME}" \
    searchServiceName="${SEARCH_NAME}" \
    bingName="${BING_NAME}" \
    searchSku="${SEARCH_SKU}" \
    userPrincipalId="${PRINCIPAL_ID}" \
  --output table

# Bing Grounding API 키 조회 후 Foundry 연결 생성
echo "Creating Foundry connection for Grounding with Bing Search..."
SUB_ID=$(az account show --query id -o tsv)
BING_KEY=$(az rest --method post \
  --url "https://management.azure.com/subscriptions/${SUB_ID}/resourceGroups/${RG_NAME}/providers/Microsoft.Bing/accounts/${BING_NAME}/listKeys?api-version=2020-06-10" \
  --query "primaryKey || key1" -o tsv 2>/dev/null)

if [[ -n "${BING_KEY}" ]]; then
  CONN_DEPLOY="bing-connection-$(date +%Y%m%d-%H%M%S)"
  az deployment group create \
    --name "${CONN_DEPLOY}" \
    --resource-group "${RG_NAME}" \
    --template-file "${IAC_ROOT}/connection-bing-grounding.bicep" \
    --parameters \
      foundryName="${FOUNDRY_NAME}" \
      bingName="${BING_NAME}" \
      bingApiKey="${BING_KEY}" \
    --output table
  echo "Bing Grounding connection created successfully."
else
  echo "WARNING: Could not retrieve Bing API key. Create the connection manually:"
  echo "  1. Get key from Azure Portal: ${BING_NAME} -> Keys and Endpoint"
  echo "  2. Run: az deployment group create --resource-group ${RG_NAME} --template-file ${IAC_ROOT}/connection-bing-grounding.bicep --parameters foundryName=${FOUNDRY_NAME} bingName=${BING_NAME} bingApiKey=<YOUR_KEY>"
fi

echo "Done. Outputs:"
az deployment group show \
  --resource-group "${RG_NAME}" \
  --name "${DEPLOYMENT_NAME}" \
  --query properties.outputs \
  -o json 2>/dev/null || true
