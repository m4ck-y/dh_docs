# Schema del motor de cuestionarios (`questionnaire-engine`)

Documentación del contrato de datos de los instrumentos psicométricos tal como
están representados en `frontend/ls_frontend_app/src/domain/questionnaire-engine/`.

- **Definición de tipos**: `domain/questionnaire-engine/types.ts`
- **Bancos de instrumentos**: `domain/questionnaire-engine/banks/*Instrument.ts`
  (13 instrumentos, cada uno `export default { ... } satisfies Instrument`).
- **Fuente de origen**: contrato `dh_forms` (legacy), portado con **extensiones
  de parity legada** (`scoring` + `interpretacion`).

> Los cuestionarios **NO están como JSON**: cada banco es un objeto TypeScript
> tipado con `satisfies Instrument`. El copy de las preguntas/opciones se
> mantiene en **español**; los identificadores de código en inglés.

---

## 1. Tipos base

### 1.1 `QuestionType`

```ts
export type QuestionType = 'SINGLE_CHOICE' | 'MULTIPLE_CHOICE' | 'TEXT';
```

| Valor | Significado |
|---|---|
| `SINGLE_CHOICE` | Una opción entre varias (valor numérico). |
| `MULTIPLE_CHOICE` | Varias opciones (`value` como `number[]`). |
| `TEXT` | Respuesta libre (texto). |

### 1.2 `QuestionOption`

```ts
export interface QuestionOption {
  value: number;
  text: string;
  /** dh_forms extras preserved verbatim. */
  [extra: string]: unknown;
}
```

- `value`: valor numérico usado para scoring.
- `text`: texto visible de la opción (español).
- En el banco se escribe además `id: number` y `url: null` (campos `dh_forms`
  conservados vía index signature).

### 1.3 `Question`

```ts
export interface Question {
  id: number;
  order?: number;
  text: string;
  type: QuestionType;
  list_options?: QuestionOption[];
  conditional?: QuestionCondition | null;   // null = incondicional
  [extra: string]: unknown;
}
```

### 1.4 `Instrument` (raíz del banco)

```ts
export interface Instrument {
  id: string;                 // identificador ("HADS", "PHQ-9", ...)
  key: string;                // clave canónica (mismas que `id` en la práctica)
  name: string;
  description: string;
  area?: string;              // ej. "Emocional"
  instrucciones?: string;
  scoring?: Scoring;          // ausente => el instrumento no exporta score
  interpretacion?: InterpretationRange[];
  list_questions: Question[];
  target_age_group?: { min_age?: number; max_age?: number; name?: string; [extra: string]: unknown };
  estimated_duration?: { min_minutes?: number; max_minutes?: number; description?: string };
  [extra: string]: unknown;   // preserva list_categories, list_cie11_codes, etc.
}
```

**Campos `dh_forms` conservados verbatim** (vía index signature, no
re-declarados en el tipo): `area_desc`, `list_categories`, `list_cie11_codes`,
`list_evaluation_topics`, `list_references`, `target_sex`.

---

## 2. Scoring

```ts
export type Scoring = {
  tipo: 'suma' | 'subescalas';
  maximo?: number;
  items?: number[];       // solo para 'suma'
  subescalas?: Subscale[]; // solo para 'subescalas'
};

export interface Subscale {
  id: string;        // ej. "A", "D"
  nombre: string;    // ej. "Ansiedad", "Depresion"
  items: number[];   // ids de preguntas que suman en esta subescala
  maximo: number;
};
```

Reglas:
- `tipo: 'suma'` → suma los `items` indicados (o todos si `items` está ausente).
- `tipo: 'subescalas'` → produce una fila de score por subescala.
- Si `Instrument.scoring` es `undefined`, el instrumento **no exporta filas de
  score** (p. ej. cuestionarios solo informativos).

Ejemplo (HADS, `hadsInstrument.ts`): dos subescalas — `A` (ítems 1,3,5,7,9,11,13,
`maximo: 21`) y `D` (ítems 2,4,6,8,10,12,14, `maximo: 21`), `maximo: 42` global.

---

## 3. Interpretación

```ts
export interface InterpretationRange {
  desde: number;         // límite inferior (inclusivo)
  hasta: number;         // límite superior (inclusivo)
  texto: string;         // interpretación visible
  subescala?: string;    // opcional: aplica solo a una subescala
}
```

Reglas (`scoring.ts`):
- Match: `score >= desde && score <= hasta`.
- Si `subescala` está presente, el rango solo aplica a esa subescala
  (filtro por `Subscale.id`).
- Solo se interpreta un instrumento **completo** (`complete = true`); si no,
  retorna `null`.

---

## 4. Condicionales de visibilidad

```ts
export type ConditionOperator =
  | '==' | '!=' | '>' | '>=' | '<' | '<='
  | 'includes' | 'notIncludes' | 'in' | 'notIn' | 'exists' | 'notEmpty';

export interface ConditionRule {
  q?: number | string;        // forma interna
  id_question?: number | string; // forma dh_forms
  op?: ConditionOperator;     // forma interna
  operator?: ConditionOperator;  // forma dh_forms
  value?: unknown;
  [extra: string]: unknown;
}

export interface QuestionCondition {
  all?: ConditionRule[];   // forma interna
  any?: ConditionRule[];   // forma interna
  type?: string;           // forma dh_forms: 'all' | 'any'
  rules?: ConditionRule[]; // forma dh_forms
  [extra: string]: unknown;
}
```

Reglas (`conditions.ts`):
- Una pregunta con `conditional: null` es **siempre visible**.
- Se aceptan **dos shapes** y se normalizan a `{ all }` / `{ any }`:
  1. Interno: `{ all: [...] }` o `{ any: [...] }`.
  2. dh_forms: `{ type: 'all'|'any', rules: [{ id_question, operator, value }] }`.
- `{ all }` tiene prioridad sobre `{ any }` si ambos están presentes (parity
  legada).
- Coerción suave: strings numéricas se comparan como números.
- Semántica de respuesta ausente (parity `evalRule`): una respuesta ausente falla
  todo operador excepto un `!=` literal.
- `pruneHiddenAnswers` borra (en punto fijo) las respuestas de preguntas que
  quedaron ocultas, para que condicionales encadenados cascaden.

---

## 5. Desbloqueo entre instrumentos (`unlock.ts`)

```ts
export interface UnlockRule {
  any?: UnlockCondition[];
  all?: UnlockCondition[];
}

type UnlockCondition =
  | { type: 'percent'; of: string; op: '>=' | '<'; value: number }
  | { type: 'answer';  of: string; qid: number; op: '>=' | '<' | 'includes'; value: number };
```

- `type: 'percent'` → compara el % de avance de otro instrumento (`of` = key).
- `type: 'answer'` → compara una respuesta de otro instrumento.
- Sin `unlock_if` (o `null`) → el instrumento siempre está disponible.

Ejemplo (`registry.ts`): el follow-up de hábitos de ejercicio se desbloquea si
SF-12 ≥ 50% **o** la respuesta 5 de SF-12 incluye el valor 3.

---

## 6. Perfiles de salud (`types.ts` + `registry.ts`)

```ts
export type HealthProfile = 'adulto_activo' | 'mayor_asistido' | 'menor_tutor';
```

Derivación (parity `utils/profile.js`, en `registry.ts`):
- edad `< 18` → `menor_tutor`
- edad `> 60` → `mayor_asistido`
- resto o edad desconocida → `adulto_activo`

Cada cuestionario en `registry.ts` declara a qué perfiles aplica (`profiles`).

---

## 7. Motor de ejecución (estado, progreso, respuestas)

### 7.1 Estado del runner (`runner-state.ts`)

```ts
export type RunnerStatus = 'in_progress' | 'pending_save' | 'completed';
```

- 100% visible respondido y **sin** confirmar guardado → `pending_save`.
- 100% y confirma guardado → `completed` (solo lectura).
- resto → `in_progress`.

Derivadas: `isReadOnly`, `canSave`, `canClear`, `canDownload` (Excel solo en
`completed`).

### 7.2 Progreso (`progress.ts`)

```ts
export interface ProgressSummary {
  percent: number;        // redondeado
  answeredCount: number;
  visibleCount: number;
}
```

- `%` = respondidas visibles / visibles totales (las visibles dependen del
  branching condicional).

### 7.3 Respuestas (`infrastructure/questionnaires/answers.store.ts`)

```ts
export type AnswerValue = number | number[] | string;
export type AnswerMap = Record<string, AnswerValue>;
```

- Persistencia en AppDB (claves `questionnaire_answers:{key}` y
  `questionnaire_dates:{key}`).
- `QuestionnaireDates` = `{ inicio?, fecha?, saved? }`; `saved` refleja la
  confirmación de guardado (parity `:guardado` legado).

---

## 8. Convenciones de escritura de un banco

1. `id` == `key` (p. ej. `"PHQ-9"`).
2. Preguntas en español; identificadores (`key`, `area`, ids de subescala) en
   inglés o siglas normalizadas.
3. Cada opción lleva `value` numérico explícito (aunque sea 0) más `url: null`.
4. `scoring` ausente ⇒ instrumento sin fila de score.
5. `interpretacion` con `desde`/`hasta` **inclusivos**, `subescala` solo si el
   instrumento puntúa por subescalas.
6. Campos `dh_forms` no usados por el engine se conservan **verbatim** (no se
   tiran), apoyándose en la index signature `[extra: string]: unknown`.
7. Instrumentos con branching condicional declaran `conditional` explícito
   (`null` si no hay).
