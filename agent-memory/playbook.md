# Playbook — Problem Resolution Cases

<!-- Flat table. Search by domain or trigger keywords at session start. -->
<!-- Trigger/Fix: 120 chars max. If more detail needed → store in knowledge/ and reference path. -->
<!-- Sequential IDs: CASE-001, CASE-002, etc. -->
<!-- Applied/Prevented: increment when case is used or prevents a repeat. -->
<!-- Archive rule: when Applied+Prevented >= 5 AND no use in 30 days → move to knowledge/archive-playbook.md -->

| ID | Trigger | Fix | Domain | Outcome | Applied | Prevented |
|----|---------|-----|--------|---------|---------|-----------|
| CASE-001 | NSButton checkbox inside NSStackView inside NSScrollView not receiving clicks in Git sidebar panel | TBD — NSScrollView/FlippedView/container overlap blocks hitTest. Tried: FlippedView hitTest override, removing scroll, using NSStackView rows. None worked. Root: layout constraints cause zero-height container OR hidden historyContainer overlaps. Need to verify with `frame` logging or Xcode View Debugger. | AppKit/UI | UNRESOLVED | 0 | 0 |
