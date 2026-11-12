---
type: "query"
date: "2026-11-12T02:00:54.190110+00:00"
question: "What commands build and test Kouen and prepare Graphify before commit?"
contributor: "graphify"
outcome: "useful"
---

# Q: What commands build and test Kouen and prepare Graphify before commit?

## Answer

rules/build-release.md documents swift test and swift build, robot invariants before build; Scripts/graphify-commit.sh refreshes synchronously with PYTHONHASHSEED=0 and includes tracked graph artifacts in the same commit.

## Outcome

- Signal: useful