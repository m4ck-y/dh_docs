# AGENTS — Digital Hospital (LiberSalus)

Workspace raíz de la plataforma LiberSalus / Historial Clínico Digital: frontend
(micro-frontends), backend (microservicios), docs, migrations y referencias.

Root: `~/Documents/projects/personal/systems/digital_hospital/`

## Routing

| Concern | Dónde |
|---|---|
| Frontend | `frontend/docs/` (start: `guides/project-contract.md`) |
| Backend | `backend/docs/STANDARDS.md` |
| Migrations | `migrations/README.md` |
| Reglas cross-cutting | este archivo (§ Rules) |
| Reglas estáticas | `.agents/rules/` (index: `index.json`) |
| Workflows | `.agents/workflows/` (index: `index.json`) |

Cumplir `.agents/rules/` y `.agents/workflows/` es **obligatorio**.

## Rules

- **Idioma**: inglés fuera de `docs/` (código, AGENTS, directorios técnicos);
  español dentro de `docs/` (ADRs, reportes, guías). Los archivos agent-facing
  dentro de `docs/` pueden ir en inglés.
- **Flujo de docs**: research → decisions (ADR) → tasks (`docs/tasks/_TEMPLATE/`).
- **Inicio de sesión**: leer `docs/STATUS.md` y verificar la rama
  (`git branch --show-current`) contra § Branches antes de cualquier pull/push.
- **Tono**: técnico y sin redundancia. Emojis solo como estado: 🟢 hecho ·
  🟡 parcial · 🔴 pendiente (ADR 032).
- **Diagramas**: solo Mermaid.
- **Agenda de trabajo**: miércoles y viernes (confirmar por request).

## Workspace map

```
digital_hospital/
├── docs/                 [repo] m4ck-y/dh_docs
├── docs_devops/          [repo] LiberSalus/docs_devops
├── migrations/           [repo] LiberSalus/ls_migrations
├── backend/              (contenedor · 13 repos)     → REPOS.md
├── frontend/             (contenedor · 5 repos)      → REPOS.md
│                           origin personal · remote `libersalus`
├── other_projects/       (contenedor · 4)            → REPOS.md
└── reference_projects/   (contenedor · 3)            → REPOS.md
```

## Branches

| Repo | Rama |
|---|---|
| `backend/dh_shared` | `feat/fhir` |
| `backend/template_backend_python` | `dev` |
| `other_projects/app_health_monitoring` | `dev` |
| `other_projects/app_questionnaire` | `dev` |
| `reference_projects/reference_frontend_app_legacy` | `dev-questionnaires` |
| resto | `main` |

## Referencias

| Documento | Ubicación |
|---|---|
| Contract frontend | `frontend/docs/guides/README.md` |
| Índice migrations | `migrations/README.md` |
| Reglas de extracción | `migrations/extraction-rules.md` |
| Mapa completo de remotos | `REPOSITORY.md` · receta `REPOS.md` |
