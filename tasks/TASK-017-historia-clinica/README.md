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
`type: CLINICAL_HISTORY`) **reutilizando el contrato `form` definido en
[TASK-016](../TASK-016-catalogo-cuestionarios/README.md)** (mismo shape).
Fuente: `docs/diagrams/0_HISTORIA_CLINICA` (el form `0`; va **después** de los
cuestionarios `1,2,3`). Genera sus fichas de estructura y sus vínculos a dominio
(feature `mapper`).

## Estado y siguiente paso

- **A (Registro)**: ficha (`sections/A_registro.md`) y mapper listos.
- **C (APNP)** y **E (Padecimiento actual)**: **siguiente** — redactar fichas
  desde `docs/diagrams/0_HISTORIA_CLINICA/flows/{apnp,padecimiento_actual}.mmd`.
- **B (AHF)** y **D (Antecedentes PP)**: **bloqueadas** por decisiones abiertas
  → ver [`planning/OPEN-QUESTIONS.md`](planning/OPEN-QUESTIONS.md) (H1, H2).
- **Banco** (`features/questionnaires/catalog/bank/clinical_history/`): vacío
  (espera a cerrar B/D).

## Objetivos

- [ ] Fichas de estructura `features/clinical_history/sections/` (A lista; B-E pendientes).
- [ ] JSON de HC en `features/questionnaires/catalog/bank/clinical_history/`.
- [ ] Vínculos pregunta → dominio (vista en `features/mapper/views/clinical_history/`).
- [ ] Mapper de AHF (sección B).
- [ ] Propuestas UI de AHF → definitivas.

## Enlaces rápidos

- [Plan de ejecución](planning/README.md)
- [Preguntas abiertas / stoppers](planning/OPEN-QUESTIONS.md)
- [Registro de progreso](progress/)
- [Artefactos](artifacts/)
- [Feature](../../features/clinical_history/README.md)
