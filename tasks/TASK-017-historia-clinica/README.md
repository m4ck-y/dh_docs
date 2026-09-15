---
type: task
id: TASK-017
title: "Historia clínica: secciones y bindings"
status: in-progress
priority: high
created: "2026-09-15"
started: "2026-09-15"
completed: null
tags: ["clinical_history", "historia_clinica", "secciones", "ahf", "mappers"]
---

# TASK-017: Historia clínica — secciones y bindings

## Descripción

Modelar la historia clínica como formularios estructurales (secciones A-E,
`kind: CLINICAL_HISTORY`) sobre el motor de formularios, generar sus fichas de
estructura y sus vínculos a dominio (feature `mapper`).

## Objetivos

- [ ] Fichas de estructura `features/clinical_history/sections/` (A lista; B-E pendientes).
- [ ] JSON de HC en `features/questionnaires/catalog/bank/clinical_history/`.
- [ ] Vínculos pregunta → dominio (vista en `features/mapper/views/clinical_history/`).
- [ ] Mapper de AHF (sección B).
- [ ] Propuestas UI de AHF → definitivas.

## Enlaces rápidos

- [Plan de ejecución](planning/README.md)
- [Registro de progreso](progress/)
- [Artefactos](artifacts/)
- [Feature](../../features/clinical_history/README.md)
