# Casos de uso médicos

Patrones del lenguaje aplicados a instrumentos reales. Algunos son **scoring**
(`expression.scoring`/`expression.evaluation`); otros son **condiciones de
visibilidad** (`condition`, ver [`../conditions.md`](../conditions.md)).

## 1. PHQ-9 — puntaje total (scoring)

Ver [`phq9-expression.jsonc`](./phq9-expression.jsonc) y
[`../operators/aggregate.md`](../operators/aggregate.md).

```jsonc
{ "type": "aggregate", "operator": "sum",
  "args": [{ "subject": { "entity": "question", "property": "value", "selector": { "all": true } } }],
  "output": { "type": "number" } }
```

## 2. PHQ-9 — interpretación (scoring)

Ver [`phq9-expression.jsonc`](./phq9-expression.jsonc) y
[`../operators/case.md`](../operators/case.md). Cada `when` compara contra
`form.result.scoring`.

## 3. PHQ-9 — condición de la pregunta 10 (visibilidad)

**Lógica médica:** la pregunta 10 (impacto funcional) se muestra solo si
**cualquiera** de las preguntas 1–9 tiene síntomas (valor > 0).

```jsonc
{
  "type": "collection",
  "operator": "any",
  "args": [
    {
      "expression": {
        "type": "comparison",
        "operator": ">",
        "args": [
          {
            "subject": {
              "entity": "question",
              "property": "value",
              "selector": { "range": [1, 9] }
            }
          },
          { "const": { "value": 0, "type": "number" } }
        ],
        "output": { "type": "boolean" }
      }
    }
  ],
  "output": { "type": "boolean" }
}
```

> Este patrón es de **condición de visibilidad**. Su lugar en el modelo es
> `question.condition`; ver [`../conditions.md`](../conditions.md).

## 4. CRAFFT — preguntas condicionales (visibilidad)

**Lógica médica:** las preguntas 5–9 se muestran solo si **cualquiera** de las
preguntas 1–3 es "Sí" (valor == 1).

```jsonc
{
  "type": "collection",
  "operator": "any",
  "args": [
    {
      "expression": {
        "type": "comparison",
        "operator": "==",
        "args": [
          {
            "subject": {
              "entity": "question",
              "property": "value",
              "selector": { "range": [1, 3] }
            }
          },
          { "const": { "value": 1, "type": "number" } }
        ],
        "output": { "type": "boolean" }
      }
    }
  ],
  "output": { "type": "boolean" }
}
```

## 5. Alerta de riesgo alto (scoring/derivado)

Mostrar una alerta si el puntaje del PHQ-9 supera 15 (depresión severa).

```jsonc
{
  "type": "comparison",
  "operator": ">",
  "args": [
    { "subject": { "entity": "form", "property": "result.scoring" } },
    { "const": { "value": 15, "type": "number" } }
  ],
  "output": { "type": "boolean" }
}
```

## 6. IPAQ — scoring por METs

El IPAQ puntúa por **MET-min/semana**:

```
MET-min/semana(dominio) = MET × minutos × días
total = caminar + moderada + vigorosa
coeficientes: caminar = 3.3, moderada = 4.0, vigorosa = 8.0
```

Se modela con el AST (ver [`../README.md`](../README.md) §7):

- **`definitions`**: intermedios (`min_vig`, `total_vig`, `total_mets`, `es_alto`…).
- **`time: minutes`**: convierte las respuestas `TIMER` (ISO 8601) a minutos.
- **`ref`**: reutiliza intermedios y condiciones nombradas.
- **`case` condition-based**: clasifica en Alto / Moderado / Bajo.

Ejemplo completo: [`ipaq-expression.jsonc`](./ipaq-expression.jsonc) y
[`ipaq-result.jsonc`](./ipaq-result.jsonc). Algoritmo de referencia:
`docs/diagrams/3_CUESTIONARIO_FISICO/IPAQ.pseint`.
