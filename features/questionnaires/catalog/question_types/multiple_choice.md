# Tipo: `MULTIPLE_CHOICE`

Selección de **varias** opciones. Las opciones viven en `list_options`
(JSONB, unión `static` | `catalog`).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `shuffle` | `boolean` | **Opcional / aditivo.** Muestra las opciones en orden aleatorio. Por defecto `false`. |
| `min` | `number` | Mínimo de opciones a seleccionar (opcional). |
| `max` | `number` | Máximo de opciones a seleccionar (opcional). |
| `default` | `(number \| string)[]` | Valores por defecto (opcional). Excluyente con `required`. |

## Opciones (`list_options`)

```jsonc
// estáticas
"list_options": { "source": "static", "items": [ { "uuid": "…", "value": 1, "label": "Fatiga", "order": 1 } ] }
// catálogo gobernado
"list_options": { "source": "catalog", "catalog": { "key": "countries" } }
```

- `source: "static"` → `items` (array **no vacío**) de
  `{uuid, value, label, description?, order?, url?}`.
- `source: "catalog"` → `catalog.key` (catálogo **existente** en el registro);
  las opciones salen del catálogo gobernado (ver ADR 044/046).
- `value` es `number` (escalas) o `string` (catálogos).
- El orden **determinista** vive en `item.order`.

## Ejemplo (item de pregunta)

```json
{
  "id": 24,
  "key": "sintomas",
  "type": "MULTIPLE_CHOICE",
  "text": "¿Cuáles de los siguientes síntomas ha presentado?",
  "order": 5,
  "config": { "required": true, "shuffle": false, "min": 1, "max": 3 },
  "list_options": { "source": "static", "items": [
    { "value": 1, "label": "Dolor de cabeza", "order": 1 },
    { "value": 2, "label": "Fatiga", "order": 2 },
    { "value": 3, "label": "Náusea", "order": 3 }
  ] }
}
```

## Valor de respuesta (`answer.data`)

`number[]` (escala estática) o `string[]` (catálogo) — arreglo con los `value`
de las opciones elegidas.

## Fuente

`config` definitivo (ver `README.md`). Contrato del motor frontend
(`../../reference/questionnaire-engine.md`) como referencia inicial.
