# `case` — CASE WHEN

Lógica condicional que evalúa un `subject` una sola vez y lo clasifica en la
primera banda que coincida. Es la base de la **`evaluation_expression`**.

## Interface

```ts
interface CaseOperator extends BaseOperator {
  type: "case";
  operator: "when";                // operador fijo para CASE WHEN
  subject: CalculationOperand;     // se evalúa UNA sola vez
  cases: Array<{
    when: {
      operator: ComparisonOperator["operator"];  // operador de comparación
      operand: CalculationOperand;               // solo un operando (el otro es el subject)
    };
    then: CalculationOperand;      // resultado si la condición when es verdadera
  }>;
  default?: CalculationOperand;    // valor por defecto si ningún WHEN se cumple
  output: { type: DataType };      // tipo resultante
}
```

## Semántica

- `subject` se evalúa **una sola vez** y se reutiliza en cada `when`.
- Cada `when` compara `subject <operator> operand`.
- Gana la **primera coincidencia** (por eso las bandas se escriben por umbrales
  acumulativos: `<5`, `<10`, `<15`...).
- `default` es el ELSE.
- Traduce 1:1 a SQL `CASE WHEN`.

> **Excepción conocida:** `CaseOperator` no usa `args` (requerido por
> `BaseOperator`), por lo que se declara `"args": []`.

## El `subject` del `evaluation_expression` (convención del proyecto)

El `case` de un `evaluation_expression` **consume el resultado del scoring**, no
repite la fórmula:

```jsonc
{
  "type": "case", "operator": "when",
  "subject": {
    "subject": { "entity": "form", "property": "scoring_result" }
  },
  "cases": [ ... ],
  "default": { "const": { "value": "Fuera de rango", "type": "string" } },
  "output": { "type": "string" },
  "args": []
}
```

Cadena completa:

```
scoring_expression  →  scoring_result  →  evaluation_expression  →  evaluation_result
   (receta suma)         (número: 11)      (case sobre ese número)     (categoría)
```

- El `subject` es un operando `OperandSubject` (`{"subject": {...}}`), de ahí el
  doble `subject` anidado en el JSON.
- Con subescalas, el subject identifica el resultado por grupo:
  `{"subject": {"entity": "form", "property": "scoring_result", "selector": {"group": "A"}}}`.
- Si el `form` no define `scoring_expression`, no hay `scoring_result` que
  consumir: un `evaluation_expression` que lo referencie requiere scoring.

## Ejemplo — interpretación PHQ-9

```jsonc
{
  "expression": {
    "type": "case",
    "operator": "when",
    "subject": { "subject": { "entity": "form", "property": "scoring_result" } },
    "cases": [
      {
        "when": { "operator": "<", "operand": { "const": { "value": 5, "type": "number" } } },
        "then": { "const": { "value": "Depresión mínima", "type": "string" } }
      },
      {
        "when": { "operator": "<", "operand": { "const": { "value": 10, "type": "number" } } },
        "then": { "const": { "value": "Depresión leve", "type": "string" } }
      }
    ],
    "default": { "const": { "value": "Puntuación fuera de rango", "type": "string" } },
    "output": { "type": "string" },
    "args": []
  }
}
```

Ejemplo completo (5 bandas) en
[`../examples/phq9-evaluation.jsonc`](../examples/phq9-evaluation.jsonc).
