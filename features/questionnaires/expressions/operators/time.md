# `time` — Operadores temporales

Operan sobre series de datos en el tiempo.

## Interface

```ts
interface TimeOperator extends BaseOperator {
  type: "time";
  operator: "range" | "movingavg" | "delta";  // rango temporal, promedio móvil, diferencia
  args: CalculationOperand[];                  // datos temporales y parámetros de tiempo
  output: { type: "number" | "array_number" }; // según la operación
}
```

## Casos de uso

- Análisis longitudinal: `avg(peso_últimos_10_años)`.
- Tendencias: `delta(síntomas_depresión, 6_meses)`.
- Rangos temporales: `range(mediciones, "-1Y", "NOW")`.

## Fechas relativas y absolutas

```ts
type RelativeOrAbsoluteDate =
  | { relative: string }   // ej. "-10Y", "NOW", "-6M"
  | { absolute: string };  // ISO 8601, ej. "2015-10-05T00:00:00Z"
```

## Ejemplo — promedio de peso en 10 años

```jsonc
{
  "expression": {
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
}
```

## Estado en el módulo

No se usa en scoring de cuestionarios. Se documenta como parte del lenguaje,
disponible para cálculos longitudinales sobre datos de salud.
