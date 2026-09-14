# `case` — CASE WHEN

Lógica condicional que evalúa un `subject` una sola vez y lo clasifica en la
primera banda que coincida. Es la base de la **`expression.evaluation`**.

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

## El `subject` del `expression.evaluation` (convención del proyecto)

El `case` de un `expression.evaluation` **consume el resultado del scoring**, no
repite la fórmula:

```jsonc
{
  "type": "case", "operator": "when",
  "subject": {
    "subject": { "entity": "form", "property": "result.scoring" }
  },
  "cases": [ ... ],
  "default": { "const": { "value": "Fuera de rango", "type": "string" } },
  "output": { "type": "string" },
  "args": []
}
```

Cadena completa:

```
expression.scoring  →  result.scoring  →  expression.evaluation  →  result.evaluation
   (receta suma)         (número: 11)      (case sobre ese número)     (categoría)
```

- El `subject` es un operando `OperandSubject` (`{"subject": {...}}`), de ahí el
  doble `subject` anidado en el JSON.
- Con subescalas, el scoping es **por contexto**: una `evaluation` anidada en la
  subescala `A` consume el `result.scoring` de **esa** subescala (no se repite el
  `group`).
- Si el `form` no define `expression.scoring`, no hay `result.scoring` que
  consumir: una `expression.evaluation` que lo referencie requiere scoring.

## Ejemplo — interpretación PHQ-9

```jsonc
{
  "type": "case",
  "operator": "when",
  "subject": { "subject": { "entity": "form", "property": "result.scoring" } },
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
```

Ejemplo completo (5 bandas) en
[`../examples/phq9-expression.jsonc`](../examples/phq9-expression.jsonc).
