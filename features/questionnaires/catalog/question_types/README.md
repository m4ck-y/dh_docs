# Tipos de pregunta y su `config`

Índice de los valores de `question.type` y de la forma de `question.config`
(JSONB). La forma de `config` **depende del tipo** y se valida en la capa de
aplicación (Pydantic); el motor del frontend la interpreta para renderizar.

## Convención

- `config` es un JSONB **nullable** en `question`.
- `required` es común a **todos** los tipos.
- `required` y `default` son **mutuamente excluyentes**: una pregunta
  obligatoria no puede traer valor por defecto (lo pasaría siempre).
- Los límites se nombran **`min`/`max`** en **todos** los tipos (numéricos,
  fechas, rango, timer, selección múltiple). Ver nota de desviación abajo.
- `shuffle` (en tipos choice) es **opcional/aditivo**: el orden canónico de las
  opciones vive en `option.order`, no en `config`.
- En los ejemplos, el campo `"order"` de la **pregunta** representa su posición
  dentro de un formulario **o** de una sección (payload), **no** una columna de
  `question` (ver `catalog/README.md` §7). Un formulario usa preguntas directas
  **o** secciones, nunca ambos (ver `catalog/README.md` §7 y ADR 038).
- Identificadores en inglés; el copy de la pregunta/opciones en español.
- El valor de respuesta (`answer.data`) también depende del tipo.

## Tipos

| Tipo | `config` (campos propios) | `default` | `answer.data` | Doc |
|---|---|---|---|---|
| `TEXT` | `required`, `min_length`, `max_length` | `string` | `string` | [text.md](./text.md) |
| `TEXT_LONG` | `required`, `min_length`, `max_length`, `multiline` | `string` | `string` | [text_long.md](./text_long.md) |
| `NUMBER` | `required`, `min`, `max`, `decimals`, `step` | `number` | `number` | [number.md](./number.md) |
| `SINGLE_CHOICE` | `required`, `shuffle`* | `number` | `number` | [single_choice.md](./single_choice.md) |
| `MULTIPLE_CHOICE` | `required`, `shuffle`*, `min`, `max` | `number[]` | `number[]` | [multiple_choice.md](./multiple_choice.md) |
| `DATE` | `required`, `min`, `max` | `string` (`YYYY-MM-DD`) | `string` (`YYYY-MM-DD`) | [date.md](./date.md) |
| `DATE_TIME` | `required`, `min`, `max`, `step` | `string` (ISO 8601) | `string` (ISO 8601) | [date_time.md](./date_time.md) |
| `TIMER` | `required`, `min`, `max`, `precision` | `string` (ISO 8601 duration) | `string` (ISO 8601 duration) | [timer.md](./timer.md) |
| `RANGE` | `required`, `min`, `max`, `step`, `integer` | `number` | `number` | [range.md](./range.md) |

`default` es opcional y **excluyente con `required`**. En `MULTIPLE_CHOICE` es un
array (`number[]`).

\* `shuffle` es opcional/aditivo. El orden determinista de las opciones es
`option.order`.

### Calculadas (`expression`)

Una pregunta con `expression` (valor **autocalculado**, solo lectura) **no lleva
`config`**: los campos de `config` describen cómo **responde** el usuario
(`required`, `default`, `shuffle`, límites de input), y una calculada no tiene
input. El valor persistido es el **cálculo crudo**; el formato (redondeo,
unidades) es **presentación** (ver ADR 042). El `type` sí debe ser compatible con
`expression.output.type`.

## Rescate de fuentes

- **`RANGE`** y **`TIMER`** se rescataron de `other_projects/app_questionnaire/`
  (`my_arquitecture/question/types/range.md` y `timer.md`; evidencia de uso en
  `cuestionarios/IPAQ.json`).
- El resto de tipos proviene del contrato del motor frontend
  (`../../reference/questionnaire-engine.md`) y del DDL de referencia.

## Desviación respecto a la fuente

`range.md` y `timer.md` de la referencia usan `min_value`/`max_value`. El modelo
adopta **`min`/`max`** en todos los tipos por **consistencia** de naming. Es una
desviación intencional de la fuente (paridad rota a propósito).

## Pendientes

- El motor frontend solo soporta `TEXT`, `SINGLE_CHOICE` y `MULTIPLE_CHOICE`
  (`types.ts:1`); falta soporte para el resto (ver D12).
