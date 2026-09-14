# `aggregate` — Operadores de agregación

Agregan una colección de valores en un único número. Es la base del **scoring**.

## Interface

```ts
interface AggregateOperator extends BaseOperator {
  type: "aggregate";
  operator: "sum" | "avg" | "min" | "max" | "count";  // suma, promedio, mínimo, máximo, conteo
  args: CalculationOperand[];   // colección de valores a agregar
  output: { type: "number" };   // siempre produce number
}
```

## Casos de uso

- Puntuación total: `sum(todas_las_respuestas)`.
- Promedio de síntomas: `avg(respuestas_sintomas)`.
- Conteo de criterios: `count(criterios_positivos)`.

## Ejemplo — puntaje total del PHQ-9

```jsonc
{
  "expression": {
    "type": "aggregate",
    "operator": "sum",
    "args": [
      { "subject": { "entity": "question", "property": "value", "selector": { "all": true } } }
    ],
    "output": { "type": "number" }
  }
}
```

Ejemplo completo en [`../examples/phq9-scoring.jsonc`](../examples/phq9-scoring.jsonc).

## Nota de la fuente

`PHQ9.ts` declara `operator: "avg"` con un comentario que dice "Promedio en lugar
de suma", pero el total clínico del PHQ-9 (0–27) requiere `sum`. Se adopta `sum`.
