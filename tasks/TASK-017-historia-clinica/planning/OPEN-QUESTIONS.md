# Preguntas abiertas — TASK-017 (Historia clínica)

> Stoppers y decisiones sin resolver que bloquean la modelación de secciones.
> Estado: 2026-09-15.

## H1 — AHF (sección B) ✅ (arquitectura + modelo decididos)

- **Decisión** ([ADR 043](../../../decisions/043-ahf-componente-dedicado.md)):
  AHF es una **matriz** familiar × enfermedad (CIE-11) → **componente/endpoint**
  (captura tipo family-tree), **fuera** de `form`/`answer`.
- **Modelo (resuelto)**: familiar = **`people.person`**; relación =
  **`relationships.family`** (dirigida) + `partnership`; enfermedades =
  **`clinical_history.condition`**; fallecimiento = **`health_profile.death`**;
  **AHF = agregado** (sin `family_member`/`family_condition`); **"Otro" = buscador
  del CIE-11 completo**; `form.cie11_code` **no aplica**.
- **Pendiente**: (a) endpoint/vista de AHF (lectura agregada + escritura
  orquestada); (b) `clinical_history.encounter` + `encounter_diagnosis` (consultas)
  — **no bloquea** AHF.
- **Impacto**: la HC `form` cubre A, C, D, E; B queda fuera del motor (sin
  `assignment`/`answer`/progreso).

## H2 — Grupos repetibles (sección D) ✅ (cerrado)

- **Decisión**: los registros de D son **componentes de dominio 1:N**
  (`Condition`/`AllergyIntolerance`/`Procedure`/`Encounter`), **no** `answer`. La
  repetición vive en el **dominio** (filas 1:N) y el front **inyecta** el componente
  ([ADR 045](../../../decisions/045-historia-clinica-componentes-vs-formularios.md), §"Secciones
  híbridas"; H5). Por eso **no** se repite dentro del `form`.
- **Descartado**: A (`answer.repetition` + `section/question.repeatable`),
  B (`response_group`), C (`array_object`) — asumían repetir **dentro del `form`**.
- **Impacto**: el `form` de D queda **sin** los registros (solo tabaco / alcohol /
  drogas / donación).

## H3 — Catálogos externos ✅ (cerrado)

- **Regla** (aplicable **por pregunta** al crear cada ficha/bank, mirando los ítems del
  `.mmd`): pocas/cerradas → **enum**; un **vocabulario** → **catálogo** (se apunta al
  `key`). Ver [`sections/README.md`](../../../features/clinical_history/sections/README.md#enum-o-catálogo).
- **Motor y política** del catálogo (PostgreSQL/ClickHouse/Mongo; gobernado/masivo) los
  define el **registro** ([`features/catalogs/`](../../../features/catalogs/README.md));
  la ficha **solo apunta al `key`**.
- **Aplicado en**: C (4 catálogos); D Vademecum; E body/estudios.
- **`disease` / `disease_category` (CIE-11)** ✅: **no** es `list_options` de un
  formulario — lo consume el **componente** (B/D). El **filtro categoría → enfermedades**
  es **UI del componente** → [ADR 046](../../../decisions/046-opciones-pregunta.md)
  **no aplica**. El **"Otro"** de B/D es **buscador del CIE-11 completo** (no create).

## H4 — Anexos C/D (activación) ✅ (dónde viven resuelto)

- **Qué son**: **reglas de activación** (*respuesta de la HC → cuestionario
  habilitado*), **no** secciones del expediente.
- **Dónde viven** ✅: en el **`form.condition` del instrumento** que se habilita
  (mecanismo [ADR 039](../../../decisions/039-condicion-visibilidad-ast.md):
  *"el formulario se habilita si…"*). **No** van en el `mapper` ni en un doc aparte.
- **Representación y evaluación** ✅: selector **`uuid`**
  (`features/questionnaires/expressions/operands.md`) + contexto **`person`**
  ([ADR 047](../../../decisions/047-contexto-evaluacion-expresiones.md)).
- **Pendiente**: los activadores de **enfermedades/medicamentos** (D, CIE-11;
  antipsicóticos) requieren **entidades de dominio** (`condition`, `medication`) en
  el AST, que hoy solo lee `question`/`person`/`form`. Además, **crear los
  instrumentos faltantes** del banco (ZARIT-CBI, SF-12, ASQ-15, AES-S, CTH, ASRS,
  EDAH, DTS, SPIN, TAS-20, DAI-10).

## H5 — Composición de sección híbrida (D) ✅ (resuelto)

- **Problema**: D mezcla `form` (preguntas lineales: tabaco/alcohol/drogas/donación)
  y **componentes** (registros: alergias/cirugías/lesiones/transfusiones/
  hospitalizaciones). El `form` se crea **sin** los componentes.
- **Decidido** ([ADR 045](../../../decisions/045-historia-clinica-componentes-vs-formularios.md)):
  - El registro de composición vive en el **front** (definición **estática**); **no**
    se modela (ni en el `form` ni en BD).
  - El front reconoce la sección por el **`key`/`uuid` del `form`** y **ancla** cada
    componente al **`key`/`uuid` de la sección o pregunta** donde se **intercala**.
  - **No** se toca el `form`: solo se almacenan preguntas lineales (shape intacto).
- **Detalle del front** (no se modela): el orden/posición concreta de cada
  componente dentro de D.

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

- Las fichas de estructura **A–E** ya están redactadas (ver
  [`sections/README.md`](../../../features/clinical_history/sections/README.md)).
