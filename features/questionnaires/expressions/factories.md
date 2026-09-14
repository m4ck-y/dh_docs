# Factory functions

Helpers de la referencia (`typescript.ts`) para construir expresiones comunes.
Son **referencia para el motor del backend** (fase F15); el modelo JSONB no las
usa directamente.

## `createComparison`

```ts
const createComparison = (
  left: CalculationOperand,
  operator: ComparisonOperator["operator"],
  right: CalculationOperand
): OperandExpression => ({
  expression: {
    type: "comparison",
    operator,
    args: [left, right],
    output: { type: "boolean" }
  } as ComparisonOperator
});
```

Uso:

```ts
const isAdult = createComparison(
  { subject: { entity: "person", property: "age" } },
  ">=",
  { const: { value: 18, type: "number" } }
);
```

## `createCollectionOperation`

```ts
const createCollectionOperation = (
  operator: CollectionOperator["operator"],
  ...args: CalculationOperand[]
): OperandExpression => ({
  expression: {
    type: "collection",
    operator,
    args,
    output: { type: "boolean" }
  } as CollectionOperator
});
```

Uso:

```ts
const anySymptoms = createCollectionOperation("any", ...symptomChecks);
```

## `createCaseOperation`

```ts
const createCaseOperation = (
  subject: CalculationOperand,
  cases: Array<{
    when: {
      operator: ComparisonOperator["operator"];
      operand: CalculationOperand;
    };
    then: CalculationOperand;
  }>,
  defaultValue?: CalculationOperand,
  outputType: DataType = "string"
): OperandExpression => ({
  expression: {
    type: "case",
    operator: "when",
    subject,
    cases,
    default: defaultValue,
    output: { type: outputType },
    args: []   // requerido por BaseOperator pero no usado en CaseOperator
  } as CaseOperator
});
```

Uso (interpretación PHQ-9, con el subject convenido del proyecto):

```ts
const phq9Interpretation = createCaseOperation(
  { subject: { entity: "form", property: "scoring_result" } },
  [
    {
      when: { operator: "<", operand: { const: { value: 5, type: "number" } } },
      then: { const: { value: "Depresión mínima", type: "string" } }
    },
    {
      when: { operator: "<", operand: { const: { value: 10, type: "number" } } },
      then: { const: { value: "Depresión leve", type: "string" } }
    }
  ],
  { const: { value: "Puntuación fuera de rango", type: "string" } },
  "string"
);
```

## `createTernaryOperation`

Ternario (`condición ? a : b`) implementado como un `case` con una sola banda
cuyo `when` compara el subject booleano contra `true`.

```ts
const createTernaryOperation = (
  condition: OperandExpression,
  trueResult: CalculationOperand,
  falseResult: CalculationOperand,
  outputType: DataType = "string"
): OperandExpression => ({
  expression: {
    type: "case",
    operator: "when",
    subject: condition,
    cases: [
      {
        when: {
          operator: "==",
          operand: { const: { value: true, type: "boolean" } }
        },
        then: trueResult
      }
    ],
    default: falseResult,
    output: { type: outputType },
    args: []
  } as CaseOperator
});
```

Uso:

```ts
const adultClassification = createTernaryOperation(
  createComparison(
    { subject: { entity: "person", property: "age" } },
    ">=",
    { const: { value: 18, type: "number" } }
  ),
  { const: { value: "Adulto", type: "string" } },
  { const: { value: "Menor", type: "string" } }
);
```
