# Operadores

Índice de las 7 familias de operadores del [lenguaje de expresiones](../README.md).
Cada operador se documenta en su propio archivo con su `interface`, sus casos de
uso y ejemplos.

## Base común

Todos los operadores comparten `BaseOperator`:

```ts
interface BaseOperator {
  type: string;                 // familia del operador
  operator: string;             // operación concreta
  args: CalculationOperand[];   // operandos (ver ../operands.md)
  output: { type: DataType };   // tipo del resultado
}
```

## Familias

| Familia (`type`) | Operadores (`operator`) | Salida | Doc |
|---|---|---|---|
| `math` | `+` `-` `*` `/` `%` `^` | `number` | [math.md](./math.md) |
| `comparison` | `==` `!=` `>` `<` `>=` `<=` `in` | `boolean` | [comparison.md](./comparison.md) |
| `logic` | `and` `or` `not` | `boolean` | [logic.md](./logic.md) |
| `aggregate` | `sum` `avg` `min` `max` `count` | `number` | [aggregate.md](./aggregate.md) |
| `collection` | `all` `any` `none` | `boolean` | [collection.md](./collection.md) |
| `case` | `when` (fijo) | cualquier `DataType` | [case.md](./case.md) |
| `time` | `range` `movingavg` `delta` | `number` \| `array_number` | [time.md](./time.md) |

## Uso en el módulo de cuestionarios

- **`scoring_expression`** usa típicamente `aggregate` (`sum`/`avg`).
- **`evaluation_expression`** usa `case` (con `comparison` en sus `when` y,
  opcionalmente, `logic` para combinar).
- `math`, `collection` y `time` están disponibles pero **no se usan todavía** en
  scoring; `math` es la vía para el scoring por METs de IPAQ
  (ver [`../examples/medical-cases.md`](../examples/medical-cases.md) y el
  pendiente C7b).
