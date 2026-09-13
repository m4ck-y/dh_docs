# Tipo: `TEXT`

Respuesta de texto corto (una línea).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `max_length` | `number` | Longitud máxima de caracteres (opcional). |

## Ejemplo (item de pregunta)

```json
{
  "id": 20,
  "key": "nombre_paciente",
  "type": "TEXT",
  "text": "Nombre completo",
  "order": 1,
  "config": { "required": true, "max_length": 120 }
}
```

## Valor de respuesta (`answer.value`)

`string`

## Fuente

Contrato del motor frontend (`docs/diagrams/schemas/cuestionario/README.md`).
`config` es propuesta inicial.
