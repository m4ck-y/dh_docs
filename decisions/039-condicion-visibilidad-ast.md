# ADR 039: Condición de Visibilidad como AST JSONB en `form`, `section` y `question`

## Estado
Aceptado

## Contexto

El modelo de cuestionarios distingue dos niveles de condición de **visibilidad**:
una pregunta puede mostrarse solo si se cumple cierta condición (`conditional_logic`),
y un formulario completo puede habilitarse solo bajo cierta condición
(`form_condition`). Ambas se almacenaban como **tablas con una columna de texto
libre**:

- `conditional_logic(id_question, triggered_by_question, formula TEXT, description)`.
- `form_condition(id_form, expression TEXT, description)`.

Esto presentaba tres problemas:

1. **Sin estructura**: `formula TEXT` no es validable ni tipable ("A1 || A2" no
   se puede interpretar con seguridad).
2. **Asimetría**: no existía condición a nivel **sección**, aunque `section` es
   una unidad de agrupación y debería poder ocultarse/mostrarse como conjunto.
3. **Contradicción con la referencia**: `app_questionnaire` documentó un análisis
   explícito (`conditional/column_or_table.md`) que **decidió columna JSON** sobre
   tabla relacional, con una justificación directa: la condición es propiedad
   exclusiva del elemento que la posee, no se comparte, no requiere consultas SQL
   sobre sus campos internos y se evalúa en memoria. El modelo actual usaba justo
   la opción rechazada.

Por otro lado, el proyecto ya adoptó un **lenguaje de expresiones** (AST,
`expressions/`) para `form.expression.scoring` y `form.expression.evaluation`
(pase A2/C7). Ese lenguaje ya sabe expresar condiciones booleanas mediante los
operadores `comparison`, `logic` y `collection`, y su capacidad de anidación
supera a la forma `{type: all|any|none, rules[]}` de la referencia.

## Decisión

### Condición = expresión AST, almacenada como columna JSONB

La condición de visibilidad se modela con el **mismo AST** que el resto del
módulo y se almacena como **columna JSONB en el propio elemento**:

| Nivel | Campo | Tipo lógico |
|---|---|---|
| Formulario | `form.condition` | `OperandExpression` (JSONB) |
| Sección | `section.condition` | `OperandExpression` (JSONB) |
| Pregunta | `question.condition` | `OperandExpression` (JSONB) |

El campo es **opcional**: su ausencia significa **siempre visible**.

### Se eliminan las tablas `conditional_logic` y `form_condition`

- `conditional_logic` (pregunta) y `form_condition` (formulario) se **eliminan**,
  junto con sus índices.
- Se **añade** `section.condition`, cerrando la asimetría de los tres niveles.
- No quedan FKs que referencien esas tablas.

Esto coincide con la recomendación de `column_or_table.md` (columna JSON) y la
extiende a los tres niveles.

### Solo visibilidad

La condición controla únicamente **mostrar/ocultar** el elemento. Otras acciones
(skip logic, requerir condicionalmente) **no** se modelan con este campo; si se
necesitan, serán decisiones aparte.

### La forma de la condición (AST)

El campo contiene un `OperandExpression` (ver
`features/questionnaires/expressions/`). Ejemplos por nivel:

```jsonc
// question.condition — mostrar PHQ-9 Q10 si alguna de Q1..Q9 > 0
{ "expression": { "type": "collection", "operator": "any",
  "args": [{ "expression": { "type": "comparison", "operator": ">",
    "args": [
      { "subject": { "entity": "question", "property": "value", "selector": { "range": [1, 9] } } },
      { "const": { "value": 0, "type": "number" } }
    ], "output": { "type": "boolean" } } }], "output": { "type": "boolean" } } }

// section.condition — mostrar la sección si la persona es de sexo femenino
{ "expression": { "type": "comparison", "operator": "==",
  "args": [
    { "subject": { "entity": "person", "property": "sex" } },
    { "const": { "value": "F", "type": "string" } }
  ], "output": { "type": "boolean" } } }

// form.condition — habilitar el formulario solo para adultos
{ "expression": { "type": "comparison", "operator": ">=",
  "args": [
    { "subject": { "entity": "person", "property": "age" } },
    { "const": { "value": 18, "type": "number" } }
  ], "output": { "type": "boolean" } } }
```

### Traducción desde la referencia

La referencia usa `{ type: all|any|none, rules: [{ id_question, operator, value }] }`
(plano, con anidación). Se traduce al AST así:

| Referencia | AST |
|---|---|
| `type: "all"` / `"any"` / `"none"` | `logic: and` / `logic: or` / `logic: not` |
| `rules[]` de un solo nivel | operandos de `logic` |
| Varias reglas sobre un rango de preguntas | `collection` + selector `range` |
| `{ id_question, operator, value }` | `comparison` con `subject`/`selector` y `const` |

Ventaja: la referencia necesitaba N reglas repetidas para un rango; el AST lo
expresa con un **selector** (`range`/`all`/`id`) y **una** comparación.

## Consecuencias

**Positivas:**
- La condición es **tipable y validable** (es una expresión AST, no texto libre).
- **Un solo lenguaje** para scoring, evaluación y condiciones: menos conceptos.
- Se cierra la asimetría: los **tres niveles** tienen condición.
- Coincide con la decisión explícita de la referencia (`column_or_table.md`).
- Se eliminan **dos tablas** y sus índices: menos JOINs, lectura en una consulta.

**Negativas:**
- El **motor del frontend actual (`conditions.ts`) no consume el AST**: evalúa
  reglas planas (`{all}`/`{any}` + `ConditionRule[]`). Con una condición AST,
  devolvería `null` y trataría el elemento como **siempre visible** (fallo
  silencioso). La migración del motor es trabajo de la **fase frontend (D12)**.
- La condición deja de ser consultable por SQL sobre sus campos internos
  (aceptable: solo la lógica de negocio la interpreta).
- Colisión de vocabulario: `condition` nombra tanto el **campo de visibilidad**
  (`question.condition`) como un **selector del AST** (`{condition: ...}`, filtro
  por condición). Se documenta; viven en contextos distintos.

## Archivos afectados (fase de definición)
- `features/questionnaires/schema.sql` (elimina tablas/índices, añade columnas)
- `features/questionnaires/catalog/ERD.mmd`, `CLASS.mmd`
- `features/questionnaires/catalog/README.md`, `example.jsonc`
- `features/questionnaires/expressions/` (`conditions.md`, `README.md`)
- `features/questionnaires/README.md`, `docs/db/postgres/form/README.md`

## Referencias
- Análisis de la referencia: `other_projects/app_questionnaire/backend/docs/my_arquitecture/question/conditional/column_or_table.md`
- Objeto `conditional` de la referencia: `.../question/conditional.md`
- Lenguaje de expresiones: `docs/features/questionnaires/expressions/`
- Pendientes: `docs/tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md` (A1, A3 resueltos; D12 para el motor)
