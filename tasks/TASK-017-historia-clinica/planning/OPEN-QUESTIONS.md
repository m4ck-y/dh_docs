# Preguntas abiertas — TASK-017 (Historia clínica)

> Stoppers y decisiones sin resolver que bloquean la modelación de secciones.
> Estado: 2026-09-15.

## H1 — AHF (sección B): componente/servicio dedicado ✅ (arquitectura decidida)

- **Decisión** ([ADR 043](../../../decisions/043-ahf-componente-dedicado.md)):
  AHF es una **matriz** familiar × enfermedad (~6 × ~60, CIE-11), **no** una
  lista de preguntas → **no** se modela como `form.section`. Es un
  **componente/servicio dedicado** (captura tipo family-tree) con endpoint
  propio, **fuera** de `form`/`answer`. Ver
  [`proposals/family_condition/`](../../../features/clinical_history/proposals/family_condition/).
- **Pendiente (modelado de datos)**: las entidades de dominio (`family_member`,
  `family_condition`, catálogo `disease`/`disease_category`) y su endpoint **no**
  se modelan en esta fase. Sub-decisiones abiertas: schema de destino
  (`family_history` vs `health_profile`), reuso de CIE-11 (`form.cie11_code`) y
  grano de "Otro".
- **Impacto**: la HC `form` cubre A, C, D, E; B queda fuera del motor (sin
  `assignment`/`answer`/progreso).

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

## H5 — Composición de sección híbrida (D)

- **Problema**: D mezcla `form` (preguntas planas: tabaco/alcohol/drogas/donación)
  y **componentes** (registros: alergias/cirugías/lesiones/transfusiones/
  hospitalizaciones). El `form` se crea **sin** los componentes; el front los
  **inyecta** en el orden de la sección.
- **Decidido** ([ADR 045](../../../decisions/045-historia-clinica-componentes-vs-formularios.md)):
  el front reconoce la sección híbrida **por el `key` (o `id`) del `form`** —
  registro en el front (`key → componentes + orden`), **sin** cambiar el shape del
  `form`.
- **Pendiente**: dónde vive ese **registro de composición** (constante del front /
  doc de contrato) y el **orden/posición** exacto de cada componente dentro de D.

## Gaps de la fuente (drawio)

Campos que la **fuente** no define, detectados al reconciliar la ficha A con el
`.mmd` (ver `features/clinical_history/sections/README.md`):

- **G1 — Nombre del tutor (`1.1.1`)**: ausente en el drawio/`.mmd`; se agrega en
  la ficha como **divergencia intencional** (necesario para identificar al
  tutor/responsable). Pendiente: confirmar si se actualiza el drawio/`.mmd`.
- **G2 — Grupo étnico**: el drawio trae el TODO **"FALTA PONER GRUPO ÉTNICO"**.
  No hay pregunta, opciones ni columna de dominio (`docs/db` no tiene etnia).
  Pendiente: definir vocabulario + destino (¿`people.sociocultural_identity`?).

## Notas

- Estos pendientes no bloquean las fichas de estructura de **A** (lista), **C** y
  **E**, que pueden redactarse desde los `.mmd`.
