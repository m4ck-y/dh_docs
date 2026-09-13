# Tipo: `SINGLE_CHOICE`

Selección de **una** opción entre varias. Las opciones viven en la tabla
`option` (no en `config`).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `shuffle` | `boolean` | **Opcional / aditivo.** Muestra las opciones en orden aleatorio. Por defecto `false`. |

El orden **determinista** de las opciones se define en `option.order` (dato
estructural), no en `config`. Si `shuffle = true`, `option.order` sigue siendo
el orden canónico/base.

## Ejemplo (item de pregunta)

```json
{
  "id": 23,
  "key": "satisfaccion",
  "type": "SINGLE_CHOICE",
  "text": "¿Cómo calificaría la atención recibida?",
  "order": 4,
  "config": { "required": true, "shuffle": false },
  "list_options": [
    { "text": "Excelente", "value": 4, "order": 1, "id": 0, "url": null },
    { "text": "Bueno", "value": 3, "order": 2, "id": 0, "url": null },
    { "text": "Regular", "value": 2, "order": 3, "id": 0, "url": null },
    { "text": "Malo", "value": 1, "order": 4, "id": 0, "url": null }
  ]
}
```

## Valor de respuesta (`answer.value`)

`number` — el `value` de la opción elegida.

## Fuente

Contrato del motor frontend (`docs/diagrams/schemas/cuestionario/README.md`).
`config` es propuesta inicial.
