# Tipo: `DATE_TIME`

Fecha con hora.

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `min` | `string` (ISO 8601) | Fecha-hora mínima permitida (opcional). |
| `max` | `string` (ISO 8601) | Fecha-hora máxima permitida (opcional). |
| `step` | `number` | Incremento en minutos (opcional; p. ej. `15`). |
| `default` | `string` (ISO 8601) | Fecha-hora por defecto (opcional). Excluyente con `required`. |

## Ejemplo (item de pregunta)

```json
{
  "id": 26,
  "key": "fecha_consulta",
  "type": "DATE_TIME",
  "text": "Fecha y hora de la consulta",
  "order": 7,
  "config": { "required": true, "min": "2026-01-01T00:00:00Z", "max": "2026-12-31T23:59:59Z", "step": 15 }
}
```

## Valor de respuesta (`answer.data`)

`string` en formato ISO 8601 (p. ej. `2026-09-13T14:30:00Z`).

## Fuente

`config` definitivo (ver `README.md`). Contrato del motor frontend
(`../../reference/questionnaire-engine.md`) como referencia inicial.
