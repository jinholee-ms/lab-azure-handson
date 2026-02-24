#!/usr/bin/env bash
# =============================================================================
# 리소스 그룹 삭제: USER_NAME 또는 RG_NAME으로 대상 지정
# - USER_NAME=tiger: rg-tiger-fundamental-ai-* 패턴 매칭 RG 모두 삭제
# - RG_NAME=rg-xxx: 해당 RG만 삭제
# =============================================================================

set -euo pipefail

USER_NAME="${USER_NAME:-}"
RG_NAME="${RG_NAME:-}"
YES="${YES:-}"

usage() {
  echo "Usage: $0 [options]"
  echo ""
  echo "Options (환경변수로도 지정 가능):"
  echo "  --user-name NAME   사용자 이름. rg-{name}-fundamental-ai-* 패턴 RG 삭제"
  echo "  --rg-name NAME     삭제할 리소스 그룹 이름 (직접 지정)"
  echo "  -y, --yes          확인 없이 삭제"
  echo "  -h, --help         이 도움말"
  echo ""
  echo "Example:"
  echo "  USER_NAME=tiger make delete"
  echo "  make delete USER_NAME=tiger"
  echo "  make delete RG_NAME=rg-tiger-fundamental-ai-a1b2"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --user-name)  USER_NAME="$2"; shift 2 ;;
    --rg-name)    RG_NAME="$2"; shift 2 ;;
    -y|--yes)     YES=1; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "${RG_NAME}" ]] && [[ -z "${USER_NAME}" ]]; then
  echo "ERROR: USER_NAME or RG_NAME is required."
  usage
  exit 1
fi

if [[ -n "${RG_NAME}" ]]; then
  # RG_NAME 직접 지정: 해당 RG만 삭제
  RGS=("${RG_NAME}")
else
  # USER_NAME으로 패턴 매칭 RG 조회
  USER_NAME_LOWER=$(echo "${USER_NAME}" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
  PREFIX="rg-${USER_NAME_LOWER}-fundamental-ai-"
  RGS=($(az group list --query "[?starts_with(name, '${PREFIX}')].name" -o tsv 2>/dev/null || true))
fi

# 빈 배열 또는 빈 문자열 필터
TO_DELETE=()
for rg in "${RGS[@]}"; do
  [[ -n "${rg}" ]] && TO_DELETE+=("$rg")
done

if [[ ${#TO_DELETE[@]} -eq 0 ]]; then
  echo "No matching resource group(s) found."
  exit 0
fi

RGS=("${TO_DELETE[@]}")

echo "Resource group(s) to delete:"
for rg in "${RGS[@]}"; do
  [[ -n "$rg" ]] && echo "  - $rg"
done

if [[ -z "${YES}" ]]; then
  read -p "Delete these resource group(s)? [y/N] " -n 1 -r
  echo
  if [[ ! "${REPLY}" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
  fi
fi

for rg in "${RGS[@]}"; do
  [[ -z "$rg" ]] && continue
  echo "Deleting resource group: $rg"
  az group delete --name "$rg" --yes --no-wait
done

echo "Delete requested (--no-wait). Check Azure Portal or 'az group show' for status."
