# AGENTS General — Cross-Cutting Agent Rules

> Language exception: this file is written in **English** on purpose, following the ADR 032 precedent (`docs/decisions/032-emoji-status-indicator-policy.md`), because it carries agent-facing instructions (optimized for AI context extraction) and not stakeholder documentation. The rest of `docs/` remains Spanish-only per `docs/README.md`.

## Core Principle

Documentation serves primary AI context extraction rather than human consumption. Write to maximize context quality in minimal reads.

## Language Policy

- **English (Primary)**: All files outside the root `docs/` directory — root README, AGENTS, technical directories, and source code. Variable names, function names, docstrings, and code comments MUST be in English. Style: professional, direct, and LLM-optimized.
- **Spanish (Business and Stakeholder Context)**: All files inside the root `docs/` directory — ADRs, status reports, research findings, and user guides. Style: clear, structured, and stakeholder-oriented.
- **Exception**: agent-facing instruction files inside `docs/` (e.g. this file) may stay in English.

## Documentation Flow

Major architectural changes must follow the Research → Decision → Task sequence:

1. Document findings in `docs/research/`.
2. Record ADRs in `docs/decisions/`.
3. Execute via granular tasks in `docs/tasks/TASK-NNN/`.

Task management uses the standardized templates in `docs/tasks/_TEMPLATE/` (see `.agents/workflows/DOCS_TASK_MANAGEMENT.md`).

## Context Awareness

Baseline check of `docs/STATUS.md` is required at the beginning of each session.

## Tone

Professional, technical, and non-redundant. No emojis or decorative markdown in development documentation, with one exception:

- **Emoji Status Indicators**: Emojis convey actionable data semantics only — status mapping, coverage levels, or completion state — using 🟢 (complete/mapped/active), 🟡 (partial/in-progress), 🔴 (missing/pending/blocked). Applies only in `docs/` files where the emoji IS the data (e.g., DB mapper coverage tables, deployment status grids). See [ADR 032](decisions/032-emoji-status-indicator-policy.md).

## Diagrams

All diagrams MUST use **Mermaid** code blocks for machine readability. Images or external links for diagrams are prohibited in core documentation.

## Developer Work Schedule & Report Alignment

The developer exclusively works on **Wednesdays** and **Fridays**. When asked to audit, generate, or plan reports in `docs/reports/`, the AI agent MUST align report dates exclusively to Wednesdays and Fridays, starting chronologically from the last submitted report (fallback baseline: June 5, 2026). During the initial request or any planning phase, the agent MUST prompt the user to confirm whether the default Wednesday/Friday schedule is still in effect or a custom set of dates/workdays should be used instead.

## Related Detailed Rules

Rich static rules live in `.agents/rules/` (indexed by `.agents/rules/index.json`); actionable workflows live in `.agents/workflows/` (indexed by `.agents/workflows/index.json`). Start with:

- `.agents/rules/WRITING.md` — writing tone and language
- `.agents/rules/DOCUMENTATION_STANDARDS.md` — README and comment standards
- `.agents/rules/DOCS_PROJECT_STRUCTURE.md` — docs/ hierarchy
- `.agents/rules/MARKDOWN_METADATA_INDEXING.md` — YAML frontmatter schema
- `.agents/rules/MERMAID_ENUM_REPRESENTATION.md` — enum representation in Mermaid
- `.agents/workflows/DOCS_TASK_MANAGEMENT.md` — TASK-NNN lifecycle

Backend-specific and frontend-specific rules are documented in `backend/docs/STANDARDS.md` and `frontend/docs/` respectively.