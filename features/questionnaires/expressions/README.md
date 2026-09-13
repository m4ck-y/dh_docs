# Lenguaje de expresiones

Gramática del **lenguaje de expresiones** del módulo de cuestionarios. Define
cómo se escriben las dos expresiones que una `form` declara:

- **`scoring_expression`** — calcula el **puntaje numérico** de una asignación.
- **`evaluation_expression`** — clasifica ese puntaje en una **categoría (texto)**.

Ambas se guardan como **JSONB** en `form` (ver `../schema.sql`) y su **resultado**
se persiste en la `assignment` correspondiente. El motor del backend evalúa la
expresión al enviar el formulario (`SUBMITTED`); el frontend la interpreta para
renderizar/scoring en cliente.

> **Fase actual: definición.** Este documento fija el **contrato**. El motor del
> frontend todavía usa la forma simplificada de rangos (§5) y migrará a esta
> gramática en una fase posterior (ver D12 en `../TODO/cuestionarios.md`).

## 1. Las 4 piezas (cadena de evaluación)

```
form.scoring_expression      →  LA RECETA del número
form.evaluation_expression   →  LA RECETA de la categoría
assignment.scoring_result    →  EL NÚMERO calculado
assignment.evaluation_result →  LA CATEGORÍA calculada
```

Al enviar un formulario:

```
scoring_expression  →  scoring_result  →  evaluation_expression  →  evaluation_result
   (aggregate sum)        (11)              (case sobre 11)          ("moderada")
```

| Pieza | Dónde vive | Contenido |
|---|---|---|
| `scoring_expression` | `form` | Fórmula del puntaje (`aggregate`) |
| `evaluation_expression` | `form` | Fórmula de clasificación (`case/when`); su `subject` es el input |
| `scoring_result` | `assignment` | Valor calculado, forma `{value, data_type}` |
| `evaluation_result` | `assignment` | Valor calculado, forma `{value, data_type}` |

### Convención del `subject`

El `subject` del `evaluation_expression` **consume el `scoring_result`**, no
repite la fórmula del scoring:

```jsonc
"subject": { "subject": { "entity": "form", "property": "scoring_result" } }
```

Así la fórmula del puntaje vive **una sola vez** (`scoring_expression`) y la
evaluación la reutiliza. Con subescalas, el subject identifica el resultado por
grupo (ver §4). Detalle en [`operators/case.md`](./operators/case.md).

### Puntos de aplicación del AST

El mismo lenguaje se aplica en varios lugares; hoy en dos, con un tercero
propuesto:

| Nivel | Campo | Qué produce | Estado |
|---|---|---|---|
| `form` | `scoring_expression` | Puntaje | ✅ |
| `form` | `evaluation_expression` | Categoría | ✅ |
| `question` | `value_expression` | Valor autocalculado de la pregunta | ⏳ pendiente (C7c) |
| `form` / `section` / `question` | `condition` | Visibilidad (booleano) | ✅ (ver [`conditions.md`](./conditions.md)) |

## 2. Alcance y frontera

| Tema | Dónde vive |
|---|---|
| Expresiones de **scoring** y **evaluación** | **Este documento** y sus subdocumentos (A2) |
| Condiciones de **visibilidad** (`condition`) | [`conditions.md`](./conditions.md) (A1/A3) |
| Tipos de pregunta y su `config` | [`../catalog/question_types/`](../catalog/question_types/) |
| Forma de `answer.value` | [`../catalog/README.md`](../catalog/README.md) §8 |

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
  output_data_type: DataType;   // tipo del resultado
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
  | "array_string" | "array_number" | "array_object";
```

## 4. Subescalas

El AST **no tiene** una dimensión de subescala. Para instrumentos con varias
escalas (HADS, DTS, ASRS, EDAH), el `form` declara un arreglo `subscales[]`, cada
una con su propio par de expresiones:

```jsonc
{
  "subscales": [
    {
      "id": "A",
      "name": "Ansiedad",
      "items": [1, 3, 5, 7, 9, 11, 13],
      "max": 21,
      "scoring_expression": { /* aggregate sum sobre esos items */ },
      "evaluation_expression": { /* case/when propio de la subescala */ }
    }
  ]
}
```

- Un instrumento **sin** subescalas declara las expresiones a nivel del `form`.
- Con subescalas, cada una lleva sus expresiones; el `evaluation_expression`
  consume el `scoring_result` de su subescala
  (`{"entity": "form", "property": "scoring_result", "selector": {"group": "A"}}`).
- El puntaje global, si aplica, es otra expresión a nivel del `form`.

Ejemplo: [`examples/hads-subscales.jsonc`](./examples/hads-subscales.jsonc).

## 5. Relación con la forma simplificada del MVP

El motor del frontend actual usa rangos cerrados:

```ts
interface Scoring { tipo: 'suma' | 'subescalas'; maximo?: number; items?: number[]; subescalas?: Subscale[]; }
interface InterpretationRange { desde: number; hasta: number; texto: string; subescala?: string; }
```

| MVP | AST |
|---|---|
| `scoring.tipo: 'suma'` | `aggregate sum` |
| `scoring.tipo: 'subescalas'` | `subscales[]` con `aggregate sum` por subescala |
| `interpretacion[] {desde, hasta, texto}` | `case/when` con umbrales acumulativos |
| `interpretacion[].subescala` | `subscales[]` (cada subescala con su `evaluation_expression`) |

**Diferencia de límites:** los rangos del MVP son **inclusivos**
(`score >= desde && score <= hasta`); el `case/when` usa umbrales (`<`/`<=`).
Para enteros coinciden; para puntajes continuos hay que fijar la semántica de
borde al migrar.

> La migración de `scoring.ts`/`banks/*.ts` a esta forma es parte del **frontend**
> (pendiente D12), fuera de esta fase.

## 6. Resultados persistidos

El resultado de evaluar cada expresión se guarda en la `assignment` (evento
único), con la **misma forma que un `const`** del AST:

```jsonc
// assignment.scoring_result
{ "value": 11, "data_type": "number" }

// assignment.evaluation_result
{ "value": "Depresión moderada", "data_type": "string" }
```

Con subescalas:

```jsonc
// assignment.scoring_result
{ "value": null, "data_type": "number",
  "subscales": [ { "id": "A", "value": 8, "data_type": "number" } ] }
```

- `value` + `data_type` espejan el operando `const` (`{const:{value,data_type}}`).
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
| [`examples/phq9-scoring.jsonc`](./examples/phq9-scoring.jsonc) | `aggregate sum` (puntaje total) |
| [`examples/phq9-evaluation.jsonc`](./examples/phq9-evaluation.jsonc) | `case/when` con 5 bandas + `default` |
| [`examples/hads-subscales.jsonc`](./examples/hads-subscales.jsonc) | `subscales[]` con expresión por subescala |
| [`examples/imc-math.jsonc`](./examples/imc-math.jsonc) | `math` anidado (demuestra el AST) |
| [`examples/medical-cases.md`](./examples/medical-cases.md) | PHQ-9, CRAFFT, riesgo alto, METs |

## Fuente

Gramática adoptada de `other_projects/app_questionnaire/backend/docs/types/`
(`expression.md`, `typescript.ts`). Los ejemplos de scoring provienen de
`cuestionarios/PHQ9.ts` y `cuestionarios/IPAQ.ts`, con las correcciones señaladas
en [`operators/aggregate.md`](./operators/aggregate.md) y §7.
