# ADR 046: Opciones de pregunta — estáticas o de catálogo (`question.list_options`)

## Estado
Aceptado

## Contexto

Las opciones de las preguntas de elección se modelaban como tablas relacionales
(`option` + `url`). Con los **catálogos gobernados** ([ADR 044](044-catalogos-gobernados.md))
aparece un segundo origen de opciones: una pregunta puede tomar sus opciones de un
**catálogo** (registro motor-agnóstico + ítems `PENDING`/`VALIDATED`). El modelo
anterior no permitía expresar ese origen.

## Decisión

Las opciones de una pregunta de elección viven en **`question.list_options`**
(JSONB, nullable), como **unión taggeada**:

```jsonc
// estáticas
"list_options": { "source": "static", "items": [ { "uuid": "…", "value": 0, "label": "Nunca" } ] }
// catálogo gobernado
"list_options": { "source": "catalog", "catalog": { "key": "countries" } }
```

1. **`source: "static"`** → `items` (array **no vacío**) de
   `{ uuid, value, label, description?, order?, url? }`.
2. **`source: "catalog"`** → `catalog.key` (key de un catálogo **existente** en el
   registro); las opciones salen del catálogo gobernado.
3. **`value`** es `number` (escalas/scoring) o `string` (catálogos). La respuesta
   (`answer.data`) guarda ese `value` (no la etiqueta).
4. **Obligación (app/Pydantic)**: en tipos de elección (`SINGLE_CHOICE`,
   `MULTIPLE_CHOICE`) existe **exactamente una** fuente — `static` con `items` no
   vacío **XOR** `catalog` con `key` existente. En el resto de tipos,
   `list_options` es `NULL`.
5. **`required`** se mantiene en `config` (no se mueve).
6. **Sentinels** ("Ninguna", "Prefiere no decirlo") son **ítems del catálogo** con
   su propio `value`; el dominio los mapea según el campo (`NULL` por defecto,
   `0`/otro si aplica).
7. **DDL**: `question.list_options JSONB`; se **eliminan** las tablas `option` y
   `url` (el recurso enlazado se embebe en el ítem como `url`).

## Consecuencias

**Positivas:**
- Un solo campo describe las opciones; el XOR es inherente al `source`.
- Uniforme con el ítem de catálogo (`value`/`label`), selector y respuesta
  agnósticos al origen.
- Opciones gobernadas reutilizables y curables (ADR 044).

**Negativas:**
- Se pierde la normalización relacional de opciones (consulta por opción);
  aceptado porque las opciones siempre se leen **con** la pregunta.
- `value` mixto (`number`/`string`) requiere declarar/validar el tipo por fuente.
- Un form `verified` con `source: "catalog"` **no congela** sus opciones (el
  vocabulario es vivo); el `answer` sí queda congelado.

## Referencias
- Catálogos gobernados: [ADR 044](044-catalogos-gobernados.md)
- XOR de composición (validado en app): [ADR 038](038-formulario-preguntas-vs-secciones.md)
- Respuesta (`answer.data`): [ADR 041](041-origen-answer-valores-calculados.md)
- Feature: `docs/features/catalogs/`
- Tipos de pregunta: `docs/features/questionnaires/catalog/question_types/`
