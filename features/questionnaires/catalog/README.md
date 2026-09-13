# Capa catálogo — Definición del instrumento

Modelo canónico del **catálogo de cuestionarios**: la definición del instrumento
(metadata + preguntas + scoring/interpretación + condiciones). Compara cuatro
fuentes para unificar la representación antes de fijar los JSON finales por
cuestionario. Aún **no** se definen los JSON definitivos de cada instrumento.

La capa de **ejecución** (respuestas) se documenta aparte en
[`../responses/`](../responses/).

## 1. Propósito

Definir una única forma de representar cada cuestionario que sirva de base para:

1. El **mock del frontend** (motor de cuestionarios ya existente).
2. El futuro **modelado de BD y API** del backend.

No es una migración legacy→frontend; es una definición de dominio.

## 2. Cuatro fuentes comparadas

| # | Fuente | Naturaleza | Rol en la comparación |
|---|--------|-----------|------------------------|
| 1 | `other_projects/app_questionnaire/backend/docs/` | Modelo ejecutable de referencia (`.json` + `.ts` + tipos de expresiones + `conditional`) | **Referencia de modelado** |
| 2 | `frontend/dh_frontend_app/src/domain/questionnaire-engine/` | Motor + bancos ya implementados en el MVP frontend (`types.ts`, `banks/*.ts`, `scoring.ts`, `conditions.ts`) | **Estado actual implementado** |
| 3 | `docs/diagrams/` | `.mmd` + `-review.md` generados desde drawio | **Lógica de negocio / flujo** |
| 4 | `reference_projects/reference_questionnaire_v1_legacy/FormsFlow2.drawio` | Diagrama drawio (3 pestañas: catálogo, detail-JSON, ejecución) | **Referencia de persistencia** → volcada a `ERD.mmd` |

## 3. Referencias

### 3.1 `other_projects/app_questionnaire/backend/docs/` (referencia de modelado)

- `other_projects/app_questionnaire/backend/docs/cuestionarios/PHQ9.json` — schema de catálogo canónico.
- `other_projects/app_questionnaire/backend/docs/cuestionarios/IPAQ.json`, `SF12.json`, `CRAFFT.json`, `C-SSRS`.
- `other_projects/app_questionnaire/backend/docs/cuestionarios/PHQ9.ts`, `IPAQ.ts` — scoring/interpretación (`case/when`, METs) y condiciones.
- `other_projects/app_questionnaire/backend/docs/my_arquitecture/question/conditional.md` — objeto `conditional` (`type: all/any/none` + `rules`).
- `other_projects/app_questionnaire/backend/docs/types/typescript.ts` — lenguaje de expresiones (`OperandExpression`, operadores).
- `other_projects/app_questionnaire/backend/docs/cuestionarios_metadata.csv` — catálogo global (columna `LS` = categoría de bienestar).

### 3.2 `frontend/dh_frontend_app/src/domain/questionnaire-engine/` (estado actual)

- `types.ts` — contrato `Instrument`, `Question`, `QuestionOption`, `QuestionCondition`, `Scoring`, `InterpretationRange`, `Subscale`.
- `banks/` — 13 instrumentos: `phq9`, `gds`, `hads`, `cdi`, `gad7`, `asrs`, `cth`, `dts`, `eag`, `edah`, `sf12`, `spin`, `tas20`.
- `scoring.ts` — cálculo de puntuación (`suma` y `subescalas`) e interpretación por rangos.
- `conditions.ts` — visibilidad condicional (operadores `==`,`!=`,`>`,`>=`,`<`,`<=`,`includes`,`notIncludes`,`in`,`notIn`,`exists`,`notEmpty`).
- `unlock.ts`, `progress.ts`, `runner-state.ts` — orquestación del flujo.

### 3.3 `docs/diagrams/` (lógica de negocio / flujo)

- `docs/diagrams/SKILL_DRAWIO_MERMAID.md` — convención drawio→mermaid.
- `docs/diagrams/0_HISTORIA_CLINICA/`, `1_CUESTIONARIO_MENTAL/`, `2_CUESTIONARIO_SOCIAL/`, `3_CUESTIONARIO_FISICO/`.
- `docs/diagrams/README.md` — pendientes (GDS ítem 15).

### 3.4 `reference_projects/reference_questionnaire_v1_legacy/FormsFlow2.drawio` (referencia de persistencia)

- `FormsFlow2.drawio` — 3 pestañas: `Página-1` (ERD de definición), `FORM_DETAIL-ERD-JSON` (JSON aplanado), `anwers` (ERD de ejecución + DDL SQL + endpoints FastAPI).
- Conversión a Mermaid y documentación de código: `pagina_1.*`, `form_detail_erd_json.*`, `anwers.*`, `index.md` en la misma carpeta.
- Destino pulido: `ERD.mmd`.
- Convención de nombres de ERDs y ejemplos JSON: [`../README.md`](../README.md).

> Nota: el `.drawio` es el **primer modelo de datos** (retomado), se **conserva**
> como referencia histórica; su forma pulida se desarrolla en
> `docs/db/postgres/form/`. No se elimina.

## 4. Matriz de concordancia de campos

Comparación del schema de catálogo de la referencia (`app_questionnaire` `.json`)
contra el contrato `Instrument` del MVP frontend (`types.ts`).

| Campo (referencia `.json`) | `app_questionnaire` | MVP `Instrument` (`types.ts`) | Observación |
|---|---|---|---|
| `id` / `key` / `name` / `description` | ✅ | ✅ | Igual |
| `list_categories` `{key_industry,name}` | ✅ | ✅ | Igual |
| `list_cie11_codes` `{code}` | ✅ | ✅ | Igual |
| `list_evaluation_topics` | ✅ (`{id,name,key_industry}`) | ✅ (`{name,key_industry}`, sin `id`) | MVP simplificado |
| `estimated_duration` | ✅ | ✅ | Igual |
| `target_age_group` `{name,min_age,max_age}` | ✅ | ✅ | Igual |
| `list_questions[]` `{id,type,text,order,list_options,condition}` | ✅ | ✅ | Ver §8 |
| `list_options` `{text,value,id,url}` | ✅ | ✅ (`url` opcional/extra) | Igual |
| `list_sections` `[]` | ✅ (siempre vacío) | ✅ `Section[]` (espejo del ERD) | Forma propia del proyecto, ver §5 y ADR 038 |
| `list_references` `[]` | ✅ | ✅ `Reference[]` | Resuelto (era gap) |
| `target_sex` | ✅ (`null`) | ✅ objeto `{type_biological_sex,id}` | Inconsistencia corregida: el ejemplo ya lo modelaba así; no era gap (ver §11) |

### Extensiones del MVP (no existen en la referencia)

| Campo | Descripción |
|---|---|
| `area` / `area_desc` | Categoría clínica (p. ej. `Emocional`) para render/agrupación |
| `instrucciones` | Texto introductorio del cuestionario |
| `scoring` `{tipo:'suma'|'subescalas', maximo, items, subescalas[]}` | Configuración de puntuación |
| `interpretacion[]` `{desde, hasta, texto, subescala?}` | Rangos de interpretación |

## 5. Esquema del catálogo (propuesto, espejo de la referencia)

Modelo canónico objetivo (unión de las tres fuentes), **sin JSON finales aún**:

```ts
interface Instrument {
  id: string;
  key: string;
  name: string;
  description: string;
  area?: string;                 // extensión MVP
  area_desc?: string;            // extensión MVP
  instrucciones?: string;        // extensión MVP

  list_categories: { key_industry: number; name: string }[];
  list_cie11_codes: { code: string }[];
  list_evaluation_topics: { id?: number; name: string; key_industry?: string }[];

  estimated_duration?: { min_minutes?: number; max_minutes?: number; description?: string };
  target_age_group?: { name?: string; min_age?: number; max_age?: number };
  target_sex?: { type_biological_sex: EBiologicalSex; id?: number };   // espeja target_sex del ERD
  list_references?: Reference[];
  list_sections?: Section[];     // XOR con list_questions (ver §7 y ADR 038)

  scoring?: Scoring;                          // extensión MVP
  interpretacion?: InterpretationRange[];     // extensión MVP
  list_questions: Question[];                 // preguntas directas (XOR con list_sections)
}

interface Reference {
  id?: number;
  url_reference?: string;
  name?: string;
  notes?: string;
  url_thumbnail?: string;
  type_media?: string;           // forma real en la referencia (PHQ9.json); ver §11
}

interface Section {
  id: number;                    // uuid externo en el modelo relacional
  key?: string;
  name?: string;
  description?: string;
  order: number;                 // section.order (vive en la entidad, ver §7)
  list_questions: Question[];    // preguntas embebidas, con order propio en la sección
}
```

> **`list_sections` no es un gap**: su forma sale del ERD del proyecto (tabla
> `section` + puente `questions_section`), no del `[]` vacío de la referencia.
> Ver [ADR 038](../../decisions/038-formulario-preguntas-vs-secciones.md).

## 6. Tipos de pregunta y `config`

Cada `question` tiene un `type` (`EQuestionType`) y una configuración `config`
(JSONB) cuya **forma depende del tipo**. El detalle por tipo vive en
[`question_types/`](./question_types/):

| Tipo | `config` (campos propios) | `answer.value` |
|---|---|---|
| `TEXT` | required, max_length | `string` |
| `TEXT_LONG` | required, max_length, multiline | `string` |
| `NUMBER` | required, min_value, max_value, decimals | `number` |
| `SINGLE_CHOICE` | required, shuffle | `number` |
| `MULTIPLE_CHOICE` | required, shuffle, min_selected, max_selected | `number[]` |
| `DATE` | required, min_date, max_date | `string` (`YYYY-MM-DD`) |
| `DATE_TIME` | required, min_date, max_date | `string` (ISO 8601) |
| `TIMER` | required, min_value, max_value, precision | `string` (ISO 8601 duration) |
| `RANGE` | required, min_value, max_value, step, integer | `number` |

- `required` es común a **todos** los tipos.
- `RANGE` y `TIMER` fueron **rescatados** de `app_questionnaire`
  (`my_arquitecture/question/types/`); evidencia de uso en `cuestionarios/IPAQ.json`.
- La coherencia de `config` con `type` se valida en la capa de aplicación
  (Pydantic), igual que `answer.value`.

## 7. Regla de orden (dónde vive `order`)

**El orden pertenece a la relación, no a la entidad**, porque un mismo elemento
puede reutilizarse en varios contextos con posiciones distintas.

| Elemento | Dónde vive su `order` | Por qué |
|---|---|---|
| `option` | **En `option`** (entidad propia) | Una opción pertenece a una **única** pregunta; no se comparte. |
| `question` | **En `questions_form` / `questions_section`** | La pregunta es un **átomo reutilizable**: su posición depende del formulario o sección que la usa. |

- `question` **no tiene** columna `order`. Su orden se define en:
  - `questions_form.order` → posición de la pregunta dentro de un formulario.
  - `questions_section.order` → posición de la pregunta dentro de una sección.
- `section.order` sí vive en la entidad, porque una sección pertenece a un único
  formulario.
- Una misma pregunta puede aparecer en el **Form A** en la posición 1 y en el
  **Form B** en la posición 7: eso lo permite tener el orden en la puente.
- `option.order` es el orden **canónico**; si la pregunta usa `shuffle`
  (presentación aleatoria, ver §6), `option.order` sigue siendo la referencia
  estable para scoring.

### Exclusividad: preguntas directas XOR secciones

Un formulario se compone de **preguntas directas** (`list_questions` /
`questions_form`) **o** de **secciones** (`list_sections` / `section` +
`questions_section`), **nunca de ambas**. Las secciones agrupan sus propias
preguntas; un formulario con secciones no tiene preguntas directas.

- Es una **regla de aplicación** (Pydantic + `COMMENT` en el DDL), no un
  constraint de BD: PostgreSQL no permite un `CHECK` XOR entre tablas.
- En el payload, `list_sections` es el espejo del ERD; su forma se define en §5.
- Justificación y consecuencias: [ADR 038](../../decisions/038-formulario-preguntas-vs-secciones.md).

## 8. Condiciones de visibilidad

La condición decide si un elemento **se muestra u oculta**, y se modela como
**expresión AST booleana** en una columna **JSONB** del propio elemento
([ADR 039](../../decisions/039-condicion-visibilidad-ast.md)):

| Nivel | Campo | Significado |
|---|---|---|
| Formulario | `form.condition` | El formulario se habilita si… |
| Sección | `section.condition` | La sección se muestra si… |
| Pregunta | `question.condition` | La pregunta se muestra si… |

- Ausente/`null` = **siempre visible**.
- Las tablas `conditional_logic` y `form_condition` **ya no existen**.
- Controla **solo visibilidad** (no skip logic ni "requerido condicional").
- Gramática, ejemplos y traducción desde la referencia:
  [`../expressions/conditions.md`](../expressions/conditions.md).

### Comparación con la referencia y el MVP

| Aspecto | `app_questionnaire` `conditional` | AST (`condition`) |
|---|---|---|
| Forma | `{ type: 'all'|'any'|'none', rules[] }` | `OperandExpression` (`logic`/`comparison`/`collection`) |
| Anidación | Sí (un nivel por `rules[]`) | Sí, ilimitada |
| Rango de preguntas | N reglas repetidas | Un selector (`range`) |
| Almacenamiento | Columna JSONB | Columna JSONB |

> El **motor del frontend** (`conditions.ts`) aún evalúa la forma plana
> `{all}`/`{any}` + `ConditionRule[]`, no el AST. Migrarlo es parte de **D12**
> (fase frontend).

### Objeto `answer` (modelo persistido vs. memoria)

El modelo persistido de respuestas ya está definido en
[`../responses/ERD.mmd`](../responses/ERD.mmd): `answer { id_assignment,
id_question, answered_by, value (JSON) }`.

```ts
// Forma en memoria que usa el motor del frontend (independiente del ERD).
type AnswerValue = number | number[] | string;
type AnswerMap = Record<string, AnswerValue>; // { id_question: value }
```

La referencia modela la respuesta persistida como `answer { id_assignment,
id_question, answer(JSON tipo+valor) }`. El ERD (`answer` con `answered_by` +
`value JSON`) ya recoge esa forma; queda pendiente alinear el `AnswerMap` en
memoria del frontend con el valor JSON persistido.

## 9. Scoring e interpretación

La forma **canónica** es el **AST de expresiones** del proyecto, documentado en
[`../expressions/README.md`](../expressions/README.md):

- **`scoring_expression`** (form) → `aggregate` (`sum`/`avg`) que produce el
  puntaje numérico.
- **`evaluation_expression`** (form) → `case/when` que clasifica el puntaje en
  una categoría de texto. Su `subject` **consume** `form.scoring_result` (no
  repite la fórmula del scoring).
- **Subescalas**: arreglo `subscales[]`, cada una con su par de expresiones.
- **Resultados**: `assignment.scoring_result` / `evaluation_result` = `{value,
  data_type}` (espejan el `const` del AST).

El MVP del frontend usa todavía una **forma simplificada** (rangos), que se
documenta como origen y a migrar (pendiente D12):

| Forma simplificada (MVP) | Forma canónica (AST) |
|---|---|
| `scoring.tipo: 'suma'` | `aggregate sum` |
| `scoring.tipo: 'subescalas'` | `subscales[]` |
| `interpretacion[] {desde,hasta,texto}` | `case/when` con umbrales acumulativos |
| `interpretacion[].subescala` | `subscales[]` |

**Ejemplo PHQ-9 (equivalencia de bandas):**

| Escala | MVP `phq9Instrument.ts` (rango) | AST `evaluation_expression` (umbral) |
|---|---|---|
| Mínima | 0–4 | `<5` |
| Leve | 5–9 | `<10` |
| Moderada | 10–14 | `<15` |
| Moderadamente severa | 15–19 | `<20` |
| Severa | 20–27 | `<=27` |

Ambas coinciden en el resultado; difieren en la representación (rango inclusivo
vs umbral). La traducción rango→umbral es trivial para enteros.

**Ejemplo IPAQ (scoring no lineal):** usa METs (`caminar=3.3`, `moderada=4`,
`vigorosa=8` × minutos × días). El AST puede expresarlo, pero **no se modela
todavía** (pendiente METs IPAQ en `../TODO/cuestionarios.md`).

## 10. Concordancia por instrumento compartido

Instrumentos presentes en las tres fuentes y estado de alineación.

| Instrumento | `docs/diagrams` | `banks/` (MVP) | Referencia `app_questionnaire` | Notas |
|---|---|---|---|---|
| PHQ-9 | ✅ `phq.mmd` | ✅ `phq9Instrument.ts` | ✅ `.json`/`.ts` | ⚠️ redacción ítem 7 difiere (ver §11) |
| GDS | ✅ `gds.mmd` | ✅ `gdsInstrument.ts` (15 ítems) | ❌ solo CSV | — |
| HADS | ✅ `hads.mmd` | ✅ `hadsInstrument.ts` | ✅ solo CSV | — |
| CDI | ✅ `cdi.mmd` | ✅ `cdiInstrument.ts` | ✅ solo CSV | ítem 25 invertido (ambos) |
| GAD-7 | ✅ `gad.mmd` | ✅ `gad7Instrument.ts` | ✅ solo CSV | — |
| SF-12 | ❌ | ✅ `sf12Instrument.ts` | ✅ `.json`/`.md` | — |
| CRAFFT | ✅ `2_CUESTIONARIO_SOCIAL` | ❌ | ✅ `.json`/`.md` | — |
| IPAQ | ✅ `3_CUESTIONARIO_FISICO` | ❌ | ✅ `.json`/`.ts`/`.md` | — |

Instrumentos solo en `banks/` (sin `.mmd` ni referencia JSON): `asrs`, `cth`,
`dts`, `eag`, `edah`, `spin`, `tas20`.

## 11. Discrepancias detectadas

1. ~~GDS — banco del MVP con 14 ítems.~~ Resuelto: drawio, Mermaid y
   `gdsInstrument.ts` ya alineados a GDS-15 (15 ítems, bandas 0-4/5-9/10-15).

2. **PHQ-9 ítem 7 — redacción divergente.**
   - MVP `phq9Instrument.ts` + legacy: "leer el **cuerpo del texto**".
   - Drawio MVP + referencia `.json`: "leer el **periódico**".
   - Por definir cuál es la fuente de verdad del copy.

3. **Gaps del contrato `Instrument`**: `list_references` y `list_sections`.
   Resuelto: se incorporan al contrato (§4/§5). `list_sections` es el espejo del
   ERD (no un gap real); `list_references` adopta la forma real de la referencia
   (`id`, `notes`, `url_thumbnail`, `type_media`), corrigiendo el README §5 previo.
   Ver [ADR 038](../../decisions/038-formulario-preguntas-vs-secciones.md).

4. ~~**`target_sex` inconsistente.**~~ Resuelto: el `example.jsonc` ya lo modelaba
   como objeto `{type_biological_sex, id}` (espejo del ERD), mientras el README §5
   lo declaraba `null | string` y como gap. Corregido en §5; no era un gap real.

5. **IPAQ scoring por METs** no modelado todavía. El AST puede expresarlo, pero
   se difiere (pendiente METs IPAQ en `../TODO/cuestionarios.md`). El único
   algoritmo completo está en `docs/diagrams/3_CUESTIONARIO_FISICO/IPAQ.pseint`.

6. **`type_media` vs `type` en `list_references`**: la referencia usa `type_media`
   (`PHQ9.json`, `IA_DEVELOPMENT.json`); el ERD define `reference.type_media`
   (enum `EUrlType`). Se adopta `type_media` en el contrato; el modelo V1/legacy
   usaba `type`.

7. **Scoring en `schema.sql` corregido**: los ejemplos previos de
   `scoring_expression` (`{"op":"sum","fields":[...]}`),
   `evaluation_expression` (`{"if":[{"gte":...}]}`) y `scoring_result` (que
   repetía la receta) **no existían** en ninguna gramática. Se alinearon al AST
   (`../expressions/README.md`).

8. **`PHQ9.ts` de la referencia**: declara `operator: "avg"` con comentario
   "Promedio en lugar de suma", pero el total clínico (0–27) requiere `sum`. Se
   adopta `sum` como correcto.

9. **Condición de visibilidad**: las tablas `conditional_logic` y `form_condition`
   (con `formula`/`expression TEXT`) se **eliminaron** en favor de columnas JSONB
   `form.condition` / `section.condition` / `question.condition`, con el AST
   booleano. Coincide con `column_or_table.md` de la referencia (que ya recomendaba
   columna JSON). Ver [ADR 039](../../decisions/039-condicion-visibilidad-ast.md)
   y [`../expressions/conditions.md`](../expressions/conditions.md).

## 12. Pendientes de esta capa

- [ ] PHQ-9: fijar redacción del ítem 7.
- [x] Forma única de scoring: **AST canónico** (`../expressions/README.md`); el
      MVP de rangos queda como forma simplificada a migrar (D12).
- [x] Cubrir gaps de `Instrument`: `list_references` y `list_sections` (ADR 038).
      `target_sex` no era gap: se corrigió la contradicción del ejemplo vs §5.
- [x] Condición de visibilidad: AST JSONB en form/section/question (ADR 039).
- [ ] Generar los JSON finales por cuestionario (cuando confluyan las fuentes).
- [ ] Alinear el `AnswerMap` en memoria del frontend con el valor JSON persistido
      (ver §8).

## 13. Fuera de alcance (por ahora)

- No se crean los JSON definitivos de cada cuestionario.
- No se generan `.json`/`.ts` ejecutables nuevos en este documento.
- No se toca `migrations/` (su alcance es legacy→frontend).

## Archivos de esta capa

| Archivo | Contenido |
|---|---|
| `ERD.mmd` | ERD relacional de la definición (`form`, `question`, metadata, puentes). |
| `CLASS.mmd` | Diagrama de clases / vista de documentos (MongoDB) del catálogo. |
| `example.jsonc` | Ejemplo de payload del catálogo (JSON con comentarios). |
| `question_types/` | Un doc por tipo de pregunta (`question.type`) con su `config` y `answer.value`. |

> El **lenguaje de expresiones** (`scoring_expression` / `evaluation_expression`)
> vive en [`../expressions/`](../expressions/), a nivel del módulo (no dentro de
> `catalog/`), porque es transversal a definición y ejecución.
