# Tipo: `NUMBER`

Valor numérico (entero o decimal).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `min` | `number` | Valor mínimo permitido (opcional). |
| `max` | `number` | Valor máximo permitido (opcional). |
| `decimals` | `number` | Número de decimales permitidos (`0` = entero). |
| `step` | `number` | Incremento permitido (opcional). |
| `default` | `number` | Valor por defecto (opcional). Excluyente con `required`. |

## Ejemplo (item de pregunta)

```json
{
  "id": 22,
  "key": "peso_kg",
  "type": "NUMBER",
  "text": "Peso en kilogramos",
  "order": 3,
  "config": { "required": true, "min": 1, "max": 500, "decimals": 1 }
}
```

## Valor de respuesta (`answer.data`)

`number`

## Fuente

`config` definitivo (ver `README.md`). Contrato del motor frontend
(`docs/diagrams/schemas/cuestionario/README.md`) como referencia inicial.
