---
type: "mcp_result"
date: "2026-09-23T03:37:26.529195+00:00"
question: "SSETransport auth token isRunning"
contributor: "graphify"
outcome: "useful"
---

# Q: SSETransport auth token isRunning

## Answer

Fixed timing side-channel in SSETransport auth using constant-time SHA256 comparison and synchronized isRunning/listener state with NSLock.

## Outcome

- Signal: useful