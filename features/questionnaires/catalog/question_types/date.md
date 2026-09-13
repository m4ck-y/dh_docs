# Tipo: `DATE`

Fecha (sin hora).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `min_date` | `string` (`YYYY-MM-DD`) | Fecha mínima permitida (opcional). |
| `max_date` | `string` (`YYYY-MM-DD`) | Fecha máxima permitida (opcional). |

## Ejemplo (item de pregunta)

```json
{
  "id": 25,
  "key": "fecha_nacimiento",
  "type": "DATE",
  "text": "Fecha de nacimiento",
  "order": 6,
  "config": { "required": true, "min_date": "1900-01-01", "max_date": "2026-12-31" }
}
```

## Valor de respuesta (`answer.value`)

`string` en formato `YYYY-MM-DD`.

## Fuente

Contrato del motor frontend (`docs/diagrams/schemas/cuestionario/README.md`).
`config` es propuesta inicial.
