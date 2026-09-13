# Tipos de pregunta y su `config`

Índice de los valores de `question.type` y de la forma de `question.config`
(JSONB). La forma de `config` **depende del tipo** y se valida en la capa de
aplicación (Pydantic); el motor del frontend la interpreta para renderizar.

## Convención

- `config` es un JSONB **nullable** en `question`.
- `required` es común a **todos** los tipos.
- `shuffle` (en tipos choice) es **opcional/aditivo**: el orden canónico de las
  opciones vive en `option.order`, no en `config`.
- En los ejemplos, el campo `"order"` de la **pregunta** representa su posición
  dentro de un formulario **o** de una sección (payload), **no** una columna de
  `question` (ver `catalog/README.md` §7). Un formulario usa preguntas directas
  **o** secciones, nunca ambos (ver `catalog/README.md` §7 y ADR 038).
- Identificadores en inglés; el copy de la pregunta/opciones en español.
- El valor de respuesta (`answer.value`) también depende del tipo.

## Tipos

| Tipo | `config` (campos propios) | `answer.value` | Doc |
|---|---|---|---|
| `TEXT` | `required`, `max_length` | `string` | [text.md](./text.md) |
| `TEXT_LONG` | `required`, `max_length`, `multiline` | `string` | [text_long.md](./text_long.md) |
| `NUMBER` | `required`, `min_value`, `max_value`, `decimals` | `number` | [number.md](./number.md) |
| `SINGLE_CHOICE` | `required`, `shuffle`* | `number` | [single_choice.md](./single_choice.md) |
| `MULTIPLE_CHOICE` | `required`, `shuffle`*, `min_selected`, `max_selected` | `number[]` | [multiple_choice.md](./multiple_choice.md) |
| `DATE` | `required`, `min_date`, `max_date` | `string` (`YYYY-MM-DD`) | [date.md](./date.md) |
| `DATE_TIME` | `required`, `min_date`, `max_date` | `string` (ISO 8601) | [date_time.md](./date_time.md) |
| `TIMER` | `required`, `min_value`, `max_value`, `precision` | `string` (ISO 8601 duration) | [timer.md](./timer.md) |
| `RANGE` | `required`, `min_value`, `max_value`, `step`, `integer` | `number` | [range.md](./range.md) |

\* `shuffle` es opcional/aditivo. El orden determinista de las opciones es
`option.order`.

## Rescate de fuentes

- **`RANGE`** y **`TIMER`** se rescataron de `other_projects/app_questionnaire/`
  (`my_arquitecture/question/types/range.md` y `timer.md`; evidencia de uso en
  `cuestionarios/IPAQ.json`).
- El resto de tipos proviene del contrato del motor frontend
  (`docs/diagrams/schemas/cuestionario/README.md`) y del DDL de referencia.

## Pendientes

- Definir `config` definitivo para los tipos que hoy son propuesta inicial
  (TEXT, TEXT_LONG, NUMBER, SINGLE_CHOICE, MULTIPLE_CHOICE, DATE, DATE_TIME).
- El motor frontend solo soporta `TEXT`, `SINGLE_CHOICE` y `MULTIPLE_CHOICE`
  (`types.ts:1`); falta soporte para el resto.
