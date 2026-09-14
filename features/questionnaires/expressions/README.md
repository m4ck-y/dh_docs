# Lenguaje de expresiones

Gramática del **lenguaje de expresiones** del módulo de cuestionarios. Define
las dos clases de expresión que un `form` declara:

- **`scoring`** — calcula el **puntaje numérico** de una asignación.
- **`evaluation`** — clasifica ese puntaje en una **categoría (texto)**.

Ambas viven en el envelope **`form.expression`** (JSONB; ver `../schema.sql`) y su
**resultado** se persiste en **`assignment.result`**. El motor del backend evalúa
las expresiones al enviar el formulario (`SUBMITTED`); el frontend las interpreta
para renderizar/scoring en cliente.

> **Fase actual: definición.** Este documento fija el **contrato**. El motor del
> frontend todavía usa la forma simplificada de rangos (§5) y migrará a esta
> gramática en una fase posterior (ver D12 en `../TODO/cuestionarios.md`).

## 1. Envelope `expression` / `result`

`form.expression` agrupa las recetas; `assignment.result` agrupa los resultados,
**con la misma forma**:

```ts
expression = { scoring?, evaluation?, subscales? }
result     = { scoring?, evaluation?, subscales? }   // mismos valores calculados
```

| Caso | `expression` / `result` |
|---|---|
| 1 escala (PHQ-9) | `{ scoring, evaluation }` |
| N escalas (HADS) | `{ subscales: [ {id, name, items, max, scoring, evaluation}, … ] }` |
| Mixto | `{ scoring, evaluation, subscales }` |

Al enviar un formulario (caso simple):

```
expression.scoring  →  result.scoring  →  expression.evaluation  →  result.evaluation
   (aggregate sum)        (11)              (case sobre 11)          ("moderada")
```

### Regla del wrapper (raíz vs operando)

| Contexto | Wrapper `{expression: ...}` | Por qué |
|---|---|---|
| **Raíz** de un campo (`expression.scoring`, `expression.evaluation`, `condition`) | ❌ **sin** wrapper | El tipo ya se conoce: es una expresión |
| **Operando** (`args`, `subject`, `cases[].operand`, `then`, `default`) | ✅ **con** wrapper | `args` es una unión de 4 variantes; la clave es el discriminante |

Las 4 variantes de operando ([`operands.md`](./operands.md)):
`{ "subject": … }`, `{ "const": … }`, `{ "expression": … }`, `{ "time_range": … }`.

### Convención del `subject`

El `subject` del `evaluation` **consume el `result.scoring`**, no repite la
fórmula del scoring:

```jsonc
"subject": { "subject": { "entity": "form", "property": "result.scoring" } }
```

Así la fórmula del puntaje vive **una sola vez** (`expression.scoring`) y la
evaluación la reutiliza. Con subescalas, el scoping es **por contexto** (ver §4).
Detalle en [`operators/case.md`](./operators/case.md).

### Puntos de aplicación del AST

| Nivel | Campo | Qué produce | Estado |
|---|---|---|---|
| `form` | `expression.scoring` | Puntaje | ✅ |
| `form` | `expression.evaluation` | Categoría | ✅ |
| `form` | `expression.subscales[]` | Puntaje + categoría por escala | ✅ |
| `question` | `value_expression` | Valor autocalculado | ⏳ pendiente (C7c) |
| `form` / `section` / `question` | `condition` | Visibilidad (booleano) | ✅ (ver [`conditions.md`](./conditions.md)) |

## 2. Alcance y frontera

| Tema | Dónde vive |
|---|---|
| Expresiones de **scoring** y **evaluación** | **Este documento** y sus subdocumentos (A2) |
| Condiciones de **visibilidad** (`condition`) | [`conditions.md`](./conditions.md) (A1/A3) |
| Tipos de pregunta y su `config` | [`../catalog/question_types/`](../catalog/question_types/) |
| Forma de `answer.data` | [`../catalog/README.md`](../catalog/README.md) §8 |

La gramática es un **AST** genérico (no exclusiva de scoring): el mismo lenguaje
expresa cálculos biométricos, promedios temporales o condiciones. La unificación
con condiciones ya está hecha: ver [`conditions.md`](./conditions.md).

## 3. Índice de la gramática

| Documento | Contenido |
|---|---|
| [`operators/`](./operators/) | Las 7 familias de operadores (uno por archivo): `math`, `comparison`, `logic`, `aggregate`, `collection`, `case`, `time`. |
| [`operands.md`](./operands.md) | Los 4 tipos de operando, entidades/propiedades y selectores. |
| [`conditions.md`](./conditions.md) | Condiciones de visibilidad (`condition`) en form/section/question. |
| [`factories.md`](./factories.md) | Factory functions de la referencia (para el motor del backend). |
| [`examples/`](./examples/) | Ejemplos `.jsonc` y casos médicos. |

### Resumen de operadores

```ts
interface BaseOperator {
  type: string;                 // familia
  operator: string;             // operación
  args: CalculationOperand[];   // operandos
  output: { type: DataType };   // tipo del resultado
}
```

| Familia (`type`) | Operadores | Salida | Uso en scoring |
|---|---|---|---|
| `math` | `+` `-` `*` `/` `%` `^` | `number` | METs, ponderaciones |
| `comparison` | `==` `!=` `>` `<` `>=` `<=` `in` | `boolean` | Condiciones de `case/when` |
| `logic` | `and` `or` `not` | `boolean` | Combinar condiciones |
| `aggregate` | `sum` `avg` `min` `max` `count` | `number` | **Puntaje** |
| `collection` | `all` `any` `none` | `boolean` | Colecciones |
| `case` | `when` (fijo) | cualquier `DataType` | **Clasificación** |
| `time` | `range` `movingavg` `delta` | `number` \| `array_number` | Series temporales |

Tipo de dato:

```ts
type DataType =
  | "number" | "string" | "boolean" | "date"
  | "datetime" | "duration"
  | "array_string" | "array_number" | "array_object";
```

> **Nota sobre `type`.** En el AST, `type` aparece con dos sentidos según el
> nivel: en un **operador** es la **familia** de la operación
> (`"type": "aggregate"`); en un **valor** (`const`, `result.*`, `answer.data`)
> o en la **salida** (`output: {type}`) es
> el **tipo de dato** (`"type": "number"`). Están en niveles distintos y no se
> confunden al parsear, pero conviene tenerlo presente al leer el modelo.

> `datetime` (fecha-hora) y `duration` (duración ISO 8601) se añadieron para
> cubrir los tipos de pregunta `DATE_TIME` y `TIMER` (ver §6 y `conditions.md`).

## 4. Subescalas

El AST no tiene una dimensión de subescala, así que el envelope declara un
arreglo **`subscales`**, donde cada subescala es una unidad autocontenida:

```jsonc
"expression": {
  "subscales": [
    {
      "id": "A",
      "name": "Ansiedad",
      "items": [1, 3, 5, 7, 9, 11, 13],   // ← única fuente de pertenencia
      "max": 21,
      "scoring":    { /* aggregate sum, scopeado a esta subescala */ },
      "evaluation": { /* case/when propio de la subescala */ }
    }
  ]
}
```

### Scoping por contexto

- **`items`** es la **única** fuente de pertenencia (lista de ids de pregunta). No
  se usa `question.group` ni un selector `{group}`.
- El **`scoring`** de una subescala suma **sus** `items` (no repite la lista): el
  evaluador usa el `items` de la subescala que lo contiene.
- El **`evaluation`** de la subescala consume **su** `result.scoring` (mismo
  scoping por contexto).

Es exactamente el modelo del motor MVP: `sumItems(subscale.items, answers)` +
bandas filtradas por subescala.

- Un instrumento **sin** subescalas declara `expression.scoring` +
  `expression.evaluation` a nivel `form`.
- El puntaje global (si aplica, además de subescalas) es un `expression.scoring`
  /`evaluation` de nivel `form`.

Ejemplos: [`examples/hads-expression.jsonc`](./examples/hads-expression.jsonc) y
[`examples/hads-result.jsonc`](./examples/hads-result.jsonc).

## 5. Relación con la forma simplificada del MVP

El motor del frontend actual usa rangos cerrados:

```ts
interface Scoring { tipo: 'suma' | 'subescalas'; maximo?: number; items?: number[]; subescalas?: Subscale[]; }
interface InterpretationRange { desde: number; hasta: number; texto: string; subescala?: string; }
```

| MVP | AST |
|---|---|
| `scoring.tipo: 'suma'` | `expression.scoring` (`aggregate sum`) |
| `scoring.tipo: 'subescalas'` | `expression.subscales[]` con `scoring` por subescala |
| `interpretacion[] {desde, hasta, texto}` | `case/when` con umbrales acumulativos |
| `interpretacion[].subescala` | `expression.subscales[]` (cada una con su `evaluation`) |

**Diferencia de límites:** los rangos del MVP son **inclusivos**
(`score >= desde && score <= hasta`); el `case/when` usa umbrales (`<`/`<=`).
Para enteros coinciden; para puntajes continuos hay que fijar la semántica de
borde al migrar.

> La migración de `scoring.ts`/`banks/*.ts` a esta forma es parte del **frontend**
> (pendiente D12), fuera de esta fase.

## 6. Resultados persistidos

El resultado de evaluar las expresiones se guarda en **`assignment.result`**
(evento único), con la **misma forma** que `form.expression` y cada valor como un
`const` del AST (`{value, type}`):

```jsonc
// Caso simple (PHQ-9)
"result": {
  "scoring":    { "value": 11, "type": "number" },
  "evaluation": { "value": "Depresión moderada", "type": "string" }
}

// Caso con subescalas (HADS)
"result": {
  "subscales": [
    { "id": "A", "scoring": { "value": 8, "type": "number" },
                  "evaluation": { "value": "Probable ansiedad", "type": "string" } },
    { "id": "D", "scoring": { "value": 5, "type": "number" },
                  "evaluation": { "value": "Normalidad", "type": "string" } }
  ]
}
```

- `value` + `type` espejan el operando `const` (`{const:{value,type}}`).
- No se persiste la **receta** en el resultado: el resultado es el **valor
  calculado**.

## 7. Limitación conocida: scoring por METs (IPAQ)

El IPAQ usa scoring **no lineal** por METs (`MET × minutos × días`, coeficientes
`caminar=3.3`, `moderada=4.0`, `vigorosa=8.0`). El AST puede expresarlo con
`math` + `aggregate`, pero **no se modela todavía** (pendiente **C7b**). Ver
[`examples/medical-cases.md`](./examples/medical-cases.md) §6.

## 8. Ejemplos

| Archivo | Qué demuestra |
|---|---|
| [`examples/phq9-expression.jsonc`](./examples/phq9-expression.jsonc) | `form.expression` de 1 escala: `{ scoring, evaluation }` |
| [`examples/hads-expression.jsonc`](./examples/hads-expression.jsonc) | `form.expression` con `subscales[]` |
| [`examples/hads-result.jsonc`](./examples/hads-result.jsonc) | `assignment.result` con `subscales[]` (receta vs resultado) |
| [`examples/imc-math.jsonc`](./examples/imc-math.jsonc) | `math` anidado (demuestra el AST) |
| [`examples/medical-cases.md`](./examples/medical-cases.md) | PHQ-9, CRAFFT, riesgo alto, METs |

## Fuente

Gramática adoptada de `other_projects/app_questionnaire/backend/docs/types/`
(`expression.md`, `typescript.ts`). Los ejemplos de scoring provienen de
`cuestionarios/PHQ9.ts` y `cuestionarios/IPAQ.ts`, con las correcciones señaladas
en [`operators/aggregate.md`](./operators/aggregate.md) y §7.
