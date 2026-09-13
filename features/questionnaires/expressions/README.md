# Lenguaje de expresiones

Gramática del **lenguaje de expresiones** del módulo de cuestionarios. Define
cómo se escriben las dos expresiones que una `form` declara:

- **`scoring_expression`** — calcula el **puntaje numérico** de una asignación.
- **`evaluation_expression`** — clasifica ese puntaje en una **categoría
  (texto)**.

Ambas se guardan como **JSONB** en `form` (ver `../schema.sql`) y su **resultado**
se persiste en la `assignment` correspondiente (`scoring_result` /
`evaluation_result`). El motor del backend evalúa la expresión al enviar el
formulario (`SUBMITTED`); el frontend la interpreta para renderizar/scoring en
cliente.

> **Fase actual: definición.** Este documento fija el **contrato** de las
> expresiones. El motor del frontend todavía usa la forma simplificada de rangos
> (§7) y migrará a esta gramática en una fase posterior (ver D12 en
> `../TODO/cuestionarios.md`).

## 1. Alcance y frontera

| Tema | Dónde vive |
|---|---|
| Expresiones de **scoring** y **evaluación** | **Este documento** (A2) |
| Condiciones de **visibilidad** (`conditional_logic`, `form_condition`) | Pendiente aparte (**A1**); hoy son `TEXT`/`formula` |
| Tipos de pregunta y su `config` | [`../catalog/question_types/`](../catalog/question_types/) |
| Forma de `answer.value` | [`../catalog/README.md`](../catalog/README.md) §8 |

La gramática es un **AST** (árbol de sintaxis abstracta) genérico: no es
exclusiva de scoring. El mismo lenguaje puede expresar cálculos biométricos
(p. ej. IMC), promedios en rangos de tiempo o condiciones. Aquí se documenta
**solo** su uso para scoring/evaluación; la unificación con condiciones (A1) se
decidirá aparte.

## 2. Tipo de dato (`DataType`)

Todo operador y operando declara el tipo de su salida:

```ts
type DataType =
  | "number"
  | "string"
  | "boolean"
  | "date"
  | "array_string"
  | "array_number"
  | "array_object";
```

## 3. Operadores

Todos los operadores comparten una base:

```ts
interface BaseOperator {
  type: string;                 // familia del operador
  operator: string;             // operación concreta
  args: CalculationOperand[];   // operandos
  output_data_type: DataType;   // tipo del resultado
}
```

| Familia (`type`) | Operadores (`operator`) | Salida | Uso en scoring |
|---|---|---|---|
| `math` | `+` `-` `*` `/` `%` `^` | `number` | Ponderaciones, METs |
| `comparison` | `==` `!=` `>` `<` `>=` `<=` `in` | `boolean` | Condiciones de `case/when` |
| `logic` | `and` `or` `not` | `boolean` | Combinar condiciones |
| `aggregate` | `sum` `avg` `min` `max` `count` | `number` | **Puntaje** (`sum`/`avg`) |
| `collection` | `all` `any` `none` | `boolean` | Colecciones |
| `case` | `when` (fijo) | cualquier `DataType` | **Clasificación** por bandas |
| `time` | `range` `movingavg` `delta` | `number` \| `array_number` | Series temporales |

### 3.1 Operandos (anidación)

El argumento (`args`) de un operador es una lista de **operandos**. Un operando
puede ser un valor literal, una referencia a datos, **otra expresión anidada** o
un rango de tiempo:

```ts
type CalculationOperand =
  | OperandSubject      // { subject: { entity, property, selector?, group? } }
  | OperandConst        // { const: { value, data_type } }
  | OperandExpression   // { expression: Operator }   ← anidación
  | OperandTimeRange;   // { time_range: { start, end } }
```

`OperandExpression` es la clave de la potencia del lenguaje: permite anidar
indefinidamente (p. ej. un `case` cuyo `subject` es un `aggregate`, que a su vez
suma `math`, etc.).

### 3.2 `aggregate` — el puntaje

`sum` suma los valores de una colección; `avg` promedia. Para scoring típico:

```jsonc
{
  "expression": {
    "type": "aggregate",
    "operator": "sum",
    "args": [
      { "subject": { "entity": "question", "property": "value", "selector": "all" } }
    ],
    "output_data_type": "number"
  }
}
```

### 3.3 `case/when` — la clasificación

`case` evalúa una vez un `subject` y lo compara contra una lista de `cases`; la
**primera coincidencia gana**. `default` es el ELSE. Traduce 1:1 a SQL
`CASE WHEN`:

```ts
interface CaseOperator extends BaseOperator {
  type: "case";
  operator: "when";
  subject: CalculationOperand;      // se evalúa UNA sola vez
  cases: Array<{
    when: { operator: ComparisonOperator["operator"]; operand: CalculationOperand };
    then: CalculationOperand;
  }>;
  default?: CalculationOperand;     // fallback
  output_data_type: DataType;
}
```

> **Excepción conocida:** `CaseOperator` no usa `args` (requerido por
> `BaseOperator`), por lo que se declara `"args": []`. Es una inconsistencia del
> tipo base, no un error del ejemplo.

## 4. `scoring_expression`

Produce el **puntaje numérico**. Es un `OperandExpression` cuya raíz es
normalmente un `aggregate`:

- `sum` → puntaje total de las preguntas.
- `avg` → promedio (cuando el instrumento lo pide).

Ejemplo PHQ-9: [`examples/phq9-scoring.jsonc`](./examples/phq9-scoring.jsonc).

```jsonc
{ "expression": { "type": "aggregate", "operator": "sum",
  "args": [{ "subject": { "entity": "question", "property": "value", "selector": "all" } }],
  "output_data_type": "number" } }
```

> **Corrección de la referencia:** `PHQ9.ts` declara `operator: "avg"` con un
> comentario que dice "Promedio en lugar de suma", pero el total clínico (0–27)
> requiere `sum`. Se adopta **`sum`**.

## 5. `evaluation_expression`

Clasifica el puntaje en una **categoría**. Es un `OperandExpression` cuya raíz es
un `case`, con el `scoring_expression` como `subject`:

Ejemplo PHQ-9 (5 bandas): [`examples/phq9-evaluation.jsonc`](./examples/phq9-evaluation.jsonc).

```jsonc
{ "expression": {
  "type": "case", "operator": "when",
  "subject": { /* el scoring_expression */ },
  "cases": [
    { "when": { "operator": "<",  "operand": { "const": { "value": 5,  "data_type": "number" } } },
      "then": { "const": { "value": "Depresión mínima", "data_type": "string" } } },
    { "when": { "operator": "<",  "operand": { "const": { "value": 10, "data_type": "number" } } },
      "then": { "const": { "value": "Depresión leve", "data_type": "string" } } }
  ],
  "default": { "const": { "value": "Puntuación fuera de rango", "data_type": "string" } },
  "output_data_type": "string" } }
```

### 5.1 Bandas por umbral acumulativo

La referencia usa **umbrales acumulativos** (`<5`, `<10`, `<15`, `<20`, `<=27`),
aprovechando que la primera coincidencia gana. Es más compacto que los rangos
cerrados del MVP y equivalente para puntajes enteros.

## 6. Subescalas

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

- Un instrumento **sin** subescalas declara las expresiones en el nivel del
  `form` (como en §4/§5).
- Un instrumento **con** subescalas declara `subscales[]`; cada subescala lleva
  sus expresiones. El puntaje global, si aplica, es otra expresión de nivel
  `form`.

Ejemplo: [`examples/hads-subscales.jsonc`](./examples/hads-subscales.jsonc).

> `subscales[]` es una **extensión propia** de este proyecto: no existe en el
> AST de la referencia (`typescript.ts`), que solo tiene `selector.group` sin
> semántica especificada.

## 7. Relación con la forma simplificada del MVP

El motor del frontend actual usa rangos cerrados:

```ts
interface Scoring { tipo: 'suma' | 'subescalas'; maximo?: number; items?: number[]; subescalas?: Subscale[]; }
interface InterpretationRange { desde: number; hasta: number; texto: string; subescala?: string; }
```

Traducción a la gramática canónica:

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
> (pendiente D12), fuera de esta fase de definición.

## 8. Resultados persistidos

El resultado de evaluar cada expresión se guarda en la `assignment` (evento
único), con la **misma forma que un `const`** del AST:

```jsonc
// assignment.scoring_result  (resultado de scoring_expression)
{ "value": 11, "data_type": "number" }

// assignment.evaluation_result  (resultado de evaluation_expression)
{ "value": "Depresión moderada", "data_type": "string" }
```

Con subescalas, el resultado agrupa por subescala:

```jsonc
// assignment.scoring_result
{ "value": null, "data_type": "number",
  "subscales": [ { "id": "A", "value": 8, "data_type": "number" } ] }
```

- `value` + `data_type` espejan el operando `const` (`{const:{value,data_type}}`),
  de modo que la receta y el resultado comparten vocabulario.
- No se persiste la **receta** en el resultado (error del ejemplo previo de
  `schema.sql`, que repetía `{"op":"sum","fields":[...]}`): el resultado es el
  **valor calculado**.

## 9. Limitación conocida: scoring por METs (IPAQ)

El IPAQ usa scoring **no lineal** por METs:

```
MET-min/semana(dominio) = MET × minutos × días
total = caminar + moderada + vigorosa
coeficientes: caminar = 3.3, moderada = 4.0, vigorosa = 8.0
```

El AST **puede** expresarlo con `math` (`*`) + `aggregate sum` sobre los
dominios, pero **no se modela todavía**: el catálogo `IPAQ.json` no trae scoring,
el `IPAQ.ts` de la referencia está incompleto (referencias a variables no
definidas) y el único algoritmo completo vive en el diagrama
`docs/diagrams/3_CUESTIONARIO_FISICO/IPAQ.pseint`. Queda como pendiente propio
(**METs IPAQ**) en `../TODO/cuestionarios.md`.

## 10. Ejemplos

| Archivo | Qué demuestra |
|---|---|
| [`examples/phq9-scoring.jsonc`](./examples/phq9-scoring.jsonc) | `aggregate sum` (puntaje total) |
| [`examples/phq9-evaluation.jsonc`](./examples/phq9-evaluation.jsonc) | `case/when` con 5 bandas + `default` |
| [`examples/hads-subscales.jsonc`](./examples/hads-subscales.jsonc) | `subscales[]` con expresión por subescala |
| [`examples/imc-math.jsonc`](./examples/imc-math.jsonc) | `math` anidado (no scoring; demuestra el AST) |

## Fuente

Gramática adoptada de `other_projects/app_questionnaire/backend/docs/types/`
(`expression.md`, `typescript.ts`). Los ejemplos de scoring provienen de
`cuestionarios/PHQ9.ts` y `cuestionarios/IPAQ.ts`, con las correcciones señaladas
en §4 y §9.
