# Lab Azure Hands-on
[![Python](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Azure AI/ML 서비스를 활용한 실습 랩입니다. Microsoft Foundry, RAG, Agent, Azure Machine Learning 등 다양한 주제를 Jupyter Notebook으로 다룹니다.

## 소개
이 저장소는 **Azure AI 서비스**를 실습할 수 있는 핸즈온 랩 모음입니다. 각 노트북은 독립적으로 실행할 수 있지만, 순서대로 진행하면 Azure AI 생태계를 단계별로 익힐 수 있습니다.

| 카테고리 | 설명 |
|----------|------|
| **Microsoft Foundry** | Azure OpenAI, RAG, Agent, MCP 등 Foundry 기반 실습 |
| **Agentic** | Agent Framework를 활용한 코드 어시스턴트, 메모리, 스킬 |
| **Machine Learning** | Azure ML AutoML, 파인튜닝, 파이프라인 |
| **IaC** | Bicep 기반 인프라 배포 (Foundry, AI Search, Document Intelligence) |

## 시작하기
### 필수 준비 사항
- **Python 3.12+**
- **Azure 구독** 및 [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az login` 완료)
- **Microsoft Foundry** 또는 **Azure OpenAI** 리소스 (ms-foundry, agentic 노트북용)
- **Azure Machine Learning** 워크스페이스 (machine-learning 노트북용)

### 환경 설정 방법
#### 1. Python 3.12 설치
##### 1-1. Windows에서 설치
1. [Python 공식 다운로드 페이지](https://www.python.org/downloads/windows/) 접속  
2. **Python 3.12.x** (최신 버전) 실행파일(Executable installer) 다운로드  
   예: `python-3.12.x-amd64.exe`
3. 설치 파일 실행  
   - "Add Python to PATH" 체크  
   - "Install Now" 추천  
4. 설치 확인:
   ```sh
   python --version
   ```
   또는
   ```sh
   py -V
   ```
   결과 예시: `Python 3.12.x`

##### 1-2. MacOS에서 설치
###### 방법 1: Homebrew 사용 (추천)
1. Homebrew가 없으면 [설치](https://brew.sh/)  
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Python 3.12 설치:
   ```sh
   brew install python@3.12
   ```
3. 경로 우선순위 등록:
   ```sh
   echo 'export PATH="/opt/homebrew/opt/python@3.12/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```
4. 설치 확인:
   ```sh
   python3.12 --version
   ```
   결과 예시: `Python 3.12.x`

###### 방법 2: 공식 설치 파일 사용
- [Python 공식 사이트](https://www.python.org/downloads/macos/)에서 `macOS 64-bit installer`(pkg 파일) 다운로드 후 설치  
- 터미널에서 버전 확인:
  ```sh
  python3.12 --version
  ```

> 💡 최신 pip 패키지 관리기를 사용하려면 설치 후 아래 명령 실행을 권장합니다:
> ```
> python -m pip install --upgrade pip
> ```

#### 2. 의존성 설치
각 노트북 상단에 `%pip install` 셀이 있습니다. 첫 실행 시 해당 셀을 실행해 패키지를 설치하세요.

#### 3. 환경 변수 설정
폴더별 필요한 환경변수는 `.env.example` 에 예시가 있으며, 이를 `.env` 파일로 복사한 뒤 아래와 같이 적절히 설정합니다.

```bash
# Azure OpenAI / Foundry 예시
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_CHAT_DEPLOYMENT=gpt-4o
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=text-embedding-3-small
```

## 폴더 구조
```
lab-azure-handson/
├── ms-foundry/          # Microsoft Foundry 실습 (모델, RAG, Agent)
├── agentic/             # Agent Framework 실습
├── machine-learning/    # Azure ML (AutoML, 파인튜닝, 파이프라인)
├── iac/                 # Bicep 기반 인프라 배포
└── _experiments/        # 실험용 노트북
```

> 💡 **Tip:** 각 폴더의 노트북은 번호 순서대로 진행하는 것을 권장합니다.

## 실습 및 활용 팁
- **`.env` 사용**: 시크릿 노출을 방지하고 설정 일관성을 위해 `dotenv`로 환경 변수를 로드하세요.
- **리전**: 기본 리전은 `koreacentral`이며, 필요시 `LOCATION` 환경 변수로 변경 가능합니다.
- **Python 버전**: 노트북은 Python 3.12 기준으로 작성되었습니다. 다른 버전은 패키지 호환성에 유의하세요.

## 라이선스
MIT License. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.
