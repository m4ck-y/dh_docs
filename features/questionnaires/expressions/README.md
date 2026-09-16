# Lenguaje de expresiones

Gramática del **lenguaje de expresiones** del módulo de cuestionarios. Define
las dos clases de expresión que un `form` declara:

- **`scoring`** — calcula el **puntaje numérico** de una asignación.
- **`evaluation`** — clasifica ese puntaje en una **categoría (texto)**.

Ambas viven en el envelope **`form.expression`** (JSONB; ver `../schema.sql`) y su
**resultado** se persiste en **`assignment.result`**. El motor del backend evalúa
las expresiones al enviar el formulario (`SUBMITTED`); el frontend las interpreta
para renderizar/scoring en cliente.

> **Fase actual: definición.** Este documento fija el **contrato**. El motor del
> frontend todavía usa la forma simplificada de rangos (§5) y migrará a esta
> gramática en una fase posterior (ver D12 en `../../../tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md`).

## 1. Envelope `expression` / `result`

`form.expression` agrupa las recetas; `assignment.result` agrupa los resultados,
**con la misma forma**:

```ts
expression = { definitions?, scoring?, evaluation?, subscales? }
result     = { definitions?, scoring?, evaluation?, subscales? }   // mismos valores calculados
```

| Caso | `expression` / `result` |
|---|---|
| 1 escala (PHQ-9) | `{ scoring, evaluation }` |
| N escalas (HADS) | `{ subscales: [ {id, name, items, max, scoring, evaluation}, … ] }` |
| Con intermedios (IPAQ) | `{ definitions, scoring, evaluation }` |
| Mixto | `{ definitions, scoring, evaluation, subscales }` |

Al enviar un formulario (caso simple):

```
expression.scoring  →  result.scoring  →  expression.evaluation  →  result.evaluation
   (aggregate sum)        (11)              (case sobre 11)          ("moderada")
```

### Definiciones (`definitions`) y `ref`

Para instrumentos con **valores intermedios reutilizados** (p. ej. los METs del
IPAQ), el envelope declara un mapa **`definitions`**: cada entrada es una
**fórmula con nombre** (como un `let`/`const` o un `WITH` de SQL). Otras
expresiones leen su valor con el operando **`{ "ref": "nombre" }`**:

```jsonc
"definitions": {
  "min_vig":    { /* fórmula que produce un número */ },
  "total_mets": { "type":"math", "operator":"+", "args":[ { "ref":"total_vig" }, … ], "output":{ "type":"number" } }
},
"scoring":    { "ref": "total_mets" },
"evaluation": { /* case/when que usa { "ref":"total_mets" } */ }
```

- Cada definition es una **fórmula** (un operador) con un **nombre**.
- Se evalúan **una sola vez** (ordenadas por dependencias) y son **inmutables**.
- Un `{ ref }` es un **operando** (5.ª variante, ver [`operands.md`](./operands.md)).
- Los valores intermedios se **persisten** en `result.definitions` (§6).

> **Extensión del proyecto.** Ni `definitions`/`ref` ni el operador `minutes`
> (§7) existen en la gramática de referencia (`typescript.ts`); se añaden aquí.

### Regla del wrapper (raíz vs operando)

| Contexto | Wrapper `{expression: ...}` | Por qué |
|---|---|---|
| **Raíz** de un campo (`expression.scoring`, `expression.evaluation`, `condition`, cada definition) | ❌ **sin** wrapper | El tipo ya se conoce: es una expresión |
| **Operando** (`args`, `subject`, `cases[].operand`, `then`, `default`) | ✅ **con** wrapper | `args` es una unión de variantes; la clave es el discriminante |

Las 5 variantes de operando ([`operands.md`](./operands.md)):
`{ "subject": … }`, `{ "const": … }`, `{ "expression": … }`, `{ "time_range": … }`,
`{ "ref": "nombre" }`.

### Convención del `subject`

El `subject` del `evaluation` **consume el `result.scoring`**, no repite la
fórmula del scoring:

```jsonc
"subject": { "subject": { "entity": "form", "property": "result.scoring" } }
```

Así la fórmula del puntaje vive **una sola vez** (`expression.scoring`) y la
evaluación la reutiliza. Con subescalas, el scoping es **por contexto** (ver §4).
Detalle en [`operators/case.md`](./operators/case.md).

### Puntos de aplicación del AST

| Nivel | Campo | Qué produce | Estado |
|---|---|---|---|
| `form` | `expression.definitions` | Valores intermedios con nombre | ✅ |
| `form` | `expression.scoring` | Puntaje | ✅ |
| `form` | `expression.evaluation` | Categoría | ✅ |
| `form` | `expression.subscales[]` | Puntaje + categoría por escala | ✅ |
| `question` | `expression` | Valor autocalculado (solo lectura) | ✅ (ver §1, persistencia) |
| `form` / `section` / `question` | `condition` | Visibilidad (booleano) | ✅ (ver [`conditions.md`](./conditions.md)) |

### Preguntas autocalculadas y persistencia

Cuando una `question` declara **`expression`** (una expresión, raíz sin wrapper),
su valor es de **solo lectura**: el motor lo calcula y el usuario no la responde.

- **Qué puede leer**: preguntas del mismo form (incluidas **otras calculadas**,
  resueltas en orden de dependencias y con **validación de ciclos**), `person`,
  `const` y `{ref}` a `definitions` del form. **Prohibido** `form.result.*`
  (sería circular).
- **Cuándo se persiste**: se recalcula **en vivo** durante el llenado y se
  guarda **al enviar** (`SUBMITTED`), junto con `assignment.result`.
- **Cómo se persiste**: como una fila de `answer` con
  **`source = CALCULATED`** y `answered_by = NULL`, con `data = {value, type}`.
  Así `question.value` (ver [`operands.md`](./operands.md)) respalda **también**
  las calculadas, sin casos especiales en el scoring (selectores `range`/`all`).
- **Por qué es snapshot**: es el registro histórico de "cómo se llegó a la
  evaluación". Si el valor depende de `person` (edad, IMC), cambiar después a la
  persona **no** reescribe lo ya enviado.
- **Receta**: no se persiste (el resultado es el valor); la receta vive en
  `question.expression`. La tabla `answer` y el origen `EAnswerSource` se
  documentan en [`../schema.sql`](../schema.sql) y
  [ADR 041](../../../decisions/041-origen-answer-valores-calculados.md).

### Contrato de la pregunta calculada (C19)

Reglas que fija la pregunta calculada (ver
[ADR 042](../../../decisions/042-contrato-pregunta-calculada.md)):

- **`text` obligatorio**: una calculada **debe** llevar `text` (es la etiqueta
  del valor; no hay opciones que den contexto). Validación de aplicación.
- **`type` libre, pero compatible**: `expression.output.type` debe coincidir con
  `question.type` / `answer.data.type` (p. ej. `NUMBER`↔`number`,
  `TEXT`↔`string`, `TIMER`↔`duration`).
- **Sin `config`**: `config` describe cómo **responde** el usuario; una calculada
  no lo lleva. El valor persistido es el **cálculo crudo**; el formato (redondeo,
  unidades) es **presentación** (no hay operador `round`).
- **No es el resultado global del instrumento**: una calculada expresa un valor
  **derivado de la pregunta** (IMC, edad, diferencia entre ítems). El puntaje/
  evaluación global vive en `form.expression` y `assignment.result`; poner el
  "total" como pregunta **duplica el scoring** y provoca **doble conteo**.
- **`all` incluye las calculadas** (literal, ver [`operands.md`](./operands.md)):
  el scoring **selecciona** las preguntas que puntúan con `range`/`id`.
- **Presentación**: read-only; el widget lo decide la **capa de presentación**.
- **Progreso**: las calculadas se excluyen del progreso (numerador y
  denominador); el 100% es alcanzable (8 respondibles + 2 calculadas = `8/8`).

Ejemplo: [`examples/question-expression.jsonc`](./examples/question-expression.jsonc)
(IMC y diferencia entre ítems).

## 2. Alcance y frontera

| Tema | Dónde vive |
|---|---|
| Expresiones de **scoring** y **evaluación** | **Este documento** y sus subdocumentos (A2) |
| Condiciones de **visibilidad** (`condition`) | [`conditions.md`](./conditions.md) (A1/A3) |
| Tipos de pregunta y su `config` | [`../catalog/question_types/`](../catalog/question_types/) |
| Forma de `answer.data` | [`../catalog/README.md`](../catalog/README.md) §8 |

La gramática es un **AST** genérico (no exclusiva de scoring): el mismo lenguaje
expresa cálculos biométricos, promedios temporales o condiciones. La unificación
con condiciones ya está hecha: ver [`conditions.md`](./conditions.md).

## 3. Índice de la gramática

| Documento | Contenido |
|---|---|
| [`operators/`](./operators/) | Las 7 familias de operadores (uno por archivo): `math`, `comparison`, `logic`, `aggregate`, `collection`, `case`, `time`. |
| [`operands.md`](./operands.md) | Los 4 tipos de operando, entidades/propiedades y selectores. |
| [`conditions.md`](./conditions.md) | Condiciones de visibilidad (`condition`) en form/section/question. |
| [`factories.md`](./factories.md) | Factory functions de la referencia (para el motor del backend). |
| [`examples/`](./examples/) | Ejemplos `.jsonc` y casos médicos. |

### Resumen de operadores

```ts
interface BaseOperator {
  type: string;                 // familia
  operator: string;             // operación
  args: CalculationOperand[];   // operandos
  output: { type: DataType };   // tipo del resultado
}
```

| Familia (`type`) | Operadores | Salida | Uso en scoring |
|---|---|---|---|
| `math` | `+` `-` `*` `/` `%` `^` | `number` | METs, ponderaciones |
| `comparison` | `==` `!=` `>` `<` `>=` `<=` `in` | `boolean` | Condiciones de `case/when` |
| `logic` | `and` `or` `not` | `boolean` | Combinar condiciones |
| `aggregate` | `sum` `avg` `min` `max` `count` | `number` | **Puntaje** |
| `collection` | `all` `any` `none` | `boolean` | Colecciones |
| `case` | `when` (fijo) | cualquier `DataType` | **Clasificación** |
| `time` | `range` `movingavg` `delta` `minutes` | `number` \| `array_number` | Series temporales; `minutes` convierte una duración a minutos |

Tipo de dato:

```ts
type DataType =
  | "number" | "string" | "boolean" | "date"
  | "datetime" | "duration"
  | "array_string" | "array_number" | "array_object";
```

> **Nota sobre `type`.** En el AST, `type` aparece con dos sentidos según el
> nivel: en un **operador** es la **familia** de la operación
> (`"type": "aggregate"`); en un **valor** (`const`, `result.*`, `answer.data`)
> o en la **salida** (`output: {type}`) es
> el **tipo de dato** (`"type": "number"`). Están en niveles distintos y no se
> confunden al parsear, pero conviene tenerlo presente al leer el modelo.

> `datetime` (fecha-hora) y `duration` (duración ISO 8601) se añadieron para
> cubrir los tipos de pregunta `DATE_TIME` y `TIMER` (ver §6 y `conditions.md`).

## 4. Subescalas

El AST no tiene una dimensión de subescala, así que el envelope declara un
arreglo **`subscales`**, donde cada subescala es una unidad autocontenida:

```jsonc
"expression": {
  "subscales": [
    {
      "id": "A",
      "name": "Ansiedad",
      "items": [1, 3, 5, 7, 9, 11, 13],   // ← única fuente de pertenencia
      "max": 21,
      "scoring":    { /* aggregate sum, scopeado a esta subescala */ },
      "evaluation": { /* case/when propio de la subescala */ }
    }
  ]
}
```

### Scoping por contexto

- **`items`** es la **única** fuente de pertenencia (lista de ids de pregunta). No
  se usa `question.group` ni un selector `{group}`.
- El **`scoring`** de una subescala suma **sus** `items` (no repite la lista): el
  evaluador usa el `items` de la subescala que lo contiene.
- El **`evaluation`** de la subescala consume **su** `result.scoring` (mismo
  scoping por contexto).

Es exactamente el modelo del motor MVP: `sumItems(subscale.items, answers)` +
bandas filtradas por subescala.

- Un instrumento **sin** subescalas declara `expression.scoring` +
  `expression.evaluation` a nivel `form`.
- El puntaje global (si aplica, además de subescalas) es un `expression.scoring`
  /`evaluation` de nivel `form`.

Ejemplos: [`examples/hads-expression.jsonc`](./examples/hads-expression.jsonc) y
[`examples/hads-result.jsonc`](./examples/hads-result.jsonc).

## 5. Relación con la forma simplificada del MVP

El motor del frontend actual usa rangos cerrados:

```ts
interface Scoring { tipo: 'suma' | 'subescalas'; maximo?: number; items?: number[]; subescalas?: Subscale[]; }
interface InterpretationRange { desde: number; hasta: number; texto: string; subescala?: string; }
```

| MVP | AST |
|---|---|
| `scoring.tipo: 'suma'` | `expression.scoring` (`aggregate sum`) |
| `scoring.tipo: 'subescalas'` | `expression.subscales[]` con `scoring` por subescala |
| `interpretacion[] {desde, hasta, texto}` | `case/when` con umbrales acumulativos |
| `interpretacion[].subescala` | `expression.subscales[]` (cada una con su `evaluation`) |

**Diferencia de límites:** los rangos del MVP son **inclusivos**
(`score >= desde && score <= hasta`); el `case/when` usa umbrales (`<`/`<=`).
Para enteros coinciden; para puntajes continuos hay que fijar la semántica de
borde al migrar.

> La migración de `scoring.ts`/`banks/*.ts` a esta forma es parte del **frontend**
> (pendiente D12), fuera de esta fase.

## 6. Resultados persistidos

El resultado de evaluar las expresiones se guarda en **`assignment.result`**
(evento único), con la **misma forma** que `form.expression` y cada valor como un
`const` del AST (`{value, type}`):

```jsonc
// Caso simple (PHQ-9)
"result": {
  "scoring":    { "value": 11, "type": "number" },
  "evaluation": { "value": "Depresión moderada", "type": "string" }
}

// Caso con subescalas (HADS)
"result": {
  "subscales": [
    { "id": "A", "scoring": { "value": 8, "type": "number" },
                  "evaluation": { "value": "Probable ansiedad", "type": "string" } },
    { "id": "D", "scoring": { "value": 5, "type": "number" },
                  "evaluation": { "value": "Normalidad", "type": "string" } }
  ]
}

// Caso con definitions (IPAQ): se persisten los intermedios
"result": {
  "definitions": {
    "min_vig":    { "value": 30,   "type": "number" },
    "total_vig":  { "value": 1680, "type": "number" },
    "total_mets": { "value": 2100, "type": "number" }
  },
  "scoring":    { "value": 2100,       "type": "number" },
  "evaluation": { "value": "Moderado", "type": "string" }
}
```

- `value` + `type` espejan el operando `const` (`{const:{value,type}}`).
- No se persiste la **receta** en el resultado: el resultado es el **valor
  calculado**.
- `definitions` en el resultado es un mapa `nombre → {value, type}` con los
  valores intermedios (útil para auditar/exportar, como la salida del `.pseint`).

## 7. Scoring no lineal: METs (IPAQ)

El IPAQ puntúa por **MET-min/semana**, no por suma simple:

```
min_vig = minutos(Q2);  min_mod = minutos(Q4);  min_cam = minutos(Q6)
total_vig = 8.0 * min_vig * Q1;  total_mod = 4.0 * min_mod * Q3;  total_cam = 3.3 * min_cam * Q5
total_mets = total_vig + total_mod + total_cam
```

Se modela con el AST así:

- **`definitions`** guardan los intermedios (`min_vig`, `total_vig`, `total_mets`…),
  reutilizables sin repetir fórmulas.
- **`time: minutes`** convierte la respuesta `TIMER` (duración ISO 8601, p. ej.
  `"PT30M"`) a **minutos** (número).
- **`scoring`** es `{ "ref": "total_mets" }`.
- **`evaluation`** es un **`case` condition-based** (Alto / Moderado / Bajo) que
  usa `{ref}` sobre condiciones nombradas (`es_alto` / `es_moderado`) definidas
  con `logic`/`comparison`.

Ejemplo completo: [`examples/ipaq-expression.jsonc`](./examples/ipaq-expression.jsonc)
y [`examples/ipaq-result.jsonc`](./examples/ipaq-result.jsonc).

> **Alternativa futura (no adoptada):** una **familia genérica `convert`** con
> campo `to` (`{ "type":"convert", "operator":"duration", "to":"minutes", ... }`)
> serviría para otras unidades (segundos, horas, kg↔lb…). Se descarta por ahora
> (YAGNI): `time: minutes` cubre la única conversión necesaria y usa el shape base
> sin excepciones. Si aparece un **segundo** tipo de conversión, se promueve a
> `convert`.

## 8. Ejemplos

| Archivo | Qué demuestra |
|---|---|
| [`examples/phq9-expression.jsonc`](./examples/phq9-expression.jsonc) | `form.expression` de 1 escala: `{ scoring, evaluation }` |
| [`examples/hads-expression.jsonc`](./examples/hads-expression.jsonc) | `form.expression` con `subscales[]` |
| [`examples/hads-result.jsonc`](./examples/hads-result.jsonc) | `assignment.result` con `subscales[]` (receta vs resultado) |
| [`examples/ipaq-expression.jsonc`](./examples/ipaq-expression.jsonc) | `definitions` + `{ref}` + `time: minutes` (METs) |
| [`examples/ipaq-result.jsonc`](./examples/ipaq-result.jsonc) | `assignment.result` con `definitions` |
| [`examples/imc-math.jsonc`](./examples/imc-math.jsonc) | `math` anidado (demuestra el AST) |
| [`examples/question-expression.jsonc`](./examples/question-expression.jsonc) | `question.expression`: valor autocalculado (IMC, diferencia) |
| [`examples/medical-cases.md`](./examples/medical-cases.md) | PHQ-9, CRAFFT, riesgo alto, METs |

## Fuente

Gramática adoptada de `other_projects/app_questionnaire/backend/docs/types/`
(`expression.md`, `typescript.ts`). Los ejemplos de scoring provienen de
`cuestionarios/PHQ9.ts` y `cuestionarios/IPAQ.ts`, con las correcciones señaladas
en [`operators/aggregate.md`](./operators/aggregate.md) y §7.
