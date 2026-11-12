# Programming Languages

Per-language reference, read from `rules/coding.md`. The extension glob lives in `coding.md`'s `paths:` frontmatter (that is what triggers loading).

| Ext | Static check before "done" | Notes |
|---|---|---|
| ts, tsx, js, jsx, mjs, cjs | `tsc --noEmit` (TS) | |
| py | `ruff check`, `python -m py_compile` | |
| go | `go vet` | |
| rs | `cargo check` | |
| swift | project's own build (see its Makefile/Package.swift) | |
| sh | `bash -n` | |
| java, kt, kts, cs, c, h, m, cpp, cc, cxx, hpp, hh, gd | (fill when first used) | |

Add a language: add its extension to `paths:` in `coding.md` and one row here.
