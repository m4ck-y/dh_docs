# `time` — Operadores temporales

Operan sobre series de datos en el tiempo.

## Interface

```ts
interface TimeOperator extends BaseOperator {
  type: "time";
  operator: "range" | "movingavg" | "delta" | "minutes";  // rango, promedio móvil, diferencia, duración→minutos
  args: CalculationOperand[];                  // datos temporales y parámetros de tiempo
  output: { type: "number" | "array_number" }; // según la operación
}
```

## Casos de uso

- Análisis longitudinal: `avg(peso_últimos_10_años)`.
- Tendencias: `delta(síntomas_depresión, 6_meses)`.
- Rangos temporales: `range(mediciones, "-1Y", "NOW")`.
- Conversión de duración: `minutes(duracion_iso)` → número de minutos.

## `minutes` — duración ISO 8601 → minutos

Convierte una **duración** (una respuesta `TIMER`, que se guarda como string ISO
8601, p. ej. `"PT1H30M"`) a un **número de minutos** (`number`):

```jsonc
{
  "type": "time",
  "operator": "minutes",
  "args": [
    { "subject": { "entity": "question", "property": "value", "selector": { "id": 2 } } }
  ],
  "output": { "type": "number" }
}
// "PT1H30M" → 90
```

Es la pieza que permite usar respuestas `TIMER` en aritmética (p. ej. los METs
del IPAQ, ver [`../README.md`](../README.md) §7).

> **Alternativa futura (no adoptada):** una **familia genérica `convert`** con
> campo `to` (`{ "type":"convert", "operator":"duration", "to":"minutes" }`)
> serviría para más unidades (segundos, horas, kg↔lb…). Se descarta por ahora
> (YAGNI); si aparece un **segundo** tipo de conversión, `minutes` se migraría a
> `convert`. Detalle: [`../README.md`](../README.md) §7.

## Fechas relativas y absolutas

```ts
type RelativeOrAbsoluteDate =
  | { relative: string }   // ej. "-10Y", "NOW", "-6M"
  | { absolute: string };  // ISO 8601, ej. "2015-10-05T00:00:00Z"
```

## Ejemplo — promedio de peso en 10 años

```jsonc
{
  "type": "aggregate",
  "operator": "avg",
  "args": [
    {
      "expression": {
        "type": "time",
        "operator": "range",
        "args": [
          { "subject": { "entity": "person", "property": "weight" } },
          {
            "time_range": {
              "start": { "relative": "-10Y" },
              "end": { "relative": "NOW" }
            }
          }
        ],
        "output": { "type": "array_number" }
      }
    }
  ],
  "output": { "type": "number" }
}
```

## Estado en el módulo

No se usa en scoring de cuestionarios. Se documenta como parte del lenguaje,
disponible para cálculos longitudinales sobre datos de salud.
