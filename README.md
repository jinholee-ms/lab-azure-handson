# Lab Azure Handson

> Azure AI/ML 서비스를 활용한 실습 랩입니다. Microsoft Foundry, RAG, Agent, Azure Machine Learning 등 다양한 주제를 Jupyter Notebook으로 다룹니다.

[![Python](https://img.shields.io/badge/Python-3.12+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 개요

이 저장소는 **Azure AI 서비스**를 실습할 수 있는 핸즈온 랩 모음입니다. 각 노트북은 독립적으로 실행 가능하나, 순서대로 진행하면 Azure AI 생태계를 단계별로 익힐 수 있습니다.

| 카테고리 | 설명 |
|----------|------|
| **Microsoft Foundry** | Azure OpenAI, RAG, Agent, MCP 등 Foundry 기반 실습 |
| **Agentic** | Agent Framework를 활용한 코드 어시스턴트, 메모리, 스킬 |
| **Machine Learning** | Azure ML AutoML, 파인튜닝, 파이프라인 |
| **IaC** | Bicep 기반 인프라 배포 (Foundry, AI Search, Document Intelligence) |

---

## 🚀 시작하기

### 사전 요구 사항

- **Python 3.12+**
- **Azure 구독** 및 [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (`az login` 완료)
- **Microsoft Foundry** 또는 **Azure OpenAI** 리소스 (ms-foundry, agentic 노트북용)
- **Azure Machine Learning** 워크스페이스 (machine-learning 노트북용)

### 환경 설정

1. **의존성 설치**  
   각 노트북 상단에 `%pip install` 셀이 있습니다. 첫 실행 시 해당 셀을 실행해주세요.

2. **환경 변수 설정**  
    폴더별 필요한 환경변수가 `.env.example` 에 있으며 `.env` 파일로 복사하여 아래처럼 적절한 변수를 설정합니다.

   ```bash
   # Azure OpenAI / Foundry
   AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
   AZURE_OPENAI_API_KEY=your-api-key
   AZURE_OPENAI_CHAT_DEPLOYMENT=gpt-4o
   AZURE_OPENAI_EMBEDDING_DEPLOYMENT=text-embedding-3-small
   ```

---

## 📁 프로젝트 구조

```
lab-azure-handson/
├── ms-foundry/          # Microsoft Foundry 실습 (모델, RAG, Agent)
├── agentic/             # Agent Framework 실습
├── machine-learning/    # Azure ML (AutoML, 파인튜닝, 파이프라인)
├── iac/                 # Bicep 기반 인프라 배포
└── _experiments/        # 실험용 노트북
```

> 💡 **Tip** 각 폴더의 노트북은 번호 순서대로 진행하는 것을 권장합니다.

---

### 공통 팁

- **`.env` 사용**: 시크릿 노출을 피하려면 `dotenv`로 환경 변수를 로드하세요. 노트북 간 일관된 설정을 유지할 수 있습니다.
- **리전**: 기본 리전은 `koreacentral`입니다. `LOCATION` 환경 변수로 변경 가능합니다.
- **Python 버전**: 노트북은 Python 3.12 기준으로 작성되었습니다. 다른 버전에서는 패키지 호환성에 주의하세요.

---

## 📄 라이선스

MIT License. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.
