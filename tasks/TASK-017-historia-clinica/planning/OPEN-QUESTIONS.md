# Preguntas abiertas — TASK-017 (Historia clínica)

> Stoppers y decisiones sin resolver que bloquean la modelación de secciones.
> Estado: 2026-09-15.

## H1 — AHF (sección B): ¿catálogo + dominio, o form con secciones?

- **Problema**: AHF es una **matriz** familiar × enfermedad (6 familiares fijos ×
  catálogo de ~60 enfermedades con CIE-11), **no** una lista plana de preguntas.
  El estado de los prototipos lo confirma (`registered[key].families`,
  `viveState[fi]`). Ver [`proposals/family_condition/`](../../../features/clinical_history/proposals/family_condition/).
- **Alternativas**:
  1. **Catálogo `disease` + entidad de dominio** (`family_condition`,
     `family_status`) — recomendado; encaja con el feature `mapper`.
  2. **Form con secciones por familiar** (6) o repetible, con 13
     `MULTIPLE_CHOICE` + "Otro" por familiar.
- **Bloquea**: ficha `sections/B_...` y su JSON en el banco.

## H2 — Grupos repetibles (sección D)

- **Problema**: D tiene **registros que el usuario agrega** (cirugías, lesiones,
  hospitalizaciones) con varios campos; el modelo no tiene repetición.
- **Alternativas**:
  - **A.** `answer.repetition` + `section.repeatable` / `question.repeatable`
    (recomendado; alinea con FHIR `item.repeats`, ADR 036).
  - **B.** Entidad `response_group` (registro explícito).
  - **C.** Workaround `array_object` (no recomendado).
- **Bloquea**: ficha `sections/D_...` y su JSON.

## H3 — Catálogos externos

- Medicamentos (Vademecum, 5.x/Y), estudios (E 22.1.1) y selector corporal
  (E 9.0). ¿Cómo se referencian? (¿feature `mapper` / `reference` / catálogo propio?).

## H4 — Anexos C/D (activación)

- Son **reglas de activación** (condición → cuestionario), **no** secciones del
  expediente. ¿Dónde viven (feature `mapper`, doc aparte)?

## Notas

- Estos pendientes no bloquean las fichas de estructura de **A** (lista), **C** y
  **E**, que pueden redactarse desde los `.mmd`.
