# ADR 040: Propiedades Derivadas en el AST (`question.value`, `form.result.*`)

## Estado
Aceptado

## Contexto

El lenguaje de expresiones (AST) referencia datos mediante `SubjectReference`
(`{ entity, property, selector? }`). Dos de esas referencias **no corresponden a
columnas físicas**:

- `{ "entity": "question", "property": "value" }` → el valor de la respuesta.
  Físicamente vive en `answer.data.value` (`answer` es otra tabla, con
  `id_question` como FK).
- `{ "entity": "form", "property": "result.scoring" }` → el resultado del
  formulario. Físicamente vive en `assignment.result.*`.

Al modelar la expresión por pregunta (`question.expression`, pendiente C7c) se
reabrió la pregunta de si el AST debería usar las **entidades físicas** en su
lugar:

- `{ "entity": "answer", "property": "value", "selector": { "question": { "range": [1, 9] } } }`
  (selector anidado, "B2"), o
- `{ "entity": "answer", "property": "data.value", "selector": { "id_question": { "range": [1, 9] } } }`
  (física literal, "B1").

El problema detectado: `answer` **no tiene** una propiedad `question` (tiene
`id_question`), por lo que un selector `{ "question": { … } }` sería una
**navegación inventada** (un join escondido en el selector), no un campo real.
Y la variante literal expone el **path** (`data.value`) y el **nombre de la FK**
(`id_question`).

Además, `selector` solo tiene sentido para entidades con **múltiples
instancias**; en el contexto de evaluación solo `question` lo es (`person` y
`form` son singulares).

## Decisión

El AST usa **propiedades derivadas lógicas**, no entidades físicas:

| Referencia | Significado | Almacenamiento físico |
|---|---|---|
| `{ entity: "question", property: "value", selector: … }` | Valor de la respuesta a la(s) pregunta(s) seleccionada(s) | `answer.data.value` |
| `{ entity: "form", property: "result.scoring" \| "result.evaluation" }` | Resultado calculado del formulario | `assignment.result.*` |
| `{ entity: "person", property: … }` | Datos de la persona | — |

- `selector` **aplica solo a `question`** (la única entidad con múltiples
  instancias). `person` y `form` se referencian en singular (sin `selector`).
- Las propiedades derivadas (`question.value`, `form.result.*`) se **documentan
  explícitamente** como tales (ver `features/questionnaires/expressions/operands.md`).

## Alternativas consideradas y descartadas

1. **Entidades físicas con selector anidado** (B2):
   `{ entity: "answer", …, selector: { question: { … } } }`.
   Descartada: `answer` no tiene `question`; sería una navegación inventada y
   añade anidación al selector.

2. **Entidades físicas literales** (B1):
   `{ entity: "answer", property: "data.value", selector: { id_question: { … } } }`.
   Descartada: expone el storage (`data.value`, `id_question`) y complica los
   selectores (habría que reinterpretarlos para respuestas).

## Consecuencias

**Positivas:**
- El AST se mantiene una **capa lógica**, agnóstica al almacenamiento (Postgres).
- `selector` sigue siendo de **un solo nivel** y simple (`all`/`id`/`range`/`group`/`condition`).
- Sin refactor: el naming ya se usaba en todo el módulo.

**Negativas:**
- Las propiedades derivadas **no** coinciden con las columnas físicas: hay que
  documentarlas para evitar confusión al implementar (backend/frontend).
- Una futura capa (p. ej. un ORM) deberá **mapear** `question.value` →
  `answer.data.value` y `form.result.*` → `assignment.result.*`.

## Referencias
- Entidades y selectores: `features/questionnaires/expressions/operands.md`
- Modelo físico: `features/questionnaires/schema.sql` (`answer`, `assignment`)
- Decisión relacionada: [ADR 039](039-condicion-visibilidad-ast.md)
- Pendiente: `docs/TODO/cuestionarios.md` (C7c, `question.expression`)
