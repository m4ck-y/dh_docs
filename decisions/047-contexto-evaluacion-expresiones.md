# ADR 047: Contexto de evaluación de expresiones — resolver `question.value` por la `person`

## Estado
Aceptado

## Contexto

El AST de expresiones/condiciones ([ADR 039](039-condicion-visibilidad-ast.md),
[ADR 040](040-ast-propiedades-derivadas.md)) referencia respuestas con
`{ "entity": "question", "property": "value", ... }`. Hoy esa referencia se
resuelve contra la **`assignment` en curso** (el form que se está respondiendo).

Eso alcanza para la lógica **dentro de un form**, pero **no** para los
**activadores** ([anexos C/D](../features/clinical_history/README.md)): la
visibilidad de un instrumento (p. ej. CRAFT) depende de respuestas que están en
**otro** form (la HC, sección D). Y el instrumento puede evaluarse **sin**
`assignment` propio.

## Decisión

El AST se evalúa con la **`person`** como contexto. `question.value` se resuelve
así:

```
Entrada: referencia a la pregunta (id | uuid | key)  +  persona P

1. Resolver la pregunta → Q (question.id)
     id   → question.id
     uuid → question WHERE uuid = …
     key  → question WHERE key  = …

2. Q → su form F   (XOR, ADR 038: una u otra)
     questions_form.id_form
     ó questions_section.id_section → section.id_form

3. assignment A = la MÁS RECIENTE de (P, F)
     WHERE id_person = P AND id_form = F AND status = 'SUBMITTED'
     ORDER BY submitted_at DESC  LIMIT 1

4. La respuesta → answer.data.value
     WHERE id_assignment = A AND id_question = Q
```

1. **Ancla = `person`**: las respuestas se buscan en **todos los forms de la
   persona**, no solo en la `assignment` actual.
2. **Identificador global**: `question.id` (PK global), `question.key` (UNIQUE
   global) y `question.uuid`; el selector del AST admite `uuid`
   (`operands.md`).
3. **"Más reciente"**: solo `status = 'SUBMITTED'`, orden por `submitted_at`
   **descendente**.
4. **Convivencia**: sin referencia externa, el sujeto sigue leyéndose del form en
   curso; con una referencia (`uuid`/`key`), se resuelve por el algoritmo.

## Consecuencias

**Positivas:**
- Habilita la lógica **cross-form** (activadores) sin duplicar ni mover datos.
- `answer`/`assignment` **no cambian**: solo cambia **cómo se lee**.
- Una sola regla determinista de resolución.

**Negativas:**
- La resolución hace **joins** (`question` → puente → `assignment` → `answer`).
- Si una persona tiene **varias** `submitted` del mismo form, se toma la **última**
  (las anteriores se ignoran para la condición).
- La reutilización de una pregunta en **dos** forms rompería la unicidad del paso
  2; queda **prohibida** por 1:N (ADR 038 / schema).

## Referencias
- Condición de visibilidad (AST): [ADR 039](039-condicion-visibilidad-ast.md)
- Propiedades derivadas: [ADR 040](040-ast-propiedades-derivadas.md)
- Origen de la `answer`: [ADR 041](041-origen-answer-valores-calculados.md)
- XOR form/sección (1:N): [ADR 038](038-formulario-preguntas-vs-secciones.md)
- Selector y operadores: `docs/features/questionnaires/expressions/operands.md`
- Activadores (anexos C/D): `docs/features/clinical_history/README.md`
