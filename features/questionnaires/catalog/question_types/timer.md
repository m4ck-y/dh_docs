# Tipo: `TIMER`

**Duración** de tiempo (no una hora del día). El valor se expresa como
**string ISO 8601 de duración** (p. ej. `PT30M`, `PT1H15M`).

> Rescatado de `other_projects/app_questionnaire/` (`my_arquitecture/question/types/timer.md`),
> con evidencia de uso en `cuestionarios/IPAQ.json`.

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `min` | `string` (ISO 8601 duration) | Duración mínima aceptada. |
| `max` | `string` (ISO 8601 duration) | Duración máxima aceptada. |
| `precision` | `string` | Unidad de captura: `seconds`, `minutes`, `hours`. |
| `default` | `string` (ISO 8601 duration) | Duración por defecto (opcional). Excluyente con `required`. |

Sintaxis ISO 8601 de duración: `PnYnMnDTnHnMnS` — en este tipo solo se usan los
componentes de tiempo (`T...`).

| Valor ISO 8601 | Descripción |
|---|---|
| `"PT0M"` | 0 minutos |
| `"PT24H"` | 24 horas |
| `"PT1H30M"` | 1 hora y 30 minutos |
| `"PT45M"` | 45 minutos |

> **Desviación de la fuente:** `timer.md` de la referencia usa
> `min_value`/`max_value`. Aquí se adopta `min`/`max` por **consistencia** con el
> resto de tipos (ver `README.md`).

## Ejemplo (item de pregunta)

```json
{
  "id": 13,
  "key": "ipaq_walk_time",
  "type": "TIMER",
  "text": "¿Cuánto tiempo en total dedicó a caminar en uno de esos días?",
  "order": 2,
  "config": { "required": true, "min": "PT0M", "max": "PT24H", "precision": "minutes" }
}
```

## Valor de respuesta (`answer.value`)

`string` en formato ISO 8601 de duración (p. ej. `"PT1H30M"`). En backend puede
convertirse a `timedelta` para validación.

## Fuente / rescate

Rescatado de `app_questionnaire`:
- `my_arquitecture/question/types/timer.md` (semántica y validación)
- `cuestionarios/IPAQ.json` (uso real: `min_value: "PT0M"`, `max_value: "PT24H"`)
