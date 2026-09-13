# Pendientes — Cuestionarios

> Estado a la fecha: **2026-09-13**. Cada pendiente incluye dónde vive, con qué
> archivos se retoma y de dónde sale el requisito, para poder reanudarlo aun si
> se pierde el contexto de la conversación.

## Contexto

- **Módulo**: [`docs/features/questionnaires/`](../features/questionnaires/)
- **Capa catálogo**: [`catalog/`](../features/questionnaires/catalog/)
- **Capa respuestas**: [`responses/`](../features/questionnaires/responses/)
- **Fuente de verdad del modelo**: [`schema.sql`](../features/questionnaires/schema.sql)
- **Rescate de referencia**: `other_projects/app_questionnaire/backend/docs/`
  (en este workspace: `other_projects/app_questionnaire/backend/docs/`).
- **Reglas de formato**: `.agents/rules/DOCUMENTATION_ERD.md`,
  `.agents/rules/MERMAID_ENUM_REPRESENTATION.md`,
  `.agents/rules/DOCUMENTATION_CLASS_DIAGRAM.md`.

## Alcance de esta fase

> **Fase actual: DEFINICIÓN.** Solo se modelan schemas y contratos en `docs/`.
> **No se toca el frontend** (`frontend/dh_frontend_app/`) ni el backend
> (`backend/`) todavía.

- Los pendientes de esta lista son, por ahora, **decisiones de modelo y
  documentación**; su reflejo en código es posterior.
- `frontend/` (motor del cuestionario, `types.ts`) y `backend/`
  (`ALL_SCHEMAS`, SQLAlchemy) se mantienen **congelados** durante la definición.
- Los pendientes marcados **Frontend** (p. ej. D12) o **Backend** (p. ej. F15)
  describen el **destino** del modelo ya definido, no trabajo de esta fase.
- Al cerrar la definición, cada pendiente se habilitará con su alcance real
  (frontend y/o backend) y su propio ciclo de commit.

## Índice

| # | Pendiente | Grupo | Estado |
|---|---|---|---|
| A1 | Condicional estructurado | Rescate | ⏳ |
| A2 | Lenguaje de expresiones | Rescate | ✅ |
| A3 | Decisión column-JSON vs tabla | Rescate | ⏳ |
| A4 | Conversión API↔BD de `condition` | Rescate | ⏳ |
| B | `order` en tablas puente | Modelo | ✅ |
| C5 | `config` definitivo por tipo | Modelo | ⏳ |
| C6 | PHQ-9 ítem 7 | Contenido | ⏳ |
| C7 | Scoring unificado | Modelo | ✅ |
| C7b | METs IPAQ (scoring no lineal) | Modelo | ⏳ |
| C7c | `value_expression` por pregunta | Modelo | ⏳ |
| C8 | Gaps del contrato `Instrument` | Modelo | ✅ |
| C9 | `AnswerMap` ↔ `answer.value` | Modelo | ⏳ |
| C10 | Schema `form` en `ALL_SCHEMAS` | Infra | ⏳ |
| C11 | Remanentes V1 en `schema.sql` | Modelo | ✅ |
| D12 | Motor frontend (solo 3 tipos) | Frontend | ⏳ |
| E13 | Ruido `TMP_SQL.*` | Higiene | ⏳ |
| E14 | `docs/db/postgres/README.md` V1 | Doc | ✅ |
| F15 | Backend fase 2 (SQLAlchemy/repos) | Backend | ⏳ |

---

## A. Rescate de `app_questionnaire`

### A1 — Condicional estructurado

- **Qué**: la referencia modela el condicional como
  `{ type: 'all'|'any'|'none', rules: [{ id_question, operator, value }] }`,
  con anidación. Hoy el modelo lo reduce a una fórmula de texto.
- **Estado actual**:
  - `schema.sql` → `conditional_logic(id_question, triggered_by_question, formula TEXT, description)`.
  - `schema.sql` → `form_condition(id_form, expression TEXT, description)`.
  - `catalog/ERD.mmd` → entidades `conditional_logic` / `form_condition`.
- **Fuente**: `app_questionnaire/backend/docs/my_arquitecture/question/conditional.md`
  y `.../conditional/index.js`.
- **A decidir**: ¿se modelan `rules[]` (tabla o JSONB) o se mantiene `formula`?
- **Archivos a tocar si se cambia**: `schema.sql`, `catalog/ERD.mmd`,
  `catalog/CLASS.mmd`, `catalog/README.md`, `catalog/example.jsonc`.

### A2 — Lenguaje de expresiones ✅ (resuelto)

- **Decisión**: adoptar el **AST** de la referencia (`typescript.ts`) como
  gramática canónica de `scoring_expression` (raíz `aggregate`) y
  `evaluation_expression` (raíz `case/when`).
- **Ubicación**: [`features/questionnaires/expressions/`](../features/questionnaires/expressions/)
  (`README.md` + `operators/*.md` + `operands.md` + `factories.md` +
  `examples/*.jsonc`). Se extrajo a la **raíz del módulo** (no en `catalog/`) por
  ser transversal a definición y ejecución.
- **Frontera**: este doc cubre **solo** scoring/evaluación. Las **condiciones
  de visibilidad** siguen siendo A1 (pendiente aparte).
- **Convención del `subject`**: el `evaluation_expression` **consume
  `form.scoring_result`** (no repite la fórmula del scoring).
- **Correcciones de la referencia**: `PHQ9.ts` usaba `avg` (debía ser `sum`);
  `expression.md` decía "6 operadores" y documenta 7.
- **Reflejo**: `schema.sql` (ejemplos inválidos corregidos), `catalog/README.md`
  §9/§11/§12, `catalog/example.jsonc`, `questionnaires/README.md`,
  `docs/db/postgres/form/README.md`, `docs/diagrams/schemas/cuestionario/README.md`.

### A3 — Decisión column-JSON vs tabla (contradicción)

- **Qué**: `conditional/column_or_table.md` decidió **columna JSON** para el
  condicional; el modelo actual usa **tabla** (`conditional_logic`).
  Hay contradicción sin documentar.
- **Estado actual**: no hay mención de `column_or_table.md` en `catalog/` ni
  `responses/`.
- **Fuente**: `app_questionnaire/backend/docs/my_arquitecture/question/conditional/column_or_table.md`.
- **A decidir**: adoptar la tabla actual o migrar a columna JSON; registrar la
  decisión (posible ADR en `docs/decisions/`).

### A4 — Conversión API↔BD de `condition`

- **Qué**: patrón de conversión entre el contrato de API (Pydantic) y la
  persistencia (SQLite/Postgres) para el condicional.
- **Fuente**: `app_questionnaire/backend/docs/my_arquitecture/question/schema_architecture_summary.md`.
- **A decidir**: aplicar solo si se implementa el backend (fase 2, F15).

---

## B. Modelo — Orden ✅ (resuelto)

- **Decisión**: el orden vive donde vive la relación.
  - `option.order` → en la entidad (relación exclusiva con su pregunta).
  - `question` → **sin** `order`; el orden vive en `questions_form.order` y
    `questions_section.order` (la pregunta es reutilizable).
- **Reflejo**: `schema.sql`, `catalog/ERD.mmd`, `catalog/CLASS.mmd`
  (vista MongoDB: sin puentes, `Question` embebido con `order`).
- **Documentación**: `catalog/README.md` §7.
- **Commits**: `921f457` (puentes) y `4925be8` (CLASS/MongoDB).

## C. Modelo / gaps

### C5 — `config` definitivo por tipo

- **Qué**: definir el `config` final de los tipos que hoy son **propuesta
  inicial**: `TEXT`, `TEXT_LONG`, `NUMBER`, `SINGLE_CHOICE`,
  `MULTIPLE_CHOICE`, `DATE`, `DATE_TIME`.
- **Estado actual**: `catalog/question_types/*.md` (8 archivos marcados
  "propuesta inicial"). `RANGE` y `TIMER` ya son definitivos (rescatados).
- **Refs**: `catalog/question_types/README.md`, `catalog/README.md` §6,
  `schema.sql` (`question.config`).

### C6 — PHQ-9 ítem 7 (redacción)

- **Qué**: divergencia de copy.
  - MVP `phq9Instrument.ts` + legacy: "leer el **cuerpo del texto**".
  - Drawio MVP + referencia `.json`: "leer el **periódico**".
- **Refs**: `catalog/README.md` §11 (discrepancias) y §12 (pendientes).
- **Fuente**: `reference_projects/reference_frontend_app_legacy/...` y
  `app_questionnaire/.../PHQ9.json`.

### C7 — Scoring unificado ✅ (resuelto)

- **Decisión**: el **AST** ([`expressions/README.md`](../features/questionnaires/expressions/README.md))
  es la forma **canónica** de scoring:
  - `scoring_expression` (form) → `aggregate sum/avg` (número).
  - `evaluation_expression` (form) → `case/when` (categoría).
  - Subescalas → arreglo `subscales[]`, cada una con su par de expresiones.
  - Resultados → `assignment.scoring_result` / `evaluation_result` = `{value, data_type}`
    (espejan el `const` del AST, en inglés).
- **Forma simplificada del MVP** (rangos `interpretacion[]` + `scoring.tipo`):
  se documenta como origen y **a migrar** (el motor la migra en D12, fase frontend).
  Traducción rango→umbral documentada en `expressions/README.md` §7.
- **IPAQ METs** se separó a **C7b** (pendiente propio).
- **Reflejo**: `expressions/` (README + ejemplos), `schema.sql` (ejemplos
  corregidos), `catalog/README.md` §9/§11/§12, `catalog/example.jsonc`,
  `questionnaires/README.md`.

### C7b — METs IPAQ (scoring no lineal)

- **Qué**: el IPAQ puntúa por **MET-min/semana**:
  `MET × minutos × días`; coeficientes `caminar=3.3`, `moderada=4.0`,
  `vigorosa=8.0`; total = suma de dominios.
- **Estado**: no modelado. `IPAQ.json` no trae scoring; `IPAQ.ts` de la referencia
  está incompleto (variables no definidas, `else if` sin cuerpo); el único
  algoritmo completo está en `docs/diagrams/3_CUESTIONARIO_FISICO/IPAQ.pseint`.
- **Vía**: el AST puede expresarlo (`math` `*` por coeficientes + `aggregate sum`),
  pero requiere definir cómo se declaran los dominios (grupos de preguntas).
- **Refs**: `expressions/README.md` §9, `catalog/README.md` §9/§11,
  `docs/diagrams/3_CUESTIONARIO_FISICO/IPAQ.pseint`.

### C7c — `value_expression` por pregunta (valor autocalculado)

- **Qué**: permitir que una **pregunta** tenga un valor **autocalculado** por una
  expresión (idea de `app_questionnaire/.../types/chatgpt_.ts`,
  `Question.calculation`), expresada con el **mismo AST** que el scoring.
- **Forma propuesta**: `Question.value_expression` (un `OperandExpression`),
  simétrico a `form.scoring_expression`.
- **Duda abierta**: si una pregunta tiene `value_expression`, ¿su valor es
  **solo lectura** (calculado) o editable por el usuario? Definir la semántica.
- **Refs**: `expressions/README.md` §1 (puntos de aplicación del AST).

### C8 — Gaps del contrato `Instrument` ✅ (resuelto)

- **Qué era**: campos presentes en la referencia y ausentes en el MVP:
  `target_sex`, `list_references`, `list_sections`.
- **Decisión** ([ADR 038](../../decisions/038-formulario-preguntas-vs-secciones.md)):
  - `list_references` → `{id?, url_reference?, name?, notes?, url_thumbnail?,
    type_media?}[]` (forma real de `PHQ9.json`/`IA_DEVELOPMENT.json`).
  - `list_sections` → `Section[]` (espejo del ERD; **no** era un gap inmodelable).
  - `target_sex`: **no era gap**; el `example.jsonc` ya lo modelaba como objeto
    `{type_biological_sex, id}` y el README §5 lo declaraba `null | string`.
    Se corrigió la contradicción del README (ver §11 de `catalog/README.md`).
- **Decisión de composición**: un formulario usa preguntas directas
  (`list_questions`) **XOR** secciones (`list_sections`), nunca ambos. Regla de
  aplicación (Pydantic + `COMMENT`), **no** constraint de BD (ADR 038).
- **Reflejo**: `catalog/README.md` §4/§5/§7/§11, `catalog/example.jsonc`,
  `catalog/ERD.mmd`, `catalog/CLASS.mmd`, `schema.sql`,
  `questionnaires/README.md`, `question_types/README.md`.

### C9 — `AnswerMap` ↔ `answer.value`

- **Qué**: alinear la forma en memoria del frontend
  (`AnswerMap = Record<string, number|number[]|string>`) con el valor JSON
  persistido (`answer.value` = `{type, value}`).
- **Refs**: `catalog/README.md` §7 (`answer`), `responses/ERD.mmd`,
  `responses/example.jsonc`.

### C10 — Schema `form` en `ALL_SCHEMAS`

- **Qué**: añadir el schema `form` a la lista de schemas del backend.
- **Ubicación**: `backend/dh_shared/src/dh_shared/base.py:40-43`
  (`ALL_SCHEMAS`). Hoy: `people, storage, auth, iam, org, health_profile, mfa, relationships`.
- **Nota**: revisar coherencia de nombres (`org` vs `organizations`,
  `relationships` vs `care`) al tocar el archivo.
- **Alcance**: repo **backend** (excluido de commits en la sesión actual).

### C11 — Remanentes V1 en `schema.sql` ✅ (resuelto)

- **Verificado**: no existen `form_direct_responses`, `scheduled_responses`
  ni `attempt_number` en `schema.sql`.
- **Commit**: `5fcb48e`.

## D. Motor frontend

### D12 — Solo 3 tipos soportados

- **Qué**: el motor del frontend implementa solo
  `SINGLE_CHOICE | MULTIPLE_CHOICE | TEXT`. Falta soporte para `RANGE`,
  `TIMER`, `NUMBER`, `DATE`, `DATE_TIME`, `TEXT_LONG`.
- **Refs**: `docs/diagrams/schemas/cuestionario/README.md:23`
  (describe el **estado actual implementado**, no el objetivo).
- **Objetivo**: `catalog/question_types/` (9 tipos).

## E. Higiene

### E13 — Ruido en `app_questionnaire`

- **Qué**: archivos vacíos o scratch por decidir su eliminación.
- **Ubicación**: `other_projects/app_questionnaire/backend/docs/cuestionarios/`
  - `TMP_SQL.JS` (0 bytes)
  - `TMP_SQL2.ts` (0 bytes)
  - `chatgpt_.ts` (scratch de IA, posible duplicado)

### E14 — `docs/db/postgres/README.md` V1 ✅ (resuelto)

- **Qué**: la fila del schema `form` listaba `response`/`id_respondent` (V1).
- **Corrección**: ahora dice `assignment (id_person)` + nota de que
  `answer.answered_by` referencia usuarios (auth/iam).
- **Commit**: `5fcb48e`.

## F. Backend (fase 2)

### F15 — Modelos SQLAlchemy / repositorios / servicios

- **Qué**: implementar el schema `form` en backend (modelos SQLAlchemy,
  repositorios, servicios) a partir de `schema.sql`.
- **Alcance**: fuera del alcance actual; repo `backend/` excluido de commits.
- **Depende de**: cerrar A1–A4 y C5–C9.

---

## Cómo retomar

1. Leer este documento y el índice.
2. Para cada pendiente, abrir los **Refs** indicados (rutas relativas a este
   workspace).
3. Respetar la convención de orden ya decidida (B) al tocar el modelo.
4. Al cerrar un pendiente, marcarlo ✅ aquí con el commit correspondiente.
