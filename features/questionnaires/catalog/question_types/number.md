# Tipo: `NUMBER`

Valor numérico (entero o decimal).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `min_value` | `number` | Valor mínimo permitido (opcional). |
| `max_value` | `number` | Valor máximo permitido (opcional). |
| `decimals` | `number` | Número de decimales permitidos (`0` = entero). |

## Ejemplo (item de pregunta)

```json
{
  "id": 22,
  "key": "peso_kg",
  "type": "NUMBER",
  "text": "Peso en kilogramos",
  "order": 3,
  "config": { "required": true, "min_value": 1, "max_value": 500, "decimals": 1 }
}
```

## Valor de respuesta (`answer.value`)

`number`

## Fuente

Contrato del motor frontend (`docs/diagrams/schemas/cuestionario/README.md`).
`config` es propuesta inicial.
