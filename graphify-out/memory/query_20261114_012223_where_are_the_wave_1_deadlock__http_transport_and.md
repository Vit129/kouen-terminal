---
type: "query"
date: "2026-11-14T01:22:23.169505+00:00"
question: "Where are the Wave 1 deadlock, HTTP transport and markdown preview paths?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["SurfaceRegistry", "SSETransport", "MarkdownPreviewView"]
---

# Q: Where are the Wave 1 deadlock, HTTP transport and markdown preview paths?

## Answer

SurfaceRegistry.handle already owns the registry lock; reuse tickFeatureWorktreeSweepLocked. SSETransport authenticates before body reads and delegates Host/Origin validation to HTTPRequestPolicy. MarkdownPreviewView sanitizes output and uses a scoped image handler.

## Outcome

- Signal: useful

## Source Nodes

- SurfaceRegistry
- SSETransport
- MarkdownPreviewView