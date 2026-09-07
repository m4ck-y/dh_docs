# Catálogo de Cuestionarios — Definición de Modelo

**Status:** En definición (pendiente)

> Este documento define el modelo canónico del **catálogo de cuestionarios**.
> El modelo de **respuestas** se define aparte en
> `docs/features/questionnaires/ERD_responses.mmd` (ver el README de esa carpeta).
> Compara cuatro fuentes para unificar la representación de los instrumentos antes
> de fijar los JSON finales por cuestionario. Aún **no** se definen los JSON
> definitivos de cada instrumento.

## 1. Propósito

Definir una única forma de representar cada cuestionario (metadata + preguntas
+ scoring/interpretación + condiciones) que sirva de base para:

1. El **mock del frontend** (motor de cuestionarios ya existente).
2. El futuro **modelado de BD y API** del backend.

No es una migración legacy→frontend; es una definición de dominio.

## 2. Cuatro fuentes comparadas

| # | Fuente | Naturaleza | Rol en la comparación |
|---|--------|-----------|------------------------|
| 1 | `other_projects/app_questionnaire/backend/docs/` | Modelo ejecutable de referencia (`.json` + `.ts` + tipos de expresiones + `conditional`) | **Referencia de modelado** |
| 2 | `frontend/dh_frontend_app/src/domain/questionnaire-engine/` | Motor + bancos ya implementados en el MVP frontend (`types.ts`, `banks/*.ts`, `scoring.ts`, `conditions.ts`) | **Estado actual implementado** |
| 3 | `docs/diagrams/` | `.mmd` + `-review.md` generados desde drawio | **Lógica de negocio / flujo** |
| 4 | `reference_projects/reference_questionnaire_v1_legacy/FormsFlow2.drawio` | Diagrama drawio (3 pestañas: catálogo, detail-JSON, ejecución) | **Referencia de persistencia** → volcada a `docs/features/questionnaires/ERD_questionnaires.mmd` |

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
- Destino pulido: `docs/features/questionnaires/ERD_questionnaires.mmd`.
- Convención de nombres de ERDs y ejemplos JSON:
  `docs/features/questionnaires/README.md`.

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
| `list_questions[]` `{id,type,text,order,list_options,condition}` | ✅ | ✅ | Ver §6 |
| `list_options` `{text,value,id,url}` | ✅ | ✅ (`url` opcional/extra) | Igual |
| `list_sections` `[]` | ✅ | ❌ ausente | **gap** |
| `list_references` `[]` | ✅ | ❌ ausente | **gap** |
| `target_sex` | ✅ (`null`) | ❌ ausente | **gap** |

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
  target_sex?: null | string;                 // gap a cubrir
  list_references?: { url_reference?: string; name?: string; type?: string }[]; // gap a cubrir
  list_sections?: unknown[];                  // gap a cubrir

  scoring?: Scoring;                          // extensión MVP
  interpretacion?: InterpretationRange[];     // extensión MVP
  list_questions: Question[];
}
```

> Los campos marcados como *"gap"* (`target_sex`, `list_references`,
> `list_sections`) existen en la referencia pero aún no están tipados en el MVP;
> pendientes de decidir si se incorporan.

## 6. Preguntas y condiciones

El MVP ya implementa visibilidad condicional **más rica** que la referencia:

| Aspecto | `app_questionnaire` `conditional` | MVP `conditions.ts` |
|---|---|---|
| Forma del bloque | `{ type: 'all'|'any'|'none', rules[] }` | Acepta `{all}|{any}` **y** `{type,rules}` (legado) |
| Operadores | `==`,`!=`,`>`,`<`,`>=`,`<=` | Los mismos **+** `includes`,`notIncludes`,`in`,`notIn`,`exists`,`notEmpty` |
| Anidación | Sí (`rules[]` puede contener `SchemaCondition`) | No (aplanado) |
| Valores string | Comparación tipada estricta | Coerción numérica suave (`coerce`) |

### Objeto `answer` (modelo persistido vs. memoria)

El modelo persistido de respuestas ya está definido en
`docs/features/questionnaires/ERD_responses.mmd`: `answer { id_assignment,
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

## 7. Scoring e interpretación

Dos representaciones coexisten y deben unificarse:

| Forma | Fuente | Cómo |
|---|---|---|
| Rangos `interpretacion[]` `{desde,hasta,texto}` + `scoring.tipo` | MVP `bank/*.ts` + `scoring.ts` | `suma` / `subescalas` sobre `maximo` |
| `case/when` (`OperandExpression`) | Referencia `.ts` + `typescript.ts` | Expresiones `aggregate/sum(avg)` + `case/when` con `default` |

**Ejemplo PHQ-9 (concordancia de bandas):**

| Escala | MVP `phq9Instrument.ts` | Referencia `PHQ9.ts` |
|---|---|---|
| Mínima | 0–4 | `<5` |
| Leve | 5–9 | `<10` |
| Moderada | 10–14 | `<15` |
| Moderadamente severa | 15–19 | `<20` |
| Severa | 20–27 | `<=27` |

Ambas coinciden; solo difieren en la representación (rangos cerrados vs `case/when`).

**Ejemplo IPAQ (scoring no lineal):** la referencia usa METs
(`caminar=3.3`, `moderada=4`, `vigorosa=8` × minutos × días). El MVP aún no
modela scoring por METs; pendiente.

## 8. Concordancia por instrumento compartido

Instrumentos presentes en las tres fuentes y estado de alineación.

| Instrumento | `docs/diagrams` | `banks/` (MVP) | Referencia `app_questionnaire` | Notas |
|---|---|---|---|---|
| PHQ-9 | ✅ `phq.mmd` | ✅ `phq9Instrument.ts` | ✅ `.json`/`.ts` | ⚠️ redacción ítem 7 difiere (ver §9) |
| GDS | ✅ `gds.mmd` | ✅ `gdsInstrument.ts` (15 ítems) | ❌ solo CSV | — |
| HADS | ✅ `hads.mmd` | ✅ `hadsInstrument.ts` | ✅ solo CSV | — |
| CDI | ✅ `cdi.mmd` | ✅ `cdiInstrument.ts` | ✅ solo CSV | ítem 25 invertido (ambos) |
| GAD-7 | ✅ `gad.mmd` | ✅ `gad7Instrument.ts` | ✅ solo CSV | — |
| SF-12 | ❌ | ✅ `sf12Instrument.ts` | ✅ `.json`/`.md` | — |
| CRAFFT | ✅ `2_CUESTIONARIO_SOCIAL` | ❌ | ✅ `.json`/`.md` | — |
| IPAQ | ✅ `3_CUESTIONARIO_FISICO` | ❌ | ✅ `.json`/`.ts`/`.md` | — |

Instrumentos solo en `banks/` (sin `.mmd` ni referencia JSON): `asrs`, `cth`,
`dts`, `eag`, `edah`, `spin`, `tas20`.

## 9. Discrepancias detectadas

1. ~~GDS — banco del MVP con 14 ítems.~~ Resuelto: drawio, Mermaid y
   `gdsInstrument.ts` ya alineados a GDS-15 (15 ítems, bandas 0-4/5-9/10-15).

2. **PHQ-9 ítem 7 — redacción divergente.**
   - MVP `phq9Instrument.ts` + legacy: "leer el **cuerpo del texto**".
   - Drawio MVP + referencia `.json`: "leer el **periódico**".
   - Por definir cuál es la fuente de verdad del copy.

3. **Gaps del contrato `Instrument`** (presentes en referencia, ausentes en MVP):
   `target_sex`, `list_references`, `list_sections`.

4. **IPAQ scoring por METs** no modelado en el MVP (solo en la referencia).

## 10. Pendientes

- [ ] PHQ-9: fijar redacción del ítem 7.
- [x] Definir formalmente el modelo de **respuestas** (`answer`): modelado en
      `docs/features/questionnaires/ERD_responses.mmd` (modelo V2). Pendiente
      alinear el DDL (`db_ddl.sql`) con este modelo.
- [ ] Decidir forma única de scoring: rangos `interpretacion[]` vs `case/when`.
- [ ] Cubrir gaps de `Instrument`: `target_sex`, `list_references`, `list_sections`.
- [ ] Generar los JSON finales por cuestionario (cuando confluyan las fuentes).
- [ ] Modelo de persistencia del catálogo: se deriva de `FormsFlow2.drawio` (fuente 4), cuyo destino pulido es `docs/features/questionnaires/ERD_questionnaires.mmd`.
- [ ] Modelo de ejecución (V2) → DDL: reemplazar `form_direct_responses` /
      `scheduled_responses` por el modelo `assignment` como tarea/evento con
      `answer`, o marcar `db_ddl.sql` como legacy en su sección de ejecución.

## 11. Fuera de alcance (por ahora)

- No se crean los JSON definitivos de cada cuestionario.
- No se generan `.json`/`.ts` ejecutables nuevos en este documento.
- No se toca `migrations/` (su alcance es legacy→frontend).
