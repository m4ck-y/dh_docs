# `case` — CASE WHEN

Lógica condicional que evalúa una lista de **condiciones** en orden y devuelve
el valor de la **primera que sea verdadera**. Es la base de la
**`expression.evaluation`**.

## Interface

```ts
interface CaseOperator extends BaseOperator {
  type: "case";
  operator: "when";                // operador fijo para CASE WHEN
  cases: Array<{
    when: CalculationOperand;      // condición booleana (operando)
    then: CalculationOperand;      // resultado si la condición es verdadera
  }>;
  default?: CalculationOperand;    // valor si ninguna condición se cumple
  output: { type: DataType };      // tipo resultante
}
```

`when` es un **operando** (`CalculationOperand`), igual que `then` y `default`:

- `{ "expression": { … } }` — una condición compuesta con `comparison`/`logic`.
- `{ "ref": "es_alto" }` — una condición **nombrada** (una definition booleana).
- `{ "const": { "value": true, "type": "boolean" } }` — constante booleana.

## Semántica

- Se evalúan los `when` **en orden**; gana el **primero cuyo booleano sea `true`**.
- `default` es el ELSE.
- Traduce 1:1 a SQL `CASE WHEN <condición> THEN <valor> … ELSE <default> END`.

> **Excepción conocida:** `CaseOperator` no usa `args` (requerido por
> `BaseOperator`), por lo que se declara `"args": []`.

> **Cambio respecto a la referencia.** El `CaseOperator` de `typescript.ts`
> compara un único `subject` contra umbrales (`when: {operator, operand}`). Aquí
> se generaliza a **condition-based** (cada `when` es una condición completa):
> así se pueden expresar clasificaciones con condiciones compuestas (p. ej. los
> niveles del IPAQ, ver [`../README.md`](../README.md) §7). `comparison` y
> `logic` **se mantienen**; solo cambia dónde viven (dentro de `when`).

## La `expression.evaluation` que consume el scoring

Es habitual que la condición compare contra el resultado del scoring. El
resultado vive en `form.result.scoring`:

```jsonc
"evaluation": {
  "type": "case", "operator": "when",
  "cases": [
    { "when": { "expression": { "type":"comparison", "operator":"<",
                "args": [ { "subject": { "entity": "form", "property": "result.scoring" } },
                          { "const": { "value": 5, "type": "number" } } ],
                "output": { "type": "boolean" } } },
      "then": { "const": { "value": "Depresión mínima", "type": "string" } } }
  ],
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

- Con subescalas, el scoping es **por contexto**: una `evaluation` anidada en la
  subescala `A` consume el `result.scoring` de **esa** subescala.
- Si el `form` no define `expression.scoring`, no hay `result.scoring` que
  consumir: una `expression.evaluation` que lo referencie requiere scoring.
- Para no repetir `result.scoring` en cada `when`, puede nombrarse con una
  **definition** (`"score": { … }`) y usar `{ "ref": "score" }`.

## Ejemplo — interpretación PHQ-9 (condiciones)

```jsonc
{
  "type": "case",
  "operator": "when",
  "cases": [
    {
      "when": { "expression": { "type": "comparison", "operator": "<",
                "args": [ { "subject": { "entity": "form", "property": "result.scoring" } },
                          { "const": { "value": 5, "type": "number" } } ],
                "output": { "type": "boolean" } } },
      "then": { "const": { "value": "Depresión mínima", "type": "string" } }
    },
    {
      "when": { "expression": { "type": "comparison", "operator": "<",
                "args": [ { "subject": { "entity": "form", "property": "result.scoring" } },
                          { "const": { "value": 10, "type": "number" } } ],
                "output": { "type": "boolean" } } },
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
