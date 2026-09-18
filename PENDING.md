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
  (A4, C10, C15, D12, F15; C15 = único de modelo).
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

### Banco y modelado
- ⏳ **E** sin banco: `features/questionnaires/catalog/bank/clinical_history/padecimiento_actual.json`.
- ⏳ **Componentes A/B/D** (tablas + endpoints) — diferido a `docs/db/postgres/`.
- ⏳ **`clinical_history.encounter`** + **`encounter_diagnosis`** — pendiente de
  diseño → [`db/postgres/clinical_history/README.md`](./db/postgres/clinical_history/README.md).

## Catálogos
- ⏳ **`medication`** (Vademecum): definir **fuente/sync** y **columnas finales**
  (hoy es **propuesta**) → [`features/catalogs/clickhouse/medication.md`](./features/catalogs/clickhouse/medication.md).
- ⏳ **Seeds/registro** de `fuel_type`, `animal_type`, `work_shift`
  → [`features/catalogs/seed/README.md`](./features/catalogs/seed/README.md).
- ⏳ **Registrar** los catálogos externos (`disease`, `study`, `body_site`, `allergen`, `drug`).
- ⏳ **`cie11` completo** (masivo) — diferido.

## Base de datos
- ⏳ Esquemas **sin adoptar** → [`db/postgres/todo/propuesta_schemes_2.md`](./db/postgres/todo/propuesta_schemes_2.md).
- ⏳ **`catalog`** (Postgres) — schema pendiente de modelar.
- ⏳ **ClickHouse / Mongo** sin diseñar (salvo `catalogs/`).

## Dudas de modelo sin cerrar
- ⏳ **D `10.0` lesiones**: `Condition` vs `Procedure`.
- ⏳ **E**: form vs `Condition`/`Encounter`.
- ⏳ **`medication`**: ¿`adherence`/`is_active`? (se omitió `status`).
- ⏳ **`people.emergency_contact`**: unificar enum de relación con `relationships`.

## Consistencia / docs menores
- ⏳ **`STATUS.md`** desactualizado (2026-07-19).
- ⏳ `tasks/TASK-017/.../planning/README.md` lista **H4** como abierto (ya "dónde resuelto").
- ⏳ Encabezado/“Notas” de `OPEN-QUESTIONS.md` (fecha 2026-09-15).
- ⏳ `features/catalogs/seed/README.md` “Pendientes” (alinear con lo decidido).

## Frontend / componentes (fuera de este repo)
- ⏳ **UI de AHF** = árbol genealógico (`features/clinical_history/proposals/family_condition/family_tree.html`).
- ⏳ **Composición híbrida** de D (registro estático del front, anclado por `key`/`uuid`).
