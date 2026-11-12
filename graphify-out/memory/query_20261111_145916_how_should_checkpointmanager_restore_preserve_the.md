---
type: "query"
date: "2026-11-11T14:59:16.238816+00:00"
question: "How should CheckpointManager.restore preserve the user staged index?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["CheckpointManager", "restore"]
---

# Q: How should CheckpointManager.restore preserve the user staged index?

## Answer

Use git restore --source=<checkpoint> --worktree --overlay -- .; the regression test preserves git write-tree and staged paths both absent from the snapshot.

## Outcome

- Signal: useful

## Source Nodes

- CheckpointManager
- restore