# `collection` — Operadores de colección

Evalúan una condición sobre una colección de elementos y producen un booleano.

## Interface

```ts
interface CollectionOperator extends BaseOperator {
  type: "collection";
  operator: "all" | "any" | "none";  // todos cumplen, alguno cumple, ninguno cumple
  args: CalculationOperand[];        // condiciones a evaluar sobre la colección
  output_data_type: "boolean";       // siempre produce boolean
}
```

## Casos de uso

- Mostrar pregunta condicional: `any(preguntas 1..9.value > 0)` → habilita la
  pregunta 10 del PHQ-9.
- Validaciones completas: `all(campos_requeridos != null)`.
- Exclusiones: `none(contraindicaciones == true)`.

## Ejemplo — ¿alguna pregunta del PHQ-9 tiene síntomas?

Con el selector `range` (ver [`../operands.md`](../operands.md)):

```jsonc
{
  "expression": {
    "type": "collection",
    "operator": "any",
    "args": [
      {
        "expression": {
          "type": "comparison",
          "operator": ">",
          "args": [
            {
              "subject": {
                "entity": "question",
                "property": "value",
                "selector": { "range": [1, 9] }
              }
            },
            { "const": { "value": 0, "data_type": "number" } }
          ],
          "output_data_type": "boolean"
        }
      }
    ],
    "output_data_type": "boolean"
  }
}
```

Con un selector de condición equivalente (más verboso; útil para filtros que no
sean un rango contiguo):

```jsonc
{
  "expression": {
    "type": "collection",
    "operator": "any",
    "args": [
      {
        "expression": {
          "type": "comparison",
          "operator": ">",
          "args": [
            {
              "subject": {
                "entity": "question",
                "property": "value",
                "selector": {
                  "condition": {
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
              }
            },
            { "const": { "value": 0, "data_type": "number" } }
          ],
          "output_data_type": "boolean"
        }
      }
    ],
    "output_data_type": "boolean"
  }
}
```

Este caso es una **condición de visibilidad** (ver [`../conditions.md`](../conditions.md)),
no scoring. Se documenta aquí porque demuestra el operador; ver
[`../examples/medical-cases.md`](../examples/medical-cases.md).
