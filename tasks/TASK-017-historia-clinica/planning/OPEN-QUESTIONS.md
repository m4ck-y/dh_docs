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

## H3 — Catálogos externos ✅ (regla aplicable por pregunta)

- **Decisión**: **no** se decide en bloque; se resuelve **por pregunta** al crear
  cada ficha/bank, mirando los **ítems del `.mmd`**: pocas/cerradas → **enum**;
  un **vocabulario** → **catálogo** (se apunta al `key`). Regla en
  [`sections/README.md`](../../../features/clinical_history/sections/README.md#enum-o-catálogo).
- **Motor y política** del catálogo (PostgreSQL/ClickHouse/Mongo; gobernado/masivo)
  los define el **registro** ([`features/catalogs/`](../../../features/catalogs/README.md));
  la ficha **solo apunta al `key`**.
- **Aplicado en**: C (4 catálogos); B/D `disease`/`disease_category` (CIE-11);
  D Vademecum; E body/estudios.
- **Al modelar cada pregunta** (no bloquea): **filtro por categoría** del `disease`
  (a) `filter` en ADR 046, (b) catálogo por categoría, (c) categoría en el ítem + UI)
  y el **"Otro"** de B/D (buscar en CIE-11 completo vs crear).

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
