# `comparison` — Operadores de comparación

Comparan dos operandos y producen un booleano.

## Interface

```ts
interface ComparisonOperator extends BaseOperator {
  type: "comparison";
  operator: "==" | "!=" | ">" | "<" | ">=" | "<=" | "in";  // igual, distinto, mayor, menor, mayor o igual, menor o igual, pertenencia
  args: CalculationOperand[];   // [izquierda, derecha] para izquierda > derecha
  output_data_type: "boolean";  // siempre produce boolean
}
```

## Casos de uso

- Umbrales clínicos: `puntaje > 10`.
- Validaciones de edad: `edad >= 18`.
- Pertenencia a un conjunto: `id in [1, 2, 3]`.
- Operadores de los `when` dentro de un `case` (ver [case.md](./case.md)).

## Ejemplo — ¿hay síntomas?

```jsonc
{
  "expression": {
    "type": "comparison",
    "operator": ">",
    "args": [
      { "subject": { "entity": "question", "property": "value" } },
      { "const": { "value": 0, "data_type": "number" } }
    ],
    "output_data_type": "boolean"
  }
}
```

## Nota sobre `in`

En la fuente hay una inconsistencia de aridad: `typescript.ts` pasa **sujeto y
constante-array** (`[subject, const]`), mientras `expression.md` y `PHQ9.ts`
pasan **solo la constante-array**. Al implementar hay que fijar una sola forma;
este documento no la resuelve (es decisión de la fase de implementación).
