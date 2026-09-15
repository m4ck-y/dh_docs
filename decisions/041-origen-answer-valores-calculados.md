# ADR 041: Origen de la `answer` (`source`) y persistencia de valores calculados

## Estado
Aceptado

## Contexto

C7c introdujo `question.expression`: una pregunta puede tener un valor
**autocalculado** (solo lectura, el usuario no la responde). Al modelarlo
quedaron abiertas dos preguntas:

1. ¿El valor calculado se **persiste** o se computa al vuelo?
2. ¿Cómo se **distingue** una respuesta ingresada por un usuario de un valor
   calculado?

Argumentos que pesaron:

- **ADR 040** fija `{ entity: "question", property: "value" }` como propiedad
  derivada respaldada por `answer.data.value`. Si el valor calculado no se
  persiste, esa equivalencia se rompe justo para las calculadas, y un
  `aggregate` con selector `all`/`range` no las incluiría sin casos especiales.
- **Auditoría/histórico**: el valor puede depender de `person` (edad, IMC), que
  es mutable. Sin snapshot, cambiar la persona reescribe la evaluación pasada.
- **Precedente**: en C7b ya se decidió persistir los intermedios del IPAQ en
  `result.definitions`.

## Decisión

1. El valor calculado **se persiste** como una fila de `answer` con
   `data = {value, type}`. Se recalcula **en vivo** durante el llenado y se
   guarda **al enviar** (`SUBMITTED`), junto con `assignment.result`.
2. Discriminador: **`answer.source`**, enum `EAnswerSource { USER, CALCULATED }`
   (default `USER`). `answered_by` sigue siendo un FK nullable y se añade
   `CHECK ((source = 'USER') = (answered_by IS NOT NULL))`: `USER` exige usuario,
   `CALCULATED` exige `NULL`.
3. La **receta** no se persiste (el resultado es el valor); vive en
   `question.expression`.

## Alternativas consideradas y descartadas

1. **Computar al vuelo, sin persistir.** Rompe el mapeo uniforme
   `question.value → answer.data.value` (ADR 040), no deja histórico y obliga al
   scoring a tratar las calculadas aparte.
2. **Persistir en `assignment.result` (mapa aparte).** Mantiene `answer` solo con
   respuestas de usuario, pero rompe la uniformidad y complica los selectores del
   scoring.
3. **`answered_by` como JSONB (unión taggeada `{user}|{calculated}|{ia}`).**
   Máxima extensibilidad (añadir origen no requiere migrar enum), pero **pierde el
   FK** a usuarios y rompe la convención documentada de los `*_by` (todos FK, no
   enums). Se difiere con una regla de promoción: **si `ia` u otro origen necesita
   payload** (modelo, versión), se promueve a `source` (discriminador queryable) +
   `author` JSONB (payload).
4. **`answered_by IS NULL` como discriminador.** Conflaciona "usuario
   desconocido/legacy" con "calculada" y hace ilegible la consulta de métricas.

## Consecuencias

**Positivas:**
- `question.value` respalda **también** las calculadas: scoring uniforme
  (selectores `all`/`range` las incluyen sin casos especiales).
- Histórico auditable: snapshot de valores dependientes de `person`.
- `answered_by` deja de ser un `NULL` indefinido: el `CHECK` lo ata a `source`.

**Negativas:**
- Una fila calculada ocupa espacio en `answer` (redundante para las
  deterministas). Se acepta por uniformidad y auditoría.
- Las métricas de progreso deben **excluir** `source = 'CALCULATED'`.

## Referencias
- Persistencia y semántica: `features/questionnaires/expressions/README.md`
- Catálogo: `features/questionnaires/catalog/README.md` §6/§8
- Ejecución: `features/questionnaires/responses/README.md`
- Modelo físico: `features/questionnaires/schema.sql` (`question.expression`,
  `answer.source`)
- Decisiones relacionadas: [ADR 039](039-condicion-visibilidad-ast.md),
  [ADR 040](040-ast-propiedades-derivadas.md)
- Pendiente: `docs/TODO/cuestionarios.md` (C7c)
