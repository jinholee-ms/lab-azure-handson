SHELL := /bin/sh
.PHONY: run-mcp-server run-mcp-server-reload test_send_json_message

UUID := $(shell uuidgen)

run-mcp-server:
	uvicorn app:app --host 0.0.0.0 --port 8000

run-mcp-server-reload:
	uvicorn app:app --host 0.0.0.0 --port 8000 --reload

# 사용법:
# make test_send_json_message AGENT_URL=http://localhost:8000 TEXT_MESSAGE="서울의 날씨를 알려줘."
test_send_json_message:
	@jq -Rn \
		--arg id  "$(UUID)" \
		--arg mid "$(UUID)" \
		--arg msg "$(TEXT_MESSAGE)" \
		'{"jsonrpc":"2.0","id":$$id,"method":"message/send","params":{"message":{"messageId":$$mid,"role":"user","parts":[{"type":"text","text":$$msg}]},"metadata":{}}}' \
	| curl -sS "$(AGENT_URL)/a2a/jsonrpc" \
		-X POST \
		-H "Content-Type: application/json" \
		-d @- \
		|| (echo "curl failed" >&2; exit 1)