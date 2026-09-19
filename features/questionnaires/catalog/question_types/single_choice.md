# Tipo: `SINGLE_CHOICE`

Selección de **una** opción entre varias. Las opciones viven en
`list_options` (JSONB, unión `static` | `catalog`).

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `shuffle` | `boolean` | **Opcional / aditivo.** Muestra las opciones en orden aleatorio. Por defecto `false`. |
| `default` | `number \| string` | `value` de la opción por defecto (opcional). Excluyente con `required`. |

## Opciones (`list_options`)

```jsonc
// estáticas
"list_options": { "source": "static", "items": [ { "uuid": "…", "value": 0, "label": "Nunca", "order": 1 } ] }
// catálogo gobernado
"list_options": { "source": "catalog", "catalog": { "key": "countries" } }
```

- `source: "static"` → `items` (array **no vacío**) de
  `{uuid, value, label, description?, order?, url?}`.
- `source: "catalog"` → `catalog.key` (catálogo **existente** en el registro);
  las opciones salen del catálogo gobernado (ver ADR 044/046).
- `value` es `number` (escalas) o `string` (catálogos).
- El orden **determinista** vive en `item.order`; si `shuffle = true`,
  `item.order` sigue siendo el canónico/base.

## Ejemplo (item de pregunta)

```json
{
  "id": 23,
  "key": "satisfaccion",
  "type": "SINGLE_CHOICE",
  "text": "¿Cómo calificaría la atención recibida?",
  "order": 4,
  "config": { "required": true, "shuffle": false },
  "list_options": { "source": "static", "items": [
    { "value": 4, "label": "Excelente", "order": 1 },
    { "value": 3, "label": "Bueno", "order": 2 },
    { "value": 2, "label": "Regular", "order": 3 },
    { "value": 1, "label": "Malo", "order": 4 }
  ] }
}
```

## Valor de respuesta (`answer.data`)

`number` (escala estática) o `string` (catálogo) — el `value` del ítem elegido.

## Fuente

`config` definitivo (ver `README.md`). Contrato del motor frontend
(`../../reference/questionnaire-engine.md`) como referencia inicial.
