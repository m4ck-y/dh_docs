# ADR 042: Contrato de la pregunta calculada (`question.expression`)

## Estado
Aceptado

## Contexto

C7c definió `question.expression` (una expresión, valor autocalculado y solo
lectura) y [ADR 041](041-origen-answer-valores-calculados.md) su persistencia
como fila de `answer` (`source = CALCULATED`). Quedaba por fijar el **contrato
completo** de una pregunta calculada: su `text`, `type`, `config`, cómo
interactúa con el scoring y el progreso, y qué está **prohibido** modelar como
pregunta.

## Decisión

1. **`text` obligatorio.** Una pregunta con `expression` debe llevar `text`
   (es la etiqueta del valor; no hay opciones que den contexto). Se valida en la
   capa de aplicación (igual que el XOR de [ADR 038](038-formulario-preguntas-vs-secciones.md)).
2. **`type` libre, pero compatible.** Cualquier `EQuestionType` es válido siempre
   que `expression.output.type` sea compatible con `question.type` /
   `answer.data.type` (p. ej. `NUMBER`↔`number`, `TEXT`↔`string`,
   `TIMER`↔`duration`).
3. **Sin `config`.** `config` describe cómo **responde** el usuario; una calculada
   no tiene input. El valor persistido es el **cálculo crudo**; el formato
   (redondeo, unidades) es **presentación**. No hay operador `round` en el AST.
4. **No es el resultado global del instrumento.** `question.expression` modela un
   valor **derivado de la pregunta** (p. ej. IMC o la diferencia entre dos
   ítems). El resultado global (puntaje/evaluación/subescalas) vive en
   `form.expression` y se persiste en `assignment.result`. Poner el "total del
   cuestionario" como pregunta **duplica el scoring** y provoca **doble conteo**.
   `form.result.*` sigue **prohibido** en expresiones (circular, ver
   [ADR 040](040-ast-propiedades-derivadas.md)).
5. **`all` incluye las calculadas.** El selector `{ all: true }` es literal: lee
   todas las preguntas con valor, incluidas las calculadas. El scoring
   **selecciona** las preguntas que puntúan con `range`/`id`; las calculadas que
   no puntúan (p. ej. IMC) se omiten en esa selección.
6. **Presentación.** La calculada es una pregunta normal (`key`, `text`, `type`,
   `order`) pero **solo lectura**; el widget lo decide la **capa de presentación**.
7. **Progreso.** Las calculadas se excluyen del progreso (numerador **y**
   denominador). El 100% es alcanzable: un form con 8 respondibles y 2 calculadas
   se completa en `8/8`, no `8/10`.

## Consecuencias

**Positivas:**
- El contrato cierra el caso "calculada sin `text`" (antes indefinido) y evita
  usar preguntas para duplicar el scoring.
- El progreso no se bloquea ni se infla por las calculadas.

**Negativas / a vigilar:**
- La regla 4 es **semántica** (no validable mecánicamente más allá de prohibir
  `form.result.*`); se controla por revisión/convención.
- Con `all` literal, un autor que use `{ all: true }` en un instrumento con
  calculadas **sí** las incluirá; debe usar `range`/`id`.

## Referencias
- Definición y persistencia: [ADR 041](041-origen-answer-valores-calculados.md),
  `features/questionnaires/expressions/README.md` §1.
- Selectores: `features/questionnaires/expressions/operands.md`.
- Prohibición de `form.result.*`: [ADR 040](040-ast-propiedades-derivadas.md).
- Tracker: `docs/tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md`
  (C19).
