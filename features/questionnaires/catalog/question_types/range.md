# Tipo: `RANGE`

Selección de un **valor numérico entero** dentro de un rango definido (p. ej.
de 0 a 7). Ideal para frecuencias o conteos acotados.

> Rescatado de `other_projects/app_questionnaire/` (`my_arquitecture/question/types/range.md`),
> con evidencia de uso en `cuestionarios/IPAQ.json`.

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. |
| `min_value` | `number` | Límite inferior (inclusive). |
| `max_value` | `number` | Límite superior (inclusive). |
| `step` | `number` | Incremento permitido. Por defecto `1`. |
| `integer` | `boolean` | Solo números enteros. Por defecto `true`. |

Regla: `min_value <= respuesta <= max_value`.

## Ejemplo (item de pregunta)

```json
{
  "id": 12,
  "key": "ipaq_vigorous_days",
  "type": "RANGE",
  "text": "Durante los últimos 7 días, ¿cuántos días realizó actividades físicas vigorosas?",
  "order": 1,
  "config": { "required": true, "min_value": 0, "max_value": 7, "step": 1, "integer": true }
}
```

## Valor de respuesta (`answer.value`)

`number` — entero dentro del rango.

## Fuente / rescate

Rescatado de `app_questionnaire`:
- `my_arquitecture/question/types/range.md` (semántica y validación)
- `cuestionarios/IPAQ.json` (uso real: `min_value: 0`, `max_value: 7`)
