# MS Foundry Hands-on Lab

Azure AI 서비스를 활용한 실습 자료입니다. Azure OpenAI, AI Search, Document Intelligence, Agent Framework 등을 다룹니다.

## Prerequisites

- Python 3.12
- Azure 구독 및 리소스
  - Azure OpenAI
  - Azure AI Search
  - Azure Document Intelligence
  - Azure AI Foundry Project

## 환경 설정

1. `.env.example`을 `.env`로 복사하고 필요한 값을 설정합니다.

```bash
cp .env.example .env
```

2. `.env` 파일에 아래 항목들을 설정합니다.

| 환경 변수 | 설명 | 참고 이미지 |
|----------|------|------------|
| `AZURE_MS_FOUNDRY_PROJECT_ENDPOINT` | Azure AI Foundry 프로젝트 엔드포인트 | [envs-project.png](./assets/envs-project.png) |
| `AZURE_MS_FOUNDRY_API_KEY` | Azure AI Foundry API 키 | [envs-project.png](./assets/envs-project.png) |
| `AZURE_OPENAI_ENDPOINT` | Azure OpenAI 엔드포인트 | [envs-openai-001.png](./assets/envs-openai-001.png) |
| `AZURE_OPENAI_API_KEY` | Azure OpenAI API 키 | [envs-openai-002.png](./assets/envs-openai-002.png) |
| `AZURE_OPENAI_CHAT_DEPLOYMENT` | Chat 모델 배포 이름 | [envs-openai-003.png](./assets/envs-openai-003.png) |
| `AZURE_OPENAI_EMBEDDING_DEPLOYMENT` | Embedding 모델 배포 이름 | [envs-openai-003.png](./assets/envs-openai-003.png) |
| `AZURE_AI_SEARCH_ENDPOINT` | Azure AI Search 엔드포인트 | [envs-ai-search-001.png](./assets/envs-ai-search-001.png) |
| `AZURE_AI_SEARCH_ADMIN_KEY` | Azure AI Search Admin 키 | [envs-ai-search-002.png](./assets/envs-ai-search-002.png) |
| `AZURE_DOCUMENTINTELLIGENCE_ENDPOINT` | Document Intelligence 엔드포인트 | [envs-doc-intel-001.png](./assets/envs-doc-intel-001.png) |
| `AZURE_DOCUMENTINTELLIGENCE_API_KEY` | Document Intelligence API 키 | [envs-doc-intel-001.png](./assets/envs-doc-intel-001.png) |

## 실습 목차

### 1. Model - OpenAI 모델 활용

| 파일 | 내용 |
|------|------|
| [001-model-001-basic.ipynb](./001-model-001-basic.ipynb) | OpenAI Chat Completions API 기본 사용법 |
| [001-model-002-gpt5-optimization.ipynb](./001-model-002-gpt5-optimization.ipynb) | GPT-5 파라미터 최적화 (Verbosity 등) |
| [001-model-003-token-optimization.ipynb](./001-model-003-token-optimization.ipynb) | 토큰 최적화 (Input Token Caching) |
| [001-model-004-mcp.ipynb](./001-model-004-mcp.ipynb) | MCP (Model Context Protocol) 통신 규격 |

### 2. RAG - 검색 증강 생성

| 파일 | 내용 |
|------|------|
| [002-rag-001-ai-search-basic.ipynb](./002-rag-001-ai-search-basic.ipynb) | Azure AI Search 기본 사용법 |
| [002-rag-002-ai-search-with-enrichment.ipynb](./002-rag-002-ai-search-with-enrichment.ipynb) | Document Intelligence를 활용한 AI Enrichment |
| [002-rag-003-graphrag.ipynb](./002-rag-003-graphrag.ipynb) | GraphRAG 구현 |

### 3. Agent - AI 에이전트 개발

| 파일 | 내용 |
|------|------|
| [003-agent-001-basic.ipynb](./003-agent-001-basic.ipynb) | Microsoft Agent Framework 기본 사용법 |
| [003-agent-002-workflow.ipynb](./003-agent-002-workflow.ipynb) | Workflow 기반 에이전트 구성 (DAG) |

## 폴더 구조

```
ms-foundry/
├── 001-model-*.ipynb        # Model 관련 노트북
├── 002-rag-*.ipynb          # RAG 관련 노트북
├── 003-agent-*.ipynb        # Agent 관련 노트북
├── assets/                  # 환경 설정 스크린샷
├── graphrag/                # GraphRAG 데이터
├── resources/               # 샘플 데이터
│   ├── batch_inputs.jsonl
│   ├── KB주택시장리뷰_2025년 10월호.pdf
│   ├── KR_Merchants_Sample.csv
│   └── 대한민국 헌법.pdf
├── .env.example             # 환경 변수 예시
├── settings.yaml            # GraphRAG 설정
└── README.md
```

## 주요 패키지

```bash
# Model
pip install openai azure-ai-projects azure-identity

# RAG
pip install azure-search-documents azure-ai-documentintelligence langchain langchain-openai graphrag

# Agent
pip install agent-framework

# MCP
pip install mcp
```

> 각 노트북의 첫 번째 셀에서 필요한 패키지를 자동으로 설치합니다.

## 참고 자료

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [Azure AI Search Documentation](https://learn.microsoft.com/azure/search/)
- [Azure Document Intelligence Documentation](https://learn.microsoft.com/azure/ai-services/document-intelligence/)
- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-studio/)
