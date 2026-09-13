# `logic` — Operadores lógicos

Combinan expresiones booleanas.

## Interface

```ts
interface LogicOperator extends BaseOperator {
  type: "logic";
  operator: "and" | "or" | "not";  // conjunción, disyunción, negación
  args: CalculationOperand[];      // expresiones booleanas a combinar
  output_data_type: "boolean";     // siempre produce boolean
}
```

## Casos de uso

- Condiciones compuestas: `(edad > 65) AND (tiene_diabetes == true)`.
- Exclusiones: `NOT (embarazada == true)`.
- Múltiples criterios: `(PHQ-9 > 10) OR (GAD-7 > 8)`.

## Ejemplo — mayor de 65 con diabetes

```jsonc
{
  "expression": {
    "type": "logic",
    "operator": "and",
    "args": [
      {
        "expression": {
          "type": "comparison",
          "operator": ">",
          "args": [
            { "subject": { "entity": "person", "property": "age" } },
            { "const": { "value": 65, "data_type": "number" } }
          ],
          "output_data_type": "boolean"
        }
      },
      {
        "expression": {
          "type": "comparison",
          "operator": "==",
          "args": [
            { "subject": { "entity": "person", "property": "has_diabetes" } },
            { "const": { "value": true, "data_type": "boolean" } }
          ],
          "output_data_type": "boolean"
        }
      }
    ],
    "output_data_type": "boolean"
  }
}
```
