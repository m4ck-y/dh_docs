# PENDIENTES (índice global)

> **Índice único** de trabajo diferido y decisiones abiertas, por área. **No**
> duplica el detalle: **enlaza** a la fuente de cada pendiente (formato
> *dónde vive + de dónde sale*, reanudable).
>
> **Estado:** 2026-09-18 · Fase **DEFINICIÓN** (solo `docs/`; `frontend/` y
> `backend/` congelados).

## Tareas (global)
- [`tasks/backlog.md`](./tasks/backlog.md) — estado de tareas `TASK-NNN`.

## Cuestionarios — TASK-016
- **Detalle**: [`tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md`](./tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md)
  (abiertos: **A4, C10, C15, C21, D12, F15**).
- **C21** — opciones con **`uuid`** (formato `{uuid, value, label, …}` + API sub-recurso
  `PATCH /questions/options/{uuid_option}`): los **bancos se revisan todos**.
- Puntero: [`TODO/cuestionarios.md`](./TODO/cuestionarios.md).

## Historia clínica — TASK-017
- **Decisiones abiertas (stoppers)**: [`tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md`](./tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md)
  → **G1** (nombre del tutor → drawio), **G2** (grupo étnico), **H1** (resto:
  `encounter`), **H4** (resto: entidades de dominio + instrumentos).
- **Bloqueos / anexos**: [`features/clinical_history/README.md`](./features/clinical_history/README.md).

### AST / expresiones
- ⏳ **Entidades de dominio en el AST** (`condition`, `medication`) para los
  activadores de enfermedades/medicamentos → ver **H4**.
- ✅ Hechos: selector `uuid`; `question.id`/`key`/`uuid` globales; cardinalidad 1:N;
  contexto `person` ([ADR 047](./decisions/047-contexto-evaluacion-expresiones.md)).

### Activadores (anexos C/D)
- ⏳ Agregar **`form.condition`** a los instrumentos (depende de las entidades de
  dominio del AST).
- ⏳ **Crear los instrumentos faltantes** del banco (ZARIT-CBI, SF-12, ASQ-15,
  AES-S, CTH, ASRS-V1.1, EDAH, DTS, SPIN, TAS-20, DAI-10).
- ⏳ **Validar la reconciliación** de los anexos (nomenclatura "Formulario A/B/C")
  → [`features/clinical_history/README.md`](./features/clinical_history/README.md) (§Anexos C/D).
- ⏳ **4 condiciones agregadas temporalmente** a la categoría **D `2.4`**
  (estrés→PSS, TEPT→DTS, fobia social→SPIN, alexitimia→TAS-20) — **validar** con la
  fuente → [`features/clinical_history/README.md`](./features/clinical_history/README.md) (§Gaps).

### Banco y modelado
- ⏳ **E** sin banco: `features/questionnaires/catalog/bank/clinical_history/padecimiento_actual.json`.
- ⏳ **Componentes A/B/D** — **contrato `componente → dominio`** (qué entidades/columnas
  lee/escribe el endpoint): ✅ medicación definida en [`contracts/medication_statement.md`](./features/clinical_history/contracts/medication_statement.md);
  resto (alergias, cirugías, AHF) **pendiente**. **No** pasan por el
  mapper → [`features/clinical_history/sections/README.md`](./features/clinical_history/sections/README.md).
- ⏳ **`clinical_history.encounter`** + **`encounter_diagnosis`** — pendiente de
  diseño → [`db/postgres/clinical_history/README.md`](./db/postgres/clinical_history/README.md).

## Mapper — TASK-018
- **Task**: [`tasks/TASK-018-mapper-dominio/README.md`](./tasks/TASK-018-mapper-dominio/README.md) — status **backlog**.
- **Feature**: [`features/mapper/`](./features/mapper/) — contrato ([`README.md`](./features/mapper/README.md)), reglas ([`RULES.md`](./features/mapper/RULES.md)), casos de uso ([`uses_cases/`](./features/mapper/uses_cases/)).
- **Store**: **`dh_bindings` / `bindings`** (Mongo) — seed [`store/seeder.js`](./features/mapper/store/seeder.js).
- **Alcance**: **solo preguntas de `form`** (prefill `read` + write-through `write`).
  Los **componentes (A/B/D)** **no** pasan por el mapper.
- ⏳ Contrato + store + read/write + **UI administrativa** por desarrollar.

## Catálogos
- ⏳ **`medication`** (Vademecum): definir **fuente/sync** y **columnas finales**
  (hoy es **propuesta**) → [`features/catalogs/clickhouse/medication.md`](./features/catalogs/clickhouse/medication.md).
- ⏳ **`medication`**: decidir si se **conserva `atc`** o es **redundante** cuando
  `code_system = "ATC"`.
- ⏳ **Seeds/registro** de `fuel_type`, `animal_type`, `work_shift`
  → [`features/catalogs/seed/README.md`](./features/catalogs/seed/README.md).
- ⏳ **Registrar** los catálogos externos (`disease`, `study`, `body_site`, `allergen`, `drug`).
- ⏳ **`cie11` completo** (masivo) — diferido.

## Base de datos
- ⏳ Esquemas **sin adoptar** → [`db/postgres/todo/propuesta_schemes_2.md`](./db/postgres/todo/propuesta_schemes_2.md).
- ⏳ **`catalog`** (Postgres) — schema pendiente de modelar.
- ⏳ **ClickHouse / Mongo** sin diseñar (salvo `catalogs/`).
- ⏳ **`relationships`**: pendientes del README — `friendship`/`follow` (diferidas),
  `power_of_attorney`, `insurance_links` → [`db/postgres/relationships/README.md`](./db/postgres/relationships/README.md).
- ⏳ **`health_profile`**: catálogos futuros (`allergy_severity`,
  `allergy_reaction_type`, `vaccine_catalog`) → [`db/postgres/health_profile/README.md`](./db/postgres/health_profile/README.md).

## Dudas de modelo sin cerrar
- ⏳ **D `10.0` lesiones**: `Condition` vs `Procedure`.
- ⏳ **E**: form vs `Condition`/`Encounter`.
- ✅ **`medication_statement`**: formalizado con `status`, `adherence_code`, ADR 010 IDs y contrato ([`contracts/medication_statement.md`](./features/clinical_history/contracts/medication_statement.md)).
- ⏳ **`people.emergency_contact`**: unificar enum de relación con `relationships`.

## Consistencia / docs menores
- ⏳ **`STATUS.md`** desactualizado (2026-07-19).
- ⏳ `tasks/TASK-017/.../planning/README.md` lista **H4** como abierto (ya "dónde resuelto").
- ⏳ Encabezado/“Notas” de `OPEN-QUESTIONS.md` (fecha 2026-09-15).
- ⏳ `features/catalogs/seed/README.md` “Pendientes” (alinear con lo decidido).

## Frontend / componentes (fuera de este repo)
- ⏳ **UI de AHF** = árbol genealógico (`features/clinical_history/proposals/family_condition/family_tree.html`).
- ⏳ **Composición híbrida** de D (registro estático del front, anclado por `key`/`uuid`).
