# Tipo: `DATE`

Fecha (sin hora).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `min` | `string` (`YYYY-MM-DD`) | Fecha mínima permitida (opcional). |
| `max` | `string` (`YYYY-MM-DD`) | Fecha máxima permitida (opcional). |
| `default` | `string` (`YYYY-MM-DD`) | Fecha por defecto (opcional). Excluyente con `required`. |

## Ejemplo (item de pregunta)

```json
{
  "id": 25,
  "key": "fecha_nacimiento",
  "type": "DATE",
  "text": "Fecha de nacimiento",
  "order": 6,
  "config": { "required": true, "min": "1900-01-01", "max": "2026-12-31" }
}
```

## Valor de respuesta (`answer.data`)

`string` en formato `YYYY-MM-DD`.

## Fuente

`config` definitivo (ver `README.md`). Contrato del motor frontend
(`../../reference/questionnaire-engine.md`) como referencia inicial.
