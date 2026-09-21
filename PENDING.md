# PENDIENTES (índice global)

> **Índice único** de trabajo diferido y decisiones abiertas, por área. **No**
> duplica el detalle: **enlaza** a la fuente de cada pendiente (formato
> *dónde vive + de dónde sale*, reanudable).
>
> **Estado:** 2026-09-20 · Fase **DEFINICIÓN** (solo `docs/`; `frontend/` y
> `backend/` congelados).
> **Alcance:** `[def]` = docs/modelo (**ahora**) · `[back]` / `[front]` = diferido.

## Tareas (global)
- [`tasks/backlog.md`](./tasks/backlog.md) — estado de tareas `TASK-NNN`.

## Cuestionarios — TASK-016
- **Detalle**: [`tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md`](./tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md)
  (abiertos: **C15** `[def]`, **C21** `[def]`, **A4** `[back]`, **C10** `[back]`, **F15** `[back]`, **D12** `[front]`).
- ⏳ `[def]` **C21** — opciones con **`uuid`** (formato `{uuid, value, label, …}` + API sub-recurso
  `PATCH /questions/options/{uuid_option}`): los **bancos se revisan todos**.
- Puntero: [`TODO/cuestionarios.md`](./TODO/cuestionarios.md).

## Historia clínica — TASK-017
- **Decisiones abiertas (stoppers)**: [`tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md`](./tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md)
  → `[def]` **G1** (nombre del tutor → drawio), **G2** (grupo étnico), **H1** (resto:
  `encounter`), **H4** (resto: propiedades de dominio (`person.*`) + instrumentos).
- **Bloqueos / anexos**: `[def]` [`features/clinical_history/README.md`](./features/clinical_history/README.md).

### AST / expresiones
- ⏳ `[def]` **Propiedades de dominio en el AST** (opción **(b)**: arreglos) — para los
  activadores de enfermedades/medicamentos:
  - `person.conditions` → arreglo de **`cie11_code`**.
  - `person.medications` → arreglo de **códigos**; sub-decisión **ATC**:
    **(A)** fijar `code_system = ATC` (el arreglo es el ATC) · **(B)** exponer
    `person.medication_atcs` aparte · **(C)** objetos `{code, atc, group}` (futuro).
  - **ADR 048** (propiedades de dominio en el AST) — **por escribir**.
  - Ver **H4**.
- ✅ Hechos: selector `uuid`; `question.id`/`key`/`uuid` globales; cardinalidad 1:N;
  contexto `person` ([ADR 047](./decisions/047-contexto-evaluacion-expresiones.md)).

### Activadores (anexos C/D)
- ⏳ `[def]` Agregar **`form.condition`** a los instrumentos (depende de las entidades de
  dominio del AST).
- ⏳ `[def]` **Crear los instrumentos faltantes** del banco (ZARIT-CBI, SF-12, ASQ-15,
  AES-S, CTH, ASRS-V1.1, EDAH, DTS, SPIN, TAS-20, DAI-10).
- ⏳ `[def]` **Validar la reconciliación** de los anexos (nomenclatura "Formulario A/B/C")
  → [`features/clinical_history/README.md`](./features/clinical_history/README.md) (§Anexos C/D).
- ⏳ `[def]` **4 condiciones agregadas temporalmente** a la categoría **D `2.4`**
  (estrés→PSS, TEPT→DTS, fobia social→SPIN, alexitimia→TAS-20) — **validar** con la
  fuente → [`features/clinical_history/README.md`](./features/clinical_history/README.md) (§Gaps).

### Banco y modelado
- ⏳ `[def]` **E** sin banco: `features/questionnaires/catalog/bank/clinical_history/padecimiento_actual.json`.
- ⏳ `[def]` **Componentes A/B/D** — **contrato `componente → dominio`** (qué entidades/columnas
  lee/escribe el endpoint): ✅ medicación definida en [`contracts/medication_statement.md`](./features/clinical_history/contracts/medication_statement.md);
  resto (alergias, cirugías, AHF) **pendiente**. **No** pasan por el
  mapper → [`features/clinical_history/sections/README.md`](./features/clinical_history/sections/README.md).
- ⏳ `[def]` **`clinical_history.encounter`** + **`encounter_diagnosis`** — pendiente de
  diseño → [`db/postgres/clinical_history/README.md`](./db/postgres/clinical_history/README.md).

## Mapper — TASK-018
- **Task**: [`tasks/TASK-018-mapper-dominio/README.md`](./tasks/TASK-018-mapper-dominio/README.md) — status **backlog**.
- **Feature**: [`features/mapper/`](./features/mapper/) — contrato ([`README.md`](./features/mapper/README.md)), reglas ([`RULES.md`](./features/mapper/RULES.md)), casos de uso ([`uses_cases/`](./features/mapper/uses_cases/)).
- **Store**: **`dh_bindings` / `bindings`** (Mongo) — seed [`store/seeder.js`](./features/mapper/store/seeder.js).
- **Alcance**: **solo preguntas de `form`** (prefill `read` + write-through `write`).
  Los **componentes (A/B/D)** **no** pasan por el mapper.
- ⏳ `[back]` / `[front]` Contrato + store + read/write + **UI administrativa** por desarrollar.

## Catálogos
- ⏳ `[def]` **`medication`** (Vademecum): definir **fuente/sync** y **columnas finales**
  (hoy es **propuesta**) → [`features/catalogs/clickhouse/medication.md`](./features/catalogs/clickhouse/medication.md).
- ⏳ `[def]` **`medication`**: decidir si se **conserva `atc`** o es **redundante** cuando
  `code_system = "ATC"`.
- ✅ **Registro/seed** de `gender`, `relationship`, `housing_type`, `heating_fuel`, `work_shift`.
- ⏳ `[def]` **`animal_type`**: seed + registro (sin decisiones) → [`features/catalogs/seed/README.md`](./features/catalogs/seed/README.md).
- ⏳ `[def]` **`allergy_category`** (D `6.0`): decidir **enum FHIR** (`food`/`medication`/`environment`/`biologic`) **vs catálogo gobernado**; lo consume el **componente** `AllergyIntolerance` (**no** un form) → [`D_antecedentes_pp.md`](./features/clinical_history/sections/D_antecedentes_pp.md).
- ⏳ `[def]` **Registrar** los catálogos externos (`disease`, `study`, `body_site`, `allergen`, `drug`).
- ⏳ `[def]` **`cie11` completo** (masivo) — diferido.

## Base de datos
- ⏳ `[def]` Esquemas **sin adoptar** → [`db/postgres/todo/propuesta_schemes_2.md`](./db/postgres/todo/propuesta_schemes_2.md).
- ✅ **`catalog`** (Postgres) → [`erd.mmd`](./db/postgres/catalog/erd.mmd). `[def]` Pendiente: DDL + FK del dominio.
- ⏳ `[def]` **ClickHouse / Mongo** sin diseñar (salvo `catalogs/`).
- ⏳ `[def]` **`relationships`**: pendientes del README — `friendship`/`follow` (diferidas),
  `power_of_attorney`, `insurance_links` → [`db/postgres/relationships/README.md`](./db/postgres/relationships/README.md).
- ⏳ `[def]` **`health_profile`**: catálogos futuros (`allergy_severity`,
  `allergy_reaction_type`, `vaccine_catalog`) → [`db/postgres/health_profile/README.md`](./db/postgres/health_profile/README.md).

## Dudas de modelo sin cerrar
- ⏳ `[def]` **D `10.0` lesiones**: `Condition` vs `Procedure`.
- ⏳ `[def]` **E**: form vs `Condition`/`Encounter`.
- ✅ **`medication_statement`**: formalizado con `status`, `adherence_code`, ADR 010 IDs y contrato ([`contracts/medication_statement.md`](./features/clinical_history/contracts/medication_statement.md)).
- ✅ Catálogo `relationship` reemplaza los enums `ERelationship` y `ERelationshipContact`.

## Consistencia / docs menores
- ⏳ `[def]` **`STATUS.md`** desactualizado (2026-07-19).
- ⏳ `[def]` `tasks/TASK-017/.../planning/README.md` lista **H4** como abierto (ya "dónde resuelto").
- ⏳ `[def]` Encabezado/“Notas” de `OPEN-QUESTIONS.md` (fecha 2026-09-15).
- ✅ `features/catalogs/seed/README.md` — alineado.
- ✅ **Review commit `5de841a` (`medication_statement`) — corregido**:
  - **I1** índice `db/postgres/README.md` → `medication_statement`.
  - **I2** activador DAI-10 → **texto funcional** + nota *"la sintaxis AST depende de H4"*.
  - **I3** `status` → **desviación intencional** declarada (estado clínico), **pendiente de revisión posterior**; enum = 4 valores (`ACTIVE`/`COMPLETED`/`STOPPED`/`ON_HOLD`).
  - **I4** DDL fuera del contrato → **enlace al ERD** + **spec de campos**.
  - **I5** `uuid` → **v4** (`gen_random_uuid()`) + comentario de seeds **v7** (SQLAlchemy/Python).
  - **I6** prefijos de endpoint → `/v1/catalogs/medications`.

## Frontend / componentes (fuera de este repo)
- ⏳ `[front]` **UI de AHF** = árbol genealógico (`features/clinical_history/proposals/family_condition/family_tree.html`).
- ⏳ `[front]` **Composición híbrida** de D (registro estático del front, anclado por `key`/`uuid`).
