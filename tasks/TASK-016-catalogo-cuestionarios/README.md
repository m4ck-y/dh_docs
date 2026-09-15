---
type: task
id: TASK-016
title: "Catálogo de cuestionarios: definición y banco JSON"
status: in-progress
priority: high
created: "2026-09-15"
started: "2026-09-15"
completed: null
tags: ["cuestionarios", "catalogo", "banco", "ast", "modelo"]
---

# TASK-016: Catálogo de cuestionarios — definición y banco JSON

## Descripción

Cerrar la definición del catálogo de cuestionarios y materializar el **banco de
instrumentos** en JSON (`features/questionnaires/catalog/bank/`), a partir de
los diagramas fuente (`docs/diagrams/`) y el modelo canónico (`schema.sql`, AST
de expresiones).

## Objetivos

- [ ] Generar `bank/instruments/*.json` (mental, social, físico) desde los `.mmd`.
- [ ] Asignar `list_categories[]` a cada instrumento (usar `bank/categories.json`).
- [ ] Resolver pendientes de modelo abiertos (`planning/pendientes.md`).
- [ ] Confirmar el schema `form` en `ALL_SCHEMAS` — C10.
- [ ] (destino) Migrar el motor frontend al AST completo — D12.
- [ ] (destino) Backend fase 2 (SQLAlchemy/repositorios) — F15.

## Enlaces rápidos

- [Pendientes detallados](planning/pendientes.md)
- [Plan de ejecución](planning/README.md)
- [Registro de progreso](progress/)
- [Artefactos](artifacts/)
- [Feature](../../features/questionnaires/README.md)
