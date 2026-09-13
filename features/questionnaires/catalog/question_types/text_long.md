# Tipo: `TEXT_LONG`

Respuesta de texto largo (párrafo, multilínea).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `max_length` | `number` | Longitud máxima de caracteres (opcional). |
| `multiline` | `boolean` | Renderiza un área de texto. Por defecto `true`. |

## Ejemplo (item de pregunta)

```json
{
  "id": 21,
  "key": "observaciones",
  "type": "TEXT_LONG",
  "text": "Observaciones adicionales",
  "order": 2,
  "config": { "required": false, "max_length": 500, "multiline": true }
}
```

## Valor de respuesta (`answer.value`)

`string`

## Fuente

Contrato del motor frontend (`docs/diagrams/schemas/cuestionario/README.md`).
`config` es propuesta inicial.
