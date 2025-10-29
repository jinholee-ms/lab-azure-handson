from fastapi import FastAPI
from a2a.server.agent_execution import AgentExecutor, RequestContext
from a2a.server.apps import A2AFastAPIApplication
from a2a.server.events import EventQueue
from a2a.server.request_handlers.default_request_handler import DefaultRequestHandler
from a2a.server.tasks import InMemoryTaskStore
from a2a.types import AgentCard, AgentCapabilities, AgentSkill
from a2a.utils.message import new_agent_text_message
from langchain.agents import create_agent
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain_openai import AzureChatOpenAI


def create_ai_agent_app(
    model_deployment_endpoint: str,
    deployment_name: str,
    model_name: str,
    api_key: str,
    api_version: str,
    servers: dict,
) -> FastAPI:
    return A2AFastAPIApplication(
        agent_card=generate_agent_card(),
        http_handler=DefaultRequestHandler(
            agent_executor=NowExecutor(
                model_deployment_endpoint,
                deployment_name,
                model_name,
                api_key,
                api_version,
                servers,
            ),
            task_store=InMemoryTaskStore(),
        ),
    ).build(
        agent_card_url="/.well-known/agent-card.json",
        rpc_url="/a2a/jsonrpc",
    )
    
    
def generate_agent_card() -> AgentCard:
    return AgentCard(
        version="0.1.0",
        name="Now AI Agent",
        description="현재 다양한 정보를 검색하는 에이전트입니다.",
        # TODO 환경변수로 host, port 받아 처리하기
        url="http://localhost:8000/a2a/jsonrpc",
        default_input_modes=["application/json"],
        default_output_modes=["text/plain"],
        capabilities=AgentCapabilities(),
        skills=[
            AgentSkill(
                id="weather",
                name="weather",
                description="provide current weather information for a a given location",
                tags=["weather information", "current weather", "location-based"],
            )
        ],
    )


class NowExecutor(AgentExecutor):
    def __init__(
        self,
        model_deployment_endpoint: str,
        deployment_name: str,
        model_name: str,
        api_key: str,
        api_version: str,
        servers: dict,
    ) -> None:
        self._model_deployment_endpoint = model_deployment_endpoint
        self._deployment_name = deployment_name
        self._model_name = model_name
        self._api_key = api_key
        self._api_version = api_version
        self._servers = servers
        self._agent = None
        print("NowExecutor initialized:")
        print(f"  model_deployment_endpoint: {model_deployment_endpoint}"
              f"  deployment_name: {deployment_name}"
              f"  model_name: {model_name}"
              f"  api_key: {api_key}"
              f"  api_version: {api_version}"
              f"  servers: {servers}")
        
    async def execute(self, context: RequestContext, event_queue: EventQueue) -> None:
        # TODO 별로 좋지 않은 구현, __init__() 쪽으로 빼야 함
        if self._agent is None:
            self._agent = await self.create_agent()
        if len(context.message.parts) > 1:
            raise NotImplementedError("현재는 단일 메시지 파트만 지원합니다.")

        response = await self._agent.ainvoke({"messages": context.message.parts[0].root.text})
        await event_queue.enqueue_event(
            new_agent_text_message(response["messages"][-1].content, context_id=context.context_id),
        )
        
    async def cancel(self, context: RequestContext, event_queue: EventQueue) -> None:
        # 현재는 취소 기능 미지원
        pass
        
    async def create_agent(self) -> list:
        tools = []
        for name, config in self._servers.items():
            mcp = MultiServerMCPClient({name: config})
            _tools = await mcp.get_tools()
            tools.extend(_tools)

        return create_agent(
            AzureChatOpenAI(
                azure_endpoint=self._model_deployment_endpoint,
                deployment_name=self._deployment_name,
                model=self._model_name,
                openai_api_key=self._api_key,
                openai_api_version=self._api_version,
            ),
            tools,
        )
