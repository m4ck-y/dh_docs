# Pendientes — Cuestionarios

> Estado a la fecha: **2026-09-15**. Cada pendiente incluye dónde vive, con qué
> archivos se retoma y de dónde sale el requisito, para poder reanudarlo aun si
> se pierde el contexto de la conversación.

## Contexto

- **Módulo**: [`docs/features/questionnaires/`](../../../features/questionnaires/)
- **Capa catálogo**: [`catalog/`](../../../features/questionnaires/catalog/)
- **Capa respuestas**: [`responses/`](../../../features/questionnaires/responses/)
- **Fuente de verdad del modelo**: [`schema.sql`](../../../features/questionnaires/schema.sql)
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
- **Excepción aplicada**: **C6** (redacción del PHQ-9 ítem 7) sí tocó el banco
  `frontend/.../banks/phq9Instrument.ts` (era un copy incorrecto, no un cambio
  de modelo). Commit `69d325e` en `ls_frontend_app`.

## Índice

| # | Pendiente | Grupo | Estado |
|---|---|---|---|
| A1 | Condicional estructurado | Rescate | ✅ |
| A2 | Lenguaje de expresiones | Rescate | ✅ |
| A3 | Decisión column-JSON vs tabla | Rescate | ✅ |
| A4 | Conversión API↔BD de `condition` | Rescate | ⏳ |
| B | `order` en tablas puente | Modelo | ✅ |
| C5 | `config` definitivo por tipo | Modelo | ✅ |
| C6 | PHQ-9 ítem 7 | Contenido | ✅ |
| C7 | Scoring unificado | Modelo | ✅ |
| C7b | METs IPAQ (scoring no lineal) | Modelo | ✅ |
| C7c | `question.expression` por pregunta | Modelo | ✅ |
| C8 | Gaps del contrato `Instrument` | Modelo | ✅ |
| C9 | `AnswerMap` ↔ `answer.data` | Modelo | ✅ |
| C10 | Schema `form` en `ALL_SCHEMAS` | Infra | ⏳ |
| C11 | Remanentes V1 en `schema.sql` | Modelo | ✅ |
| C12 | `instructions` (técnica vs llenado) | Modelo | ✅ |
| C13 | `list_population` (N:N) | Modelo | ✅ |
| C14 | Prefijo `list_` en colecciones | Modelo | ✅ |
| C15 | ¿`target_*` (sex/age/population) dentro de `condition`? | Modelo | ⏳ |
| C16 | Rangos: `min`/`max`/`unit` + `name` legible (Diseño C) | Modelo | ✅ |
| C17 | `question.text` nullable (ítem sin enunciado propio) | Modelo | ✅ |
| C18 | `form.type` (`EFormType`) formalizado | Modelo | ✅ |
| D12 | Motor frontend (solo 3 tipos) | Frontend | ⏳ |
| E13 | Ruido `TMP_SQL.*` | Higiene | ✅ |
| E14 | `docs/db/postgres/README.md` V1 | Doc | ✅ |
| F15 | Backend fase 2 (SQLAlchemy/repos) | Backend | ⏳ |

---

## A. Rescate de `app_questionnaire`

### A1 — Condicional estructurado ✅ (resuelto)

- **Decisión** ([ADR 039](../../../decisions/039-condicion-visibilidad-ast.md)): la
  condición de visibilidad se modela con el **AST de expresiones** (booleano) y se
  guarda como **columna JSONB** en **tres niveles**: `form.condition`,
  `section.condition`, `question.condition`. Ausente = siempre visible.
- **Alcance**: solo **visibilidad** (mostrar/ocultar), no skip logic ni "requerido
  condicional".
- **Ubicación**: [`expressions/conditions.md`](../../../features/questionnaires/expressions/conditions.md).
- **Traducción**: la forma de la referencia `{type: all|any|none, rules[]}` se
  traduce al AST (`logic`/`comparison`/`collection`); un rango de preguntas usa el
  selector `range` en vez de N reglas.

### A2 — Lenguaje de expresiones ✅ (resuelto)

- **Decisión**: adoptar el **AST** de la referencia (`typescript.ts`) como
  gramática canónica de `form.expression.scoring` (raíz `aggregate`) y
  `form.expression.evaluation` (raíz `case/when`).
- **Ubicación**: [`features/questionnaires/expressions/`](../../../features/questionnaires/expressions/)
  (`README.md` + `operators/*.md` + `operands.md` + `factories.md` +
  `examples/*.jsonc`). Se extrajo a la **raíz del módulo** (no en `catalog/`) por
  ser transversal a definición y ejecución.
- **Frontera**: este doc cubre **solo** scoring/evaluación. Las **condiciones
  de visibilidad** siguen siendo A1 (pendiente aparte).
- **Convención del `subject`**: la `evaluation` **consume
  `form.result.scoring`** (no repite la fórmula del scoring).
- **Correcciones de la referencia**: `PHQ9.ts` usaba `avg` (debía ser `sum`);
  `expression.md` decía "6 operadores" y documenta 7.
- **Reflejo**: `schema.sql` (ejemplos inválidos corregidos), `catalog/README.md`
  §9/§11/§12, `catalog/example.jsonc`, `questionnaires/README.md`,
  `docs/db/postgres/form/README.md`, `docs/features/questionnaires/reference/questionnaire-engine.md`.

### A3 — Decisión column-JSON vs tabla ✅ (resuelto)

- **Decisión**: se adopta **columna JSONB** (`condition`) en `form`/`section`/
  `question`, eliminando las tablas `conditional_logic` y `form_condition`. Es lo
  que ya recomendaba `column_or_table.md` (condición = propiedad exclusiva del
  elemento, no compartida, evaluada en memoria).
- **Reflejo**: `schema.sql` (tablas e índices eliminados; columnas añadidas),
  `catalog/ERD.mmd`, `catalog/CLASS.mmd`, `catalog/README.md`, `catalog/example.jsonc`.
- **Decisión registrada en**: [ADR 039](../../../decisions/039-condicion-visibilidad-ast.md).

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

### C5 — `config` definitivo por tipo ✅ (resuelto)

- **Decisión**: los 9 tipos tienen `config` definitivo:
  - `required` común; `default` (opcional) **excluyente** con `required`.
  - Límites unificados a **`min`/`max`** en todos los tipos (incluidos
    `RANGE`/`TIMER`, con **desviación intencional** de `range.md`/`timer.md`).
  - `MULTIPLE_CHOICE`: `min`/`max` son cantidad de selecciones; `default` es
    `number[]`.
  - Nuevos campos: `min_length` (texto), `step` (NUMBER/DATE_TIME),
    `default`/`default_values`→`default` (todos).
- **Forma final**:
  | Tipo | `config` |
  |---|---|
  | `TEXT` | required, min_length, max_length, default |
  | `TEXT_LONG` | required, min_length, max_length, multiline, default |
  | `NUMBER` | required, min, max, decimals, step, default |
  | `SINGLE_CHOICE` | required, shuffle, default |
  | `MULTIPLE_CHOICE` | required, shuffle, min, max, default (number[]) |
  | `DATE` | required, min, max, default |
  | `DATE_TIME` | required, min, max, step, default |
  | `TIMER` | required, min, max, precision, default |
  | `RANGE` | required, min, max, step, integer, default |
- **Reflejo**: 9 docs en `catalog/question_types/`, `question_types/README.md`,
  `catalog/README.md` §6, `catalog/example.jsonc`, `schema.sql`.

### C6 — PHQ-9 ítem 7 (redacción) ✅ (resuelto)

- **Qué era**: se planteó como "divergencia de copy", pero **no era una
  divergencia entre fuentes válidas, sino un error propagado**: el
  "cuerpo del texto" nació en el **código legacy**
  (`reference_frontend_app_legacy/.../cuestionarios/phq9.js`) y lo **heredó** el
  banco del MVP al portarlo.
- **Decisión**: la redacción canónica es **"periódico"**, usada por las **cuatro**
  referencias reales: drawio fuente de verdad
  (`docs/diagrams/1_CUESTIONARIO_MENTAL/source/…drawio`), drawio legacy
  (`index.DEMO_quewstionnaire.drawio`), `PHQ9.json`/`PHQ9.md` y `phq.mmd`.
- **Aplicado**: `phq9Instrument.ts` ítem 7 → `"…leer el periódico o ver la
  televisión"` (antes `"…cuerpo del texto o ver la television"`).
- **Nota**: el `.mmd`/`.md` de `docs/diagrams/` ya eran correctos (no se tocaron).
- **Refs**: `catalog/README.md` §11 (discrepancias) y §12 (pendientes).

### C7 — Scoring unificado ✅ (resuelto)

- **Decisión**: el **AST** ([`expressions/README.md`](../../../features/questionnaires/expressions/README.md))
  es la forma **canónica** de scoring, agrupada en el envelope **`form.expression`**:
  - `expression.scoring` → `aggregate sum/avg` (número).
  - `expression.evaluation` → `case/when` (categoría).
  - Subescalas → `expression.subscales[]`, cada una `{id, name, items, max, scoring, evaluation}`;
    `items` es la fuente de pertenencia y el scoping es **por contexto** (HADS).
  - Resultados → `assignment.result` (espeja el envelope) = `{value, type}` por valor.
- **Forma simplificada del MVP** (rangos `interpretacion[]` + `scoring.tipo`):
  se documenta como origen y **a migrar** (el motor la migra en D12, fase frontend).
  Traducción rango→umbral documentada en `expressions/README.md` §5.
- **IPAQ METs** se separó a **C7b** (pendiente propio).
- **Regla de wrapper** (§1): raíz de campo sin wrapper; operandos con wrapper.
- **Reflejo**: `expressions/` (README + ejemplos), `schema.sql`, `catalog/README.md`
  §9/§11/§12, `catalog/example.jsonc`, `questionnaires/README.md`.

### C7b — METs IPAQ (scoring no lineal) ✅ (resuelto)

- **Qué**: el IPAQ puntúa por **MET-min/semana**:
  `MET × minutos × días`; coeficientes `caminar=3.3`, `moderada=4.0`,
  `vigorosa=8.0`; total = suma de dominios.
- **Decisión**: modelado con el AST mediante **extensiones del proyecto**:
  - **`definitions`** (mapa de fórmulas con nombre) + operando **`{ref}`** para
    reutilizar intermedios (`min_vig`, `total_vig`, `total_mets`…).
  - **`time: minutes`** (nuevo operador de la familia `time`) que convierte la
    respuesta `TIMER` (ISO 8601) a minutos.
  - **`case` condition-based**: cada `when` es una condición booleana (se elimina
    el `subject` único); las condiciones del IPAQ se nombran como definitions
    (`es_alto` / `es_moderado`).
  - Los intermedios se **persisten** en `result.definitions`.
- **Alternativa descartada (documentada)**: familia genérica `convert` con campo
  `to` (más invasiva; se promovería si aparece un 2.º tipo de conversión).
- **Reflejo**: `expressions/README.md` §1/§6/§7, `operands.md` (`OperandRef`),
  `operators/time.md` (`minutes`), `operators/case.md` (condition-based),
  `examples/ipaq-expression.jsonc` + `ipaq-result.jsonc`, `schema.sql`
  (COMMENTs), `catalog/README.md` §9/§11, `catalog/CLASS.mmd`.
- **Refs**: `docs/diagrams/3_CUESTIONARIO_FISICO/source/IPAQ.pseint` (algoritmo).

### C7c — `question.expression` por pregunta (valor autocalculado) ✅ (resuelto)

- **Qué era**: permitir que una **pregunta** tenga un valor **autocalculado** por
  una expresión (idea de un borrador de IA ya eliminado, `Question.calculation`),
  expresada con el **mismo AST** que el scoring.
- **Decisión — campo y semántica**:
  - `question.expression` (JSONB, **una** expresión, raíz sin wrapper) en la
    **entidad** `question`. Es la **receta**; análogo a `form.expression` (pero
    `form.expression` es un *envelope* y `question.expression` es *una* expresión).
  - **Solo lectura (calculada)**: el usuario no la responde.
  - **Referencias permitidas**: preguntas del mismo form (incl. **otras
    calculadas**, con **validación de ciclos**), `person`, `const`, `{ref}` a
    `definitions` del form, operadores anidados.
  - **Prohibido**: `form.result.*` (circular).
  - **Ejemplos**: "Total" (suma de preguntas) e IMC (`person`).
- **Decisión — persistencia**: el valor calculado **se persiste** como fila de
  `answer` con `data = {value, type}` (`source = CALCULATED`, `answered_by = NULL`).
  Se recalcula en vivo y se guarda al enviar (`SUBMITTED`), junto con
  `assignment.result`; es un **snapshot** auditable (congela edad/IMC del momento).
  Justificación (uniformidad `question.value → answer.data.value`, histórico,
  precedente `result.definitions`): [ADR 041](../../../decisions/041-origen-answer-valores-calculados.md).
- **Origen de la `answer`**: enum `EAnswerSource { USER, CALCULATED }` en
  `answer.source` (default `USER`) con
  `CHECK ((source = 'USER') = (answered_by IS NOT NULL))`. Se descartó el
  `answered_by` JSONB (perdería el FK y la convención de los `*_by`).
- **Reflejo**: `schema.sql` (`question.expression`, `answer.source` + enum + CHECK),
  `expressions/README.md` (§1 + "Preguntas autocalculadas y persistencia"),
  `expressions/operands.md`, `expressions/examples/question-expression.jsonc`,
  `catalog/ERD.mmd`, `catalog/CLASS.mmd`, `catalog/README.md` §6/§8,
  `catalog/example.jsonc`, `responses/ERD.mmd`, `responses/CLASS.mmd`,
  `responses/README.md`, `responses/example.jsonc`.
- **Refs**: `expressions/README.md` §1, `expressions/operands.md` (propiedades
  derivadas), [ADR 040](../../../decisions/040-ast-propiedades-derivadas.md),
  [ADR 041](../../../decisions/041-origen-answer-valores-calculados.md).

### C8 — Gaps del contrato `Instrument` ✅ (resuelto)

- **Qué era**: campos presentes en la referencia y ausentes en el MVP:
  `target_sex`, `list_references`, `list_sections`.
- **Decisión** ([ADR 038](../../../decisions/038-formulario-preguntas-vs-secciones.md)):
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

### C9 — `AnswerMap` ↔ `answer.data` ✅ (resuelto)

- **Decisión (modelo)**: `answer.data` usa el envelope **`{value, type}`**,
  los mismos campos que un `const` del AST y que `assignment.result`. Un solo
  vocabulario para todo valor del módulo.
- **`DataType` ampliado** con `datetime` y `duration` (para `DATE_TIME` y `TIMER`).
- **Respuestas de opción** guardan el `value` **numérico** de la opción
  (`option.value`), no la etiqueta.
- **Reflejo**: `schema.sql` (CHECK `type` + COMMENT), `responses/ERD.mmd`,
  `responses/CLASS.mmd`, `responses/example.jsonc`, `catalog/README.md` §8,
  `expressions/README.md` §3.
- **Frontend**: el `AnswerMap` en memoria es una representación **provisional**
  (sin tipo, aplanada); su migración al envelope es **fase frontend (D12)**.

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

### C12 — `form.instructions` (técnica vs llenado) ✅ (resuelto)

- **Qué era**: tres textos posibles del instrumento: `description` (técnica),
  texto de **llenado** y "descripción amigable". El frontend ya usaba
  `instrucciones`; `schema.sql` no tenía el campo.
- **Decisión**:
  - `form.description` = **técnica** (qué es / qué evalúa).
  - **`form.instructions`** (inglés, `TEXT`, nullable) = **llenado** para el
    paciente. Se renombra `instrucciones` → `instructions` (frontend en D12).
  - **Amigable** = solo en el `<key>.md` del banco; **no** se modela.
- **Reflejo**: `schema.sql` (+ columna y `COMMENT`), `catalog/ERD.mmd`,
  `catalog/CLASS.mmd`, `catalog/README.md` (§5 + extensiones), `catalog/example.jsonc`,
  `catalog/bank/README.md` (convención y plantilla), `reference/questionnaire-engine.md`
  (nota de destino).

### C13 — `list_population` (N:N) ✅ (resuelto)

- **Qué era**: `form ↔ population` es **N:N** (`form_population` con
  `UNIQUE(id_form, id_population)`); el DDL/ERD ya estaban bien, pero el
  contrato/ejemplo/plantilla **no** exponían la relación, y `CLASS.mmd` no
  modelaba ninguna metadata.
- **Decisión**: exponer `list_population: { id?, name }[]` (naming elegido:
  `list_population`). El ERD no se toca.
- **Reflejo**: `catalog/README.md` §5, `catalog/example.jsonc`,
  `catalog/bank/README.md` (plantilla), `catalog/CLASS.mmd` (metadata embebida
  del `Form`: `list_categories`, `list_cie11_codes`, `list_evaluation_topics`,
  `target_age_groups`, `list_population`, `list_references`, `estimated_duration`,
  `target_sex` + clases `Category`/`Cie11Code`/`EvaluationTopic`/`AgeGroup`/
  `Population`/`Reference`/`EstimatedDuration`).

### C14 — Prefijo `list_` en colecciones ✅ (resuelto)

- **Qué era**: el `CLASS.mmd` usaba `sections`/`questions`/`options` y
  `target_age_groups`, mientras el payload ya usaba `list_sections`/
  `list_questions`/`list_options`.
- **Decisión**: toda colección (1:N y N:N) lleva **`list_`** +
  `{secondary_entity_plural}` (regla `PYTHON_INFRA_DB_RELATIONSHIPS.md` y
  `PYTHON_DOMAIN_RELATIONSHIPS.md`). Se unifica:
  - `sections` → `list_sections`, `questions` → `list_questions`,
    `options` → `list_options`.
  - `target_age_groups` → **`list_age_groups`** (payload incluido).
- **Reflejo**: `catalog/CLASS.mmd`, `catalog/example.jsonc`,
  `catalog/bank/README.md`, `catalog/README.md` §5.
- **Pendiente asociado**: decidir `target_sex` (¿escolar único `target_sex` o
  colección `list_sexes`? hoy es objeto único en el contrato).

### C15 — ¿`target_*` (sex/age/population) dentro de `condition`? ⏳ (abierto)

- **Qué**: evaluar si `target_sex`, `age_group` y `population` deberían modelarse
  como **parte de `condition`** (AST de visibilidad del form) en lugar de tablas
  propias, ya que "a quién aplica" es afín a "cuándo es visible".
- **Estatus**: **sin decidir**. No bloquea la definición ni el banco actual.
- **Reflejo**: nota de diseño en `catalog/ERD.mmd` (NOTAS DE DISENO) y en
  `schema.sql` (header de `target_sex`).
- **A decidir**: semántica (visibilidad vs. metadata consultable), impacto en
  reportes/filtros y en `condition`.

### C16 — Rangos: `min`/`max`/`unit` + `name` legible (Diseño C) ✅ (resuelto)

- **Qué era**: `age_group` usaba `min_age`/`max_age`; `estimated_duration`
  `min_minutes`/`max_minutes` + `description`; `config` usaba `min`/`max`.
  Naming mixto e incapaz de expresar unidades (meses en pediatría, seg/h).
- **Decisión (Diseño C)**: rangos genéricos `{ name, min, max, unit }`.
  - `min`/`max` (sin sufijo de dimensión) + `unit` (`EUnit`: `SECOND`, `MINUTE`,
    `HOUR`, `DAY`, `WEEK`, `MONTH`, `YEAR`).
  - `name` = **etiqueta legible** de la fuente para UI; se renombra
    `estimated_duration.description` → `name`. No se usa `description` para
    etiquetas.
  - El texto literal de la fuente (caso 3) vive en `name`; el valor en
    `min`/`max`/`unit`. Ej.: `>60` → `{ name: ">60", min: 61, unit: "YEAR" }`.
- **Reflejo**: `schema.sql` (`EUnit`, `age_group`, `estimated_duration`),
  `catalog/ERD.mmd`, `catalog/CLASS.mmd`, `catalog/README.md` §5,
  `catalog/example.jsonc`, `catalog/bank/README.md` (plantilla + regla),
  `reference/questionnaire-engine.md` (nota de destino).
- **Pendiente**: `question.config` (¿también `unit`? hoy fuera de alcance).

### C17 — `question.text` nullable (ítem sin enunciado propio) ✅ (resuelto)

- **Qué era**: `question.text` era `NOT NULL`, pero hay instrumentos cuyos ítems
  **no tienen enunciado propio** (ej. **CDI**, formato "elige la frase": las 3
  opciones *son* las frases y no existe un enunciado separado).
- **Decisión (modelo)**: `question.text` es **nullable**. El modelo guarda
  `text: null` + las opciones del ítem; las **instrucciones generales** del
  instrumento viven **una sola vez** en `form.instructions`.
- **Presentación (no es modelo)**: cómo se da **contexto** a un ítem con
  `text: null` es decisión de la **capa de presentación** (frontend, móvil, CLI,
  API…), no del modelo. Opciones válidas:
  - mostrar `form.instructions` **una vez** por bloque/carrusel de preguntas, o
  - **replicarlo en cada ítem** (mostrar la instrucción antes de sus opciones).
  El modelo **no** impone "solo las opciones".
- **Reflejo**: `schema.sql` (`question.text` sin `NOT NULL` + `COMMENT`),
  `catalog/ERD.mmd`, `catalog/CLASS.mmd`, `catalog/README.md` §5 (nota),
  `catalog/bank/README.md` (convención), `features/questionnaires/README.md`
  (tabla de decisiones).
- **Ejemplo**: `cdi` (los 27 ítems con `text: null`, `instructions: "En las últimas dos semanas"`).

### C18 — `form.type` (`EFormType`) ✅ (resuelto)

- **Qué era**: el banco usaba `kind` (`INSTRUMENT`/`CLINICAL_HISTORY`) **sin
  definición en el modelo** (ni `schema.sql`/ERD/CLASS/contrato).
- **Decisión**: formalizar como **`form.type`** (enum **`EFormType`**) =
  `INSTRUMENT | CLINICAL_HISTORY | SURVEY | FORM`. Se usa `type` (no `kind`) por
  consistencia con los enums del repo (`E*Type`) y porque `form.type` y
  `question.type` (`EQuestionType`) son ejes distintos en entidades distintas.
  - "Evaluación académica" = `INSTRUMENT` + `industry: education` (no un `type` propio).
- **Reflejo**: `schema.sql` (+`EFormType` +`form.type` +`COMMENT`),
  `catalog/ERD.mmd`, `catalog/CLASS.mmd`, `catalog/README.md` §5,
  `catalog/example.jsonc`, `catalog/bank/README.md` y los 8
  `bank/instruments/*.json` (`kind`→`type`), `features/README.md`,
  `features/questionnaires/README.md`, `features/clinical_history/README.md`.

## D. Motor frontend

### D12 — Solo 3 tipos soportados

- **Qué**: el motor del frontend implementa solo
  `SINGLE_CHOICE | MULTIPLE_CHOICE | TEXT`. Falta soporte para `RANGE`,
  `TIMER`, `NUMBER`, `DATE`, `DATE_TIME`, `TEXT_LONG`.
- **Incluye**: migrar el evaluador de condiciones a la **condición AST** (hoy
  evalúa la forma plana `{all}`/`{any}` + `ConditionRule[]`, sin anidación ni
  `none`). Con el contrato nuevo, `conditions.ts` trataría el elemento como
  siempre visible (fallo silencioso). Ver
  [`expressions/conditions.md`](../../../features/questionnaires/expressions/conditions.md) §5.
- **Incluye**: migrar el `AnswerMap` en memoria al envelope `{value, type}`
  (C9). Hoy es provisional: sin tipo y aplanado. Ver `catalog/README.md` §8.
- **Incluye**: soportar el motor de expresiones ampliado — **`definitions` +
  `{ref}`**, **`time: minutes`** y **`case` condition-based** (C7b), además de
  la condición AST.
- **Refs**: `docs/features/questionnaires/reference/questionnaire-engine.md:23`
  (describe el **estado actual implementado**, no el objetivo).
- **Objetivo**: `catalog/question_types/` (9 tipos) + AST completo
  (condición, definitions/ref, time:minutes, case condition-based).

## E. Higiene

### E13 — Ruido en `app_questionnaire` ✅ (resuelto)

- **Acción**: se **eliminaron** (repo `app_questionnaire`, rama `dev`, commit
  `086f3b1`):
  - `backend/docs/cuestionarios/TMP_SQL.JS` (0 bytes)
  - `backend/docs/cuestionarios/TMP_SQL2.ts` (0 bytes)
  - `backend/docs/types/chatgpt_.ts` (borrador de IA; su idea útil —selectores
    `id`/`range`— ya estaba rescatada; lo demás cubierto por A1/A2/C7c).
- **Reflejo**: nota de `expressions/operands.md` reescrita (ya no apunta a la
  ruta eliminada).

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
