# Tipo: `MULTIPLE_CHOICE`

Selección de **varias** opciones. Las opciones viven en la tabla `option`.

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `shuffle` | `boolean` | **Opcional / aditivo.** Muestra las opciones en orden aleatorio. Por defecto `false`. |
| `min_selected` | `number` | Mínimo de opciones a seleccionar (opcional). |
| `max_selected` | `number` | Máximo de opciones a seleccionar (opcional). |

El orden **determinista** de las opciones se define en `option.order` (dato
estructural), no en `config`.

## Ejemplo (item de pregunta)

```json
{
  "id": 24,
  "key": "sintomas",
  "type": "MULTIPLE_CHOICE",
  "text": "¿Cuáles de los siguientes síntomas ha presentado?",
  "order": 5,
  "config": { "required": true, "shuffle": false, "min_selected": 1, "max_selected": 3 },
  "list_options": [
    { "text": "Dolor de cabeza", "value": 1, "order": 1, "id": 0, "url": null },
    { "text": "Fatiga", "value": 2, "order": 2, "id": 0, "url": null },
    { "text": "Náusea", "value": 3, "order": 3, "id": 0, "url": null }
  ]
}
```

## Valor de respuesta (`answer.value`)

`number[]` — arreglo con los `value` de las opciones elegidas.

## Fuente

Contrato del motor frontend (`docs/diagrams/schemas/cuestionario/README.md`).
`config` es propuesta inicial.
