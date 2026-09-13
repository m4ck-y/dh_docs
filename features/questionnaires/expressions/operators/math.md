# `math` — Operadores matemáticos

Operaciones aritméticas sobre operandos numéricos.

## Interface

```ts
interface MathOperator extends BaseOperator {
  type: "math";
  operator: "+" | "-" | "*" | "/" | "%" | "^";  // suma, resta, multiplicación, división, módulo, potencia
  args: CalculationOperand[];   // operandos de la operación (ej. [a, b] para a + b)
  output_data_type: "number";   // siempre produce number
}
```

## Casos de uso

- Índices clínicos: IMC = `peso / (altura ^ 2)`.
- Scoring ponderado: `suma de (peso_pregunta × valor) / total_pesos`.
- METs (IPAQ): `MET × minutos × días` por dominio.

## Ejemplo — IMC

```jsonc
{
  "expression": {
    "type": "math",
    "operator": "/",
    "args": [
      { "subject": { "entity": "person", "property": "weight" } },
      {
        "expression": {
          "type": "math",
          "operator": "^",
          "args": [
            { "subject": { "entity": "person", "property": "height" } },
            { "const": { "value": 2, "data_type": "number" } }
          ],
          "output_data_type": "number"
        }
      }
    ],
    "output_data_type": "number"
  }
}
```

Ejemplo completo en [`../examples/imc-math.jsonc`](../examples/imc-math.jsonc).
