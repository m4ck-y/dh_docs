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
- **B (AHF)**: **componente propio** (ADR 043), **modelado pendiente** — ficha
  `sections/B_ahf.md`; no es sección del `form`.
- **C (APNP)**: **form** — ficha `sections/C_apnp.md` + banco
  `bank/clinical_history/apnp.json`.
- **D (Antecedentes PP)**: **híbrido** (form + componentes) — ficha
  `sections/D_antecedentes_pp.md` + banco `bank/clinical_history/antecedentes_pp.json`
  (solo el `form`); **H2 cerrado** (registros = componentes 1:N).
- **E (Padecimiento actual)**: **form** — ficha `sections/E_padecimiento_actual.md`;
  banco ⏳.
- **Banco** (`features/questionnaires/catalog/bank/clinical_history/`): `apnp.json`,
  `antecedentes_pp.json` (A y B son componentes, sin banco).
- **Pendiente**: modelado de los componentes (A/B/D) y banco de E — ver
  [`planning/OPEN-QUESTIONS.md`](planning/OPEN-QUESTIONS.md) (H1, H4, H5).

## Proceso por sección

Antes de crear el JSON de una sección: **reconciliar la ficha con su `.mmd`**
(cadena de verdad `drawio → .mmd → ficha → bank JSON`; divergencias y TODO de la
fuente se anotan — ver
[`features/clinical_history/sections/README.md`](../../features/clinical_history/sections/README.md)).

## Objetivos

- [x] Fichas de estructura `features/clinical_history/sections/` (A–E).
- [x] JSON de los `form` de HC: `apnp.json` (C), `antecedentes_pp.json` (D).
- [ ] JSON del `form` de E (`padecimiento_actual.json`).
- [ ] Vínculos pregunta → dominio (vista en `features/mapper/views/clinical_history/`).
- [ ] Modelado de los componentes (A, B, D): entidades + endpoints (ADR 043/045).

## Enlaces rápidos

- [Plan de ejecución](planning/README.md)
- [Preguntas abiertas / stoppers](planning/OPEN-QUESTIONS.md)
- [Registro de progreso](progress/)
- [Artefactos](artifacts/)
- [Feature](../../features/clinical_history/README.md)
