# Tipo: `DATE_TIME`

Fecha con hora.

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `min_date` | `string` (ISO 8601) | Fecha-hora mínima permitida (opcional). |
| `max_date` | `string` (ISO 8601) | Fecha-hora máxima permitida (opcional). |

## Ejemplo (item de pregunta)

```json
{
  "id": 26,
  "key": "fecha_consulta",
  "type": "DATE_TIME",
  "text": "Fecha y hora de la consulta",
  "order": 7,
  "config": { "required": true, "min_date": "2026-01-01T00:00:00Z", "max_date": "2026-12-31T23:59:59Z" }
}
```

## Valor de respuesta (`answer.value`)

`string` en formato ISO 8601 (p. ej. `2026-09-13T14:30:00Z`).

## Fuente

Contrato del motor frontend (`docs/diagrams/schemas/cuestionario/README.md`).
`config` es propuesta inicial.
