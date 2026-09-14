# Tipo: `RANGE`

Selección de un **valor numérico entero** dentro de un rango definido (p. ej.
de 0 a 7). Ideal para frecuencias o conteos acotados.

> Rescatado de `other_projects/app_questionnaire/` (`my_arquitecture/question/types/range.md`),
> con evidencia de uso en `cuestionarios/IPAQ.json`.

## `config`

| Campo | Tipo | Descripción |
|---|---|---|
| `required` | `boolean` | Si la pregunta es obligatoria. Excluyente con `default`. |
| `min` | `number` | Límite inferior (inclusive). |
| `max` | `number` | Límite superior (inclusive). |
| `step` | `number` | Incremento permitido. Por defecto `1`. |
| `integer` | `boolean` | Solo números enteros. Por defecto `true`. |
| `default` | `number` | Valor por defecto (opcional). Excluyente con `required`. |

Regla: `min <= respuesta <= max`.

> **Desviación de la fuente:** `range.md` de la referencia usa
> `min_value`/`max_value`. Aquí se adopta `min`/`max` por **consistencia** con el
> resto de tipos (ver `README.md`).

## Ejemplo (item de pregunta)

```json
{
  "id": 12,
  "key": "ipaq_vigorous_days",
  "type": "RANGE",
  "text": "Durante los últimos 7 días, ¿cuántos días realizó actividades físicas vigorosas?",
  "order": 1,
  "config": { "required": true, "min": 0, "max": 7, "step": 1, "integer": true }
}
```

## Valor de respuesta (`answer.value`)

`number` — entero dentro del rango.

## Fuente / rescate

Rescatado de `app_questionnaire`:
- `my_arquitecture/question/types/range.md` (semántica y validación)
- `cuestionarios/IPAQ.json` (uso real: `min_value: 0`, `max_value: 7`)
