# AI Foundry 핸즈온 가이드

이 문서는 `ai-foundry` 폴더에서 실습을 시작하기 위한 준비 단계와 환경 구성(.env), Jupyter Notebook 설치, Naver Developer API 및 Google API 키 발급 절차를 설명합니다.

## 요구사항
- Python 3.12 이상 권장
- Virtual Environment, Jupyter Notebook 설치

```bash
# Python 3.12+ 설치 여부 확인
python3 --version

# venv는 Python 3.3+ 기본 내장 모듈이므로 별도 설치 불필요
# 만약 venv 모듈이 없다면 (Ubuntu/Debian 계열)
sudo apt-get install python3-venv

# macOS (Homebrew Python 사용 시 기본 포함)
# Windows (Python 설치 시 기본 포함)
```

## 폴더 구조
- `ai-foundry/` 내부에서 실습 노트북과 스크립트를 실행합니다.

## 1) Python 가상환경 및 Notebook 설치
- 가상환경을 사용해 의존성을 격리하는 것을 권장합니다.

```bash
# git repository 클론
git clone https://github.com/jinholee-ms/lab-azure-handson.git

# ai-foundry 폴더로 이동
cd lab-azure-handson/ai-foundry

# 가상환경 생성 (예: .venv)
python3 -m venv .venv

# 가상환경 활성화 (zsh)
source .venv/bin/activate

# pip 최신화
python -m pip install --upgrade pip

# 필수 패키지 설치 (Jupyter 포함)
pip install jupyter notebook python-dotenv requests pandas numpy

# Jupyter Lab을 선호한다면
pip install jupyterlab
```

실행:
```bash
# Jupyter Notebook 실행
jupyter notebook

# 또는 JupyterLab 실행
jupyter lab
```

## 2) .env 구성
API 키와 환경변수는 루트(`ai-foundry` 폴더) 기준으로 `.env.example` 파일을 `.env` 파일로 복사하여 저장합니다.
- `AZURE_AI_FOUNDRY_PROJECT_ENDPOINT`: Azure AI Foundry 프로젝트의 엔드포인트 URL
- `AZURE_OPENAI_ENDPOINT`: Azure OpenAI 서비스의 기본 엔드포인트 URL
- `AZURE_OPENAI_API_KEY`: Azure OpenAI 서비스 인증을 위한 API 키
- `AZURE_OPENAI_CHAT_DEPLOYMENT`: 채팅/대화용 모델 배포 이름 (예: gpt-4, gpt-35-turbo)
- `AZURE_OPENAI_CHAT_BATCH_DEPLOYMENT`: 배치 처리용 채팅 모델 배포 이름
- `AZURE_OPENAI_EMBEDDING_DEPLOYMENT`: 임베딩 생성용 모델 배포 이름 (예: text-embedding-ada-002)
- `AZURE_OPENAI_API_VERSION`: Azure OpenAI API 버전 (예: 2024-02-01)
- `AZURE_OPENAI_SECONDARY_ENDPOINT`: 보조/백업 Azure OpenAI 엔드포인트 (다중 리전 구성 시)
- `AZURE_OPENAI_SECONDARY_API_KEY`: 보조 엔드포인트용 API 키
- `AZURE_OPENAI_SECONDARY_IMAGE_DEPLOYMENT`: 이미지 생성용 모델 배포 이름 (예: dall-e-3)
- `AZURE_DOCUMENTINTELLIGENCE_ENDPOINT`: Azure Document Intelligence(구 Form Recognizer) 엔드포인트 URL
- `AZURE_DOCUMENTINTELLIGENCE_API_KEY`: Document Intelligence 서비스 인증 키
- `AZURE_AI_SEARCH_ENDPOINT`: Azure AI Search(구 Cognitive Search) 서비스 엔드포인트
- `AZURE_AI_SEARCH_ADMIN_KEY`: AI Search 관리 작업용 Admin 키
- `AZURE_STORAGE_ACCOUNT_BASE_URL`: Azure Storage 계정의 기본 URL (예: https://<account>.blob.core.windows.net)
- `AZURE_STORAGE_ACCOUNT_SAS_URL`: SAS 토큰이 포함된 전체 Storage URL
- `AZURE_STORAGE_ACCOUNT_SAS_TOKEN`: Azure Storage 접근용 SAS(Shared Access Signature) 토큰
- `NAVER_CLIENT_ID`: Naver Developers API Client ID
- `NAVER_CLIENT_SECRET`: Naver Developers API Client Secret


## 3) Naver Developer API 발급 절차
Naver Developers 콘솔에서 애플리케이션을 등록하고 `Client ID` 및 `Client Secret`을 발급받습니다.

- 접속: https://developers.naver.com/
- 로그인 후 마이애플리케이션 > 애플리케이션 등록
- 사용하려는 API(예: 검색, Papago 등) 권한 선택
- 발급된 `Client ID`, `Client Secret`을 `.env`에 저장
