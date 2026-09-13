# Operandos

Los `args` de un [operador](./operators/README.md) son listas de **operandos**.
Un operando es la unidad de menor nivel de una expresión: un valor literal, una
referencia a datos, **otra expresión anidada** o un rango de tiempo.

## Tipos

```ts
type CalculationOperand =
  | OperandSubject      // referencia a un sujeto (question, person, form)
  | OperandConst        // valor constante literal
  | OperandExpression   // expresión anidada
  | OperandTimeRange;   // rango de tiempo
```

### `OperandConst` — valor literal

```ts
interface OperandConst {
  const: {
    value: number | string | boolean | Date | number[] | string[];
    data_type: DataType;
  };
}
```

```jsonc
{ "const": { "value": 5, "data_type": "number" } }
{ "const": { "value": "Depresión leve", "data_type": "string" } }
{ "const": { "value": [1,2,3], "data_type": "array_number" } }
```

> Los resultados persistidos (`scoring_result` / `evaluation_result`) usan la
> **misma forma** (`{value, data_type}`), de modo que receta y resultado comparten
> vocabulario.

### `OperandSubject` — referencia a datos

```ts
interface SubjectReference {
  entity: string;                         // "question" | "person" | "form"
  property: string;                       // propiedad a leer
  selector?: SubjectSelector;             // filtro de selección
  group?: string;                         // grupo (ej. subescala)
  output_data_type?: SelectorOutputType;
}
```

```jsonc
{ "subject": { "entity": "question", "property": "value", "selector": "all" } }
{ "subject": { "entity": "form", "property": "scoring_result" } }
```

### `OperandExpression` — anidación

```ts
interface OperandExpression {
  expression: Operator;   // contiene args y output_data_type internamente
}
```

Es la clave de la potencia del lenguaje: permite anidar indefinidamente (un
`case` cuyo `subject` es un `aggregate`, que a su vez suma `math`, etc.).

```jsonc
{
  "expression": {
    "type": "math", "operator": "^",
    "args": [
      { "subject": { "entity": "person", "property": "height" } },
      { "const": { "value": 2, "data_type": "number" } }
    ],
    "output_data_type": "number"
  }
}
```

### `OperandTimeRange` — rango temporal

```ts
interface OperandTimeRange {
  time_range: {
    start: RelativeOrAbsoluteDate;
    end: RelativeOrAbsoluteDate | null;
  };
}
```

Ver [`operators/time.md`](./operators/time.md).

## Entidades y propiedades

| Entidad | Propiedades comunes | Uso |
|---|---|---|
| `question` | `value` (valor de respuesta), `id` | Scoring de preguntas |
| `form` | `scoring_result` (resultado del scoring) | Input de `evaluation_expression` |
| `person` | `age`, `weight`, `height` | Cálculos clínicos |

`form.scoring_result` es una propiedad **derivada**: existe solo si el `form`
define `scoring_expression`. Ver [`operators/case.md`](./operators/case.md).

## Selectores

```ts
type SubjectSelector = "group" | "all" | SubjectSelectorCondition;

interface SubjectSelectorCondition extends OperandExpression {
  property: string;   // propiedad sobre la que se filtra
}
```

- `"all"` — todas las entidades (ej. todas las preguntas).
- `"group"` — por grupo (ej. subescala `A`).
- **Condición personalizada** — filtra por una expresión sobre `property`:

```jsonc
{
  "selector": {
    "property": "id",
    "expression": {
      "type": "comparison",
      "operator": "in",
      "args": [
        { "const": { "value": [1,2,3,4,5,6,7,8,9], "data_type": "array_number" } }
      ],
      "output_data_type": "boolean"
    },
    "output_data_type": "array_number"
  }
}
```

## Nota sobre aridad de `in`

La fuente es inconsistente: `typescript.ts` pasa `[subject, const]` y
`expression.md`/`PHQ9.ts` pasan solo `[const]`. Los ejemplos de este documento
siguen la forma de `expression.md` (solo la constante). La aridad definitiva es
decisión de la fase de implementación.
