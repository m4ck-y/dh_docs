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

- **A (Registro)**: **componente/endpoint de dominio** (ADR 045) — spec en
  `sections/A_registro.md` y contrato en `mapper/views/clinical_history/A_registro.md`.
- **C (APNP)** y **E (Padecimiento actual)**: **siguiente** — redactar fichas
  desde `docs/diagrams/0_HISTORIA_CLINICA/flows/{apnp,padecimiento_actual}.mmd`.
- **B (AHF)**: **componente propio** (ADR 043), **modelado pendiente** — no es
  sección del `form`.
- **D (Antecedentes PP)**: **bloqueada** por **H2** (grupos repetibles) →
  ver [`planning/OPEN-QUESTIONS.md`](planning/OPEN-QUESTIONS.md).
- **Banco** (`features/questionnaires/catalog/bank/clinical_history/`): vacío
  (solo forms C/E/D; A y B son componentes).

## Proceso por sección

Antes de crear el JSON de una sección: **reconciliar la ficha con su `.mmd`**
(cadena de verdad `drawio → .mmd → ficha → bank JSON`; divergencias y TODO de la
fuente se anotan — ver
[`features/clinical_history/sections/README.md`](../../features/clinical_history/sections/README.md)).

## Objetivos

- [ ] Fichas de estructura `features/clinical_history/sections/` (A lista; C y E
      siguientes; B = componente propio; D pendiente por H2).
- [ ] JSON de HC en `features/questionnaires/catalog/bank/clinical_history/`.
- [ ] Vínculos pregunta → dominio (vista en `features/mapper/views/clinical_history/`).
- [ ] Modelado de AHF (componente propio): entidades + endpoint (pendiente, ADR 043).

## Enlaces rápidos

- [Plan de ejecución](planning/README.md)
- [Preguntas abiertas / stoppers](planning/OPEN-QUESTIONS.md)
- [Registro de progreso](progress/)
- [Artefactos](artifacts/)
- [Feature](../../features/clinical_history/README.md)
