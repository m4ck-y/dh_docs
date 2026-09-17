# Operandos

Los `args` de un [operador](./operators/README.md) son listas de **operandos**.
Un operando es la unidad de menor nivel de una expresión: un valor literal, una
referencia a datos, **otra expresión anidada**, un rango de tiempo o una
referencia a una [definition](./README.md#definiciones-definitions-y-ref).

## Tipos

```ts
type CalculationOperand =
  | OperandSubject      // referencia a un sujeto (question, person, form)
  | OperandConst        // valor constante literal
  | OperandExpression   // expresión anidada
  | OperandTimeRange    // rango de tiempo
  | OperandRef;         // referencia a una definition ({ "ref": "nombre" })
```

### `OperandConst` — valor literal

```ts
interface OperandConst {
  const: {
    value: number | string | boolean | Date | number[] | string[];
    type: DataType;
  };
}
```

```jsonc
{ "const": { "value": 5, "type": "number" } }
{ "const": { "value": "Depresión leve", "type": "string" } }
{ "const": { "value": [1,2,3], "type": "array_number" } }
```

> Los resultados persistidos (`assignment.result.*`) usan la
> **misma forma** (`{value, type}`), de modo que receta y resultado comparten
> vocabulario.

### `OperandSubject` — referencia a datos

```ts
interface SubjectReference {
  entity: string;                         // "question" | "person" | "form"
  property: string;                       // propiedad a leer
  selector?: SubjectSelector;             // filtro (solo para `question`; ver abajo)
  output?: { type: SelectorOutputType };
}
```

```jsonc
{ "subject": { "entity": "question", "property": "value", "selector": { "all": true } } }
{ "subject": { "entity": "form", "property": "result.scoring" } }
```

### `OperandExpression` — anidación

```ts
interface OperandExpression {
  expression: Operator;   // contiene args y output internamente
}
```

Es la clave de la potencia del lenguaje: permite anidar indefinidamente (un
`case` cuya condición (`when`) es un `logic` que combina `comparison`, etc.).

```jsonc
{
  "expression": {
    "type": "math", "operator": "^",
    "args": [
      { "subject": { "entity": "person", "property": "height" } },
      { "const": { "value": 2, "type": "number" } }
    ],
    "output": { "type": "number" }
  }
}
```

### `OperandTimeRange` — rango temporal

```ts
interface OperandTimeRange {
  time_range: {
    start: RelativeOrAbsoluteDate;
    end: RelativeOrAbsoluteDate | null;
  };
}
```

Ver [`operators/time.md`](./operators/time.md).

### `OperandRef` — referencia a una definition

Lee el valor de una **definition** del envelope
([`definitions`](./README.md#definiciones-definitions-y-ref)) por su nombre:

```ts
interface OperandRef {
  ref: string;   // nombre de la definition
}
```

```jsonc
{ "ref": "total_mets" }
// uso:  "scoring": { "ref": "total_mets" }
```

> **Extensión del proyecto.** No existe en la gramática de referencia
> (`typescript.ts`); se añade para reutilizar valores intermedios sin repetir
> fórmulas (p. ej. los METs del IPAQ).

## Entidades y propiedades

| Entidad | Propiedad | Significado | Almacenamiento físico | Selector |
|---|---|---|---|---|
| `question` | `value` | Valor de la respuesta | `answer.data.value` | ✅ (id/range/group/all/condition) |
| `question` | `id` | Identidad de la pregunta | `question.id` | ✅ |
| `form` | `result.scoring` | Resultado del puntaje | `assignment.result.scoring` | ❌ (singular) |
| `form` | `result.evaluation` | Resultado de la clasificación | `assignment.result.evaluation` | ❌ (singular) |
| `person` | `age`, `weight`, `height` | Datos de la persona | — | ❌ (singular) |

- `question.value` y `form.result.*` son **propiedades derivadas** (no columnas).
- `question.value` respalda **también** las preguntas autocalculadas
  (`question.expression`): su valor se persiste como una fila de `answer` con
  `source = CALCULATED`, de modo que un selector `all`/`range` las incluye sin
  casos especiales. Ver [`README.md`](./README.md) (persistencia) y
  [ADR 041](../../../decisions/041-origen-answer-valores-calculados.md).
- `form.result.scoring` existe solo si el `form` define `expression.scoring`. Ver
  [`operators/case.md`](./operators/case.md).
- `selector` **solo aplica a `question`** (la única entidad con múltiples
  instancias); `person` y `form` se referencian en singular.

### Propiedades derivadas (y por qué no entidades físicas)

El AST es una **capa lógica** por encima del almacenamiento. No usa las tablas
físicas (`answer`/`assignment`) como entidades, sino **propiedades derivadas**:

| Referencia del AST | Físicamente |
|---|---|
| `{ "entity":"question", "property":"value", … }` | `answer.data.value` (con `answer.id_question`) |
| `{ "entity":"form", "property":"result.scoring" … }` | `assignment.result.scoring` |

**Por qué no entidades físicas** (ver [ADR 040](../../../decisions/040-ast-propiedades-derivadas.md)):
- Usar `entity:"answer"` obligaría a un selector anidado
  (`selector: { "question": { … } }`), pero `answer` **no tiene** una propiedad
  `question` (tiene `id_question`) → sería una **navegación inventada**.
- La variante física literal (`property:"data.value"`, `selector:{ "id_question": … }`)
  **expone el storage** (path + FK) y complica los selectores.
- Mantener `question.value` conserva selectores de **un solo nivel** y el AST
  agnóstico al motor de base de datos.

## Selectores

El `selector` dice **qué** entidades del `entity` se toman. Hoy aplica **solo a
`question`** (la única entidad con múltiples instancias; `person` y `form` son
singulares). Es un **objeto cuya clave es el tipo de selección** (sin campo
discriminante aparte):

```ts
type SubjectSelector =
  | { all: true }                                               // todas las entidades
  | { id: number }                                              // una pregunta concreta
  | { range: [number, number] }                                 // un rango de ids
  | { group: string }                                           // por grupo/subescala
  | { uuid: string }                                            // una pregunta por su uuid (global)
  | { condition: OperandExpression & { property: string } };    // por condición

interface SubjectReference {
  entity: string;                         // "question" | "person" | "form"
  property: string;                       // propiedad a leer
  selector?: SubjectSelector;             // filtro (solo para `question`)
  output?: { type: SelectorOutputType };
}
```

| Selección | Forma | Ejemplo de `selector` | Cuándo usarlo |
|---|---|---|---|
| todas | `{ all: true }` | `{ "all": true }` | Scoring total (aggregate) |
| por grupo | `{ group }` | `{ "group": "A" }` | Subescalas (A, D) |
| por id | `{ id }` | `{ "id": 103 }` | Una pregunta concreta |
| por rango | `{ range }` | `{ "range": [1, 9] }` | Sumar un rango de preguntas |
| por uuid | `{ uuid }` | `{ "uuid": "0f8f…" }` | Referencia **global** a una pregunta (incluso de **otro** form) |
| condición | `{ condition }` | ver bloque siguiente | Filtro complejo |

> **`all` incluye las calculadas.** `{ all: true }` es literal: lee **todas** las
> preguntas con valor, **incluidas** las autocalculadas (`question.expression`).
> Si un instrumento tiene calculadas (p. ej. un IMC numérico) y el scoring usa
> `{ all: true }`, esas también entrarán en el `aggregate` → **doble conteo /
> puntaje inflado**. Para puntuar **solo las respondibles**, usa `{ range }` o
> `{ id }` explícito (ver [ADR 042](../../../decisions/042-contrato-pregunta-calculada.md)).

**Formas:**

```jsonc
{ "subject": { "entity": "question", "property": "value", "selector": { "all": true } } }
{ "subject": { "entity": "question", "property": "value", "selector": { "group": "A" } } }
{ "subject": { "entity": "question", "property": "value", "selector": { "id": 103 } } }
{ "subject": { "entity": "question", "property": "value", "selector": { "range": [1, 9] } } }
{ "subject": { "entity": "question", "property": "value", "selector": { "uuid": "0f8f…" } } }
```

> **Nota — `uuid` desconocido al autorar.** El `uuid` lo asigna la DB al
> **insertar** la pregunta → **no se conoce** al escribir el JSON a mano. Por eso la
> expresión/condición **no se autora manualmente**: se **construye** (insert en el
> AST) **después** de crear las preguntas, reutilizando el **`uuid` retornado** por
> el create. Si hiciera falta autoría manual, usar un selector **local**
> (`id`/`range`) o **resolver el `uuid` a partir del `key`** antes de armar el AST.

Condición personalizada — filtra por una expresión sobre `property`:

```jsonc
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
            { "const": { "value": [1,2,3,4,5,6,7,8,9], "type": "array_number" } }
          ],
          "output": { "type": "boolean" }
        },
        "output": { "type": "array_number" }
      }
    }
  }
}
```

### Default y regla de uso

- El `selector` es **opcional**. Si se **omite**, el sujeto se toma **en
  singular** (la pregunta/entidad del contexto).
- Para operar sobre **varias** entidades se **exige selector explícito**
  (`all`/`group`/`id`/`range`/`uuid`/`condition`).
- En un `aggregate` (scoring), el selector **nunca se omite**: se usa `{ "all": true }`
  o `{ "range": [...] }`.

> Los selectores `id` y `range` se rescataron de un **intento previo ya
> eliminado** (`chatgpt_.ts`, un borrador de IA en `app_questionnaire`), donde
> eran `selector: "id"` + `id`, y `selector: "range"` + `id_range`. Aquí se
> unifican con el resto en un objeto por clave. `group` absorbe el campo `group`
> que en `typescript.ts` iba suelto en `SubjectReference`.

## Nota sobre aridad de `in`

La fuente es inconsistente: `typescript.ts` pasa `[subject, const]` y
`expression.md`/`PHQ9.ts` pasan solo `[const]`. Los ejemplos de este documento
siguen la forma de `expression.md` (solo la constante). La aridad definitiva es
decisión de la fase de implementación.
