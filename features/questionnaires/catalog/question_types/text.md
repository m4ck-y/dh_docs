# Tipo: `TEXT`

Respuesta de texto corto (una línea).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `min_length` | `number` | Longitud mínima de caracteres (opcional). |
| `max_length` | `number` | Longitud máxima de caracteres (opcional). |
| `default` | `string` | Valor por defecto (opcional). Excluyente con `required`. |

## Ejemplo (item de pregunta)

```json
{
  "id": 20,
  "key": "nombre_paciente",
  "type": "TEXT",
  "text": "Nombre completo",
  "order": 1,
  "config": { "required": true, "min_length": 2, "max_length": 120 }
}
```

## Valor de respuesta (`answer.value`)

`string`

## Fuente

`config` definitivo (ver `README.md`). Contrato del motor frontend
(`docs/diagrams/schemas/cuestionario/README.md`) como referencia inicial.
