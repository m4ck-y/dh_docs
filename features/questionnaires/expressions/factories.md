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
    output_data_type: "boolean"
  } as ComparisonOperator
});
```

Uso:

```ts
const isAdult = createComparison(
  { subject: { entity: "person", property: "age" } },
  ">=",
  { const: { value: 18, data_type: "number" } }
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
    output_data_type: "boolean"
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
    output_data_type: outputType,
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
      when: { operator: "<", operand: { const: { value: 5, data_type: "number" } } },
      then: { const: { value: "Depresión mínima", data_type: "string" } }
    },
    {
      when: { operator: "<", operand: { const: { value: 10, data_type: "number" } } },
      then: { const: { value: "Depresión leve", data_type: "string" } }
    }
  ],
  { const: { value: "Puntuación fuera de rango", data_type: "string" } },
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
          operand: { const: { value: true, data_type: "boolean" } }
        },
        then: trueResult
      }
    ],
    default: falseResult,
    output_data_type: outputType,
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
    { const: { value: 18, data_type: "number" } }
  ),
  { const: { value: "Adulto", data_type: "string" } },
  { const: { value: "Menor", data_type: "string" } }
);
```
