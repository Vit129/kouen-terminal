# PLAN: Kiro Rules Restructure

> Status: PENDING
> Priority: Low (ไม่เร่ง — น้องๆใช้ repo อยู่ ต้อง coordinate)
> Created: 2026-06-21

## Problem

- `~/.kiro/AGENTS.md` = 349 lines (loaded every session ทุก project ทุกคน)
- `~/.kiro/steering/` = 141 lines (2 files, loaded every session)
- Total always-loaded = ~490 lines
- เป็น shared repo ของทีม (Azure DevOps) — แก้แล้วกระทบทุกคน
- ปัจจุบัน assume-unchanged ไว้ 4 files เพื่อไม่ให้ personal changes push

## Goal

ลด always-loaded tokens + แยก personal config ออกจาก team-shared config

## Proposed Structure

```
~/.kiro/
├── AGENTS.md              (~100 lines) — core only: trust, response format, memory protocol
├── steering/
│   ├── project-rules.md   (~50 lines)  — AIDLC routing + phase gates (ลด from 141)
│   └── karpathy.md        (keep as-is)  — coding principles
├── skills/                 (on-demand)  — AIDLC + all skills
└── personal/              (NEW, .gitignore'd)
    └── overrides.md       — Mode Lock settings, path filters, personal prefs
```

## Steps

1. **Propose to team:** present the restructure idea — smaller AGENTS.md, move routing details to AIDLC SKILL.md
2. **Split personal vs shared:** create `personal/` dir, add to `.gitignore`, move assume-unchanged configs there
3. **Slim AGENTS.md:** extract skill-map table, file index, detailed pipeline descriptions → into skills/ or on-demand reference
4. **Update hooks:** point to new paths if needed
5. **Test:** verify Kiro still routes correctly with leaner config
6. **PR:** submit to team for review

## Risks

- น้องๆอาจ depend on current structure (skill keywords, routing paths)
- Hooks reference specific paths — need to update if files move
- AIDLC SKILL.md is shared — adding routing tables there affects everyone

## Workaround (ตอนนี้)

- `assume-unchanged` บน 4 files ที่แก้ personal
- ไม่ push → ไม่กระทบ team
- เวลา pull ถ้า conflict → `git stash` → pull → re-apply
