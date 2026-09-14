# Condiciones de visibilidad

Una **condición de visibilidad** decide si un elemento del cuestionario **se
muestra u oculta**. Se escribe con el **mismo AST** que el resto del módulo
([`README.md`](./README.md)) y se guarda como **columna JSONB** en el propio
elemento (ver [ADR 039](../../../decisions/039-condicion-visibilidad-ast.md)).

## 1. Dónde vive

| Nivel | Campo | JSONB | Significado |
|---|---|---|---|
| Formulario | `form.condition` | ✅ | El formulario completo solo se habilita si… |
| Sección | `section.condition` | ✅ | La sección solo se muestra si… |
| Pregunta | `question.condition` | ✅ | La pregunta solo se muestra si… |

- El campo es **opcional**. Su ausencia (o `null`) significa **siempre visible**.
- El tipo lógico es `OperandExpression`; en Postgres es `JSONB`.
- Controla **solo visibilidad** (mostrar/ocultar). No cubre skip logic ni
  "requerir condicionalmente"; eso sería una decisión aparte.

Las tablas `conditional_logic` y `form_condition` fueron **eliminadas** en favor
de estas columnas (ADR 039).

## 2. Forma de la expresión

La raíz de una condición debe producir un **booleano** (`output: { "type":
"boolean" }`). Los operadores típicos son:

| Operador | Uso en una condición |
|---|---|
| `comparison` | Comparar un valor contra otro (`==`, `>`, `<=`, `in`, …) |
| `logic` | Combinar condiciones (`and`, `or`, `not`) |
| `collection` | Aplicar una condición a **varias** preguntas (`any`, `all`, `none`) |

El **sujeto** se lee del contexto de respuesta con `entity`/`property`/`selector`
(ver [`operands.md`](./operands.md)):

| Entidad | Propiedad | Ejemplo |
|---|---|---|
| `question` | `value` | La respuesta a una pregunta |
| `person` | `age`, `sex`, … | Datos de la persona |
| `form` | `result.scoring`, … | Resultado ya calculado |

## 3. Ejemplos por nivel

### Pregunta — PHQ-9 Q10

Mostrar la pregunta 10 solo si **alguna** de las preguntas 1–9 tiene síntoma
(`value > 0`). El conjunto se expresa con el selector `range`:

```jsonc
// question.condition (raíz sin wrapper)
{
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
          { "const": { "value": 0, "type": "number" } }
        ],
        "output": { "type": "boolean" }
      }
    }
  ],
  "output": { "type": "boolean" }
}
```

### Sección — datos de embarazo

Mostrar la sección solo si la persona es de sexo femenino:

```jsonc
// section.condition (raíz sin wrapper)
{
  "type": "comparison",
  "operator": "==",
  "args": [
    { "subject": { "entity": "person", "property": "sex" } },
    { "const": { "value": "F", "type": "string" } }
  ],
  "output": { "type": "boolean" }
}
```

### Formulario — solo adultos

Habilitar el formulario solo si la persona tiene 18 años o más:

```jsonc
// form.condition (raíz sin wrapper)
{
  "type": "comparison",
  "operator": ">=",
  "args": [
    { "subject": { "entity": "person", "property": "age" } },
    { "const": { "value": 18, "type": "number" } }
  ],
  "output": { "type": "boolean" }
}
```

### Combinación — dos reglas con `logic`

Mostrar la sección solo si (edad ≥ 18 **Y** sexo = F):

```jsonc
// section.condition (raíz sin wrapper; los operandos sí llevan wrapper)
{
  "type": "logic",
  "operator": "and",
  "args": [
    {
      "expression": {
        "type": "comparison",
        "operator": ">=",
        "args": [
          { "subject": { "entity": "person", "property": "age" } },
          { "const": { "value": 18, "type": "number" } }
        ],
        "output": { "type": "boolean" }
      }
    },
    {
      "expression": {
        "type": "comparison",
        "operator": "==",
        "args": [
          { "subject": { "entity": "person", "property": "sex" } },
          { "const": { "value": "F", "type": "string" } }
        ],
        "output": { "type": "boolean" }
      }
    }
  ],
  "output": { "type": "boolean" }
}
```

## 4. Traducción desde la referencia

La referencia (`app_questionnaire`) usa la forma plana
`{ type: all|any|none, rules: [{ id_question, operator, value }] }`. Se traduce
al AST:

| Referencia | AST |
|---|---|
| `type: "all"` | `logic: and` |
| `type: "any"` | `logic: or` |
| `type: "none"` | `logic: not` |
| `rules[]` (un nivel) | operandos del `logic` |
| Varias reglas sobre un rango de preguntas | `collection` + selector `range` |
| `{ id_question, operator, value }` | `comparison` con `subject`/`selector` y `const` |

**Ejemplo — PHQ-9 Q10** (`PHQ9.json`: `type:"any"` + 9 reglas `id_question 1..9 > 0`):

```jsonc
// Referencia (9 reglas repetidas)
{ "type": "any", "rules": [
  { "id_question": 1, "operator": ">", "value": 0 },
  { "id_question": 2, "operator": ">", "value": 0 },
  { "id_question": 3, "operator": ">", "value": 0 },
  { "id_question": 4, "operator": ">", "value": 0 },
  { "id_question": 5, "operator": ">", "value": 0 },
  { "id_question": 6, "operator": ">", "value": 0 },
  { "id_question": 7, "operator": ">", "value": 0 },
  { "id_question": 8, "operator": ">", "value": 0 },
  { "id_question": 9, "operator": ">", "value": 0 }
] }

// AST (una comparación sobre un rango; raíz sin wrapper)
{ "type": "collection", "operator": "any", "args": [ ... ], "output": { "type": "boolean" } }
```

Ventaja del AST: el rango se expresa con **un selector** (`range`/`all`/`id`) en
lugar de repetir una regla por pregunta, y la anidación (`logic`) no tiene el
límite de forma de la referencia.

## 5. Estado del motor del frontend

El motor actual (`frontend/dh_frontend_app/src/domain/questionnaire-engine/conditions.ts`)
**no consume el AST**: evalúa reglas planas (`{all}`/`{any}` + `ConditionRule[]`,
con operadores `==`,`!=`,`>`,`>=`,`<`,`<=`,`includes`,`notIncludes`,`in`,`notIn`,
`exists`,`notEmpty`). Tampoco soporta `none` ni anidación.

Con una condición AST, ese motor devolvería `null` y trataría el elemento como
**siempre visible** (fallo silencioso). La migración del motor a este contrato es
parte de la **fase frontend** (pendiente D12 en
[`../TODO/cuestionarios.md`](../TODO/cuestionarios.md)).

## 6. Naming

`condition` nombra **dos cosas** distintas en el proyecto:

| Uso | Dónde | Significado |
|---|---|---|
| Campo de visibilidad | `form.condition` / `section.condition` / `question.condition` | Si el elemento se muestra |
| Selector del AST | `"selector": { "condition": { ... } }` | Filtro: "los elementos que cumplen una condición" |

Viven en contextos distintos, pero conviene no confundirlos al leer el modelo.

## Referencias
- Decisión: [ADR 039](../../../decisions/039-condicion-visibilidad-ast.md)
- Gramática: [`README.md`](./README.md), [`operands.md`](./operands.md)
- Operadores: [`operators/collection.md`](./operators/collection.md), `comparison`, `logic`
- Casos médicos: [`examples/medical-cases.md`](./examples/medical-cases.md)
