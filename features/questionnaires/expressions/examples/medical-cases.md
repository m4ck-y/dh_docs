# Casos de uso médicos

Patrones del lenguaje aplicados a instrumentos reales. Algunos son **scoring**
(`evaluation_expression`); otros son **condiciones de visibilidad**
(`condition`, ver [`../conditions.md`](../conditions.md)).

## 1. PHQ-9 — puntaje total (scoring)

Ver [`phq9-scoring.jsonc`](./phq9-scoring.jsonc) y
[`../operators/aggregate.md`](../operators/aggregate.md).

```jsonc
{ "expression": { "type": "aggregate", "operator": "sum",
  "args": [{ "subject": { "entity": "question", "property": "value", "selector": { "all": true } } }],
  "output": { "type": "number" } } }
```

## 2. PHQ-9 — interpretación (scoring)

Ver [`phq9-evaluation.jsonc`](./phq9-evaluation.jsonc) y
[`../operators/case.md`](../operators/case.md). El `subject` consume
`form.scoring_result`.

## 3. PHQ-9 — condición de la pregunta 10 (visibilidad)

**Lógica médica:** la pregunta 10 (impacto funcional) se muestra solo si
**cualquiera** de las preguntas 1–9 tiene síntomas (valor > 0).

```jsonc
{
  "expression": {
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
}
```

> Este patrón es de **condición de visibilidad**. Su lugar en el modelo es
> `question.condition`; ver [`../conditions.md`](../conditions.md).

## 4. CRAFFT — preguntas condicionales (visibilidad)

**Lógica médica:** las preguntas 5–9 se muestran solo si **cualquiera** de las
preguntas 1–3 es "Sí" (valor == 1).

```jsonc
{
  "expression": {
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
}
```

## 5. Alerta de riesgo alto (scoring/derivado)

Mostrar una alerta si el puntaje del PHQ-9 supera 15 (depresión severa).

```jsonc
{
  "expression": {
    "type": "comparison",
    "operator": ">",
    "args": [
      { "subject": { "entity": "form", "property": "scoring_result" } },
      { "const": { "value": 15, "type": "number" } }
    ],
    "output": { "type": "boolean" }
  }
}
```

## 6. IPAQ — scoring por METs (pendiente C7b)

El IPAQ puntúa por **MET-min/semana**:

```
MET-min/semana(dominio) = MET × minutos × días
total = caminar + moderada + vigorosa
coeficientes: caminar = 3.3, moderada = 4.0, vigorosa = 8.0
```

El AST puede expresarlo con `math` (`*`) + `aggregate sum` sobre los dominios,
pero **no se modela todavía** (pendiente C7b). El único algoritmo completo está
en `docs/diagrams/3_CUESTIONARIO_FISICO/IPAQ.pseint`.
