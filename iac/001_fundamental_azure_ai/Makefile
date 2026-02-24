# =============================================================================
# IaC: Microsoft Foundry + Document Intelligence + AI Search + Grounding with Bing Search
# 사용: make deploy USER_NAME=tiger  |  make deploy-existing-user USER_OBJECT_ID=...  |  make delete USER_NAME=tiger
# =============================================================================

SHELL := /bin/bash
SCRIPT := scripts/deploy.sh
DELETE_SCRIPT := scripts/delete.sh

# 배포 옵션 (make VAR=value 로 덮어쓸 수 있음). USER_NAME 있으면 리소스명 자동: rg-{user}-fundamental-ai-{4자리}, foundry-*, doc-*, search-*, bing-*
USER_NAME       ?=
DOMAIN          ?=
LOCATION        ?= koreacentral
RG_NAME         ?=
FOUNDRY_NAME    ?=
FOUNDRY_PROJECT ?=
DOC_NAME        ?=
SEARCH_NAME     ?=
BING_NAME       ?=
SEARCH_SKU      ?= standard
USER_OBJECT_ID  ?=
YES             ?=

.PHONY: deploy deploy-existing-user delete help

# 사용자 생성 + Bicep 배포 (USER_NAME 필수. 기존 사용자만 쓸 때는 deploy-existing-user 사용)
deploy:
	chmod +x $(SCRIPT)
	USER_NAME='$(USER_NAME)' \
	DOMAIN='$(DOMAIN)' \
	LOCATION='$(LOCATION)' \
	RG_NAME='$(RG_NAME)' \
	FOUNDRY_NAME='$(FOUNDRY_NAME)' \
	FOUNDRY_PROJECT='$(FOUNDRY_PROJECT)' \
	DOC_NAME='$(DOC_NAME)' \
	SEARCH_NAME='$(SEARCH_NAME)' \
	BING_NAME='$(BING_NAME)' \
	SEARCH_SKU='$(SEARCH_SKU)' \
	USER_OBJECT_ID='$(USER_OBJECT_ID)' \
	$(SCRIPT)

# 기존 사용자 Object ID로만 배포 (사용자 생성 생략, USER_NAME 불필요)
# 사용: make deploy-existing-user USER_OBJECT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
deploy-existing-user:
	@if [ -z '$(USER_OBJECT_ID)' ]; then \
		echo 'Usage: make deploy-existing-user USER_OBJECT_ID=<object-id>'; exit 1; fi
	$(MAKE) deploy USER_OBJECT_ID='$(USER_OBJECT_ID)' USER_NAME=''

# 리소스 그룹 삭제. USER_NAME 또는 RG_NAME 지정
# 사용: make delete USER_NAME=tiger  또는  make delete RG_NAME=rg-tiger-fundamental-ai-a1b2
# 확인 없이 삭제: make delete USER_NAME=tiger YES=1
delete:
	chmod +x $(DELETE_SCRIPT)
	USER_NAME='$(USER_NAME)' RG_NAME='$(RG_NAME)' YES='$(YES)' $(DELETE_SCRIPT)

# 스크립트 도움말
help:
	chmod +x $(SCRIPT) 2>/dev/null || true
	$(SCRIPT) --help
