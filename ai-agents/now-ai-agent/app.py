from dotenv import load_dotenv
import os
import agent


load_dotenv(override=True)


app = agent.create_ai_agent_app(
    os.getenv("AZURE_OPENAI_ENDPOINT"),
    os.getenv("AZURE_OPENAI_CHAT_DEPLOYMENT"),
    os.getenv("AZURE_OPENAI_CHAT_MODEL"),
    os.getenv("AZURE_OPENAI_API_KEY"),
    os.getenv("AZURE_OPENAI_API_VERSION"),
    {
        "mcp-weather": {
            "url": os.getenv("MCP_WEATHER_URL") + "/sse",
            "transport": "sse",
        }
    },
)


@app.get("/")
def root():
    return {"ok": True}