# D. ANTECEDENTES PERSONALES PATOLÓGICOS

> **Fuente:** `flows/antecedentes_pp.mmd` (drawio `0_DEMO_HISTORIA_CLINICA.drawio`,
> tab "D - ANTECEDENTES PP").
> **Modelado:** **híbrido** — `form` (preguntas de hábitos) **+** componentes de
> dominio (registros 1:N) inyectados por el front — ver
> [ADR 045](../../../decisions/045-historia-clinica-componentes-vs-formularios.md)
> (§"Secciones híbridas") y **H5**.

> **Artefacto:** [`bank/clinical_history/antecedentes_pp.json`](../../questionnaires/catalog/bank/clinical_history/antecedentes_pp.json)
> (**solo el `form`**; los componentes no van en el `form`).

## Bloques de captura

- **`form`** (preguntas nativas, no 1:N): tabaco (`3.0`/`3.0A`/`3.0B`) · alcohol
  (`4.0`) · drogas (`5.0`) · donación (`9.0`).
- **Componentes** (registros 1:N de dominio, **inyectados** por el front):
  enfermedades (`2.0`) · alergias (`6.0`) · cirugías (`7.0`) · transfusión (`8.0`) ·
  lesiones (`10.0`) · hospitalizaciones (`11.0`).

## Clasificación por bloque

| # | Bloque | Tipo | Recurso |
|---|---|---|---|
| 3.0 + 3.0A + 3.0B | tabaco · humo 2.º mano · vapeo | **form** | — |
| 4.0 | alcohol | **form** | — |
| 5.0 | drogas | **form** | — |
| 9.0 | donación de sangre | **form** | — |
| 2.0 | enfermedades (13 categorías) | **componente** (1:N) | `Condition` |
| 6.0 | alergias | **componente** (1:N) | `AllergyIntolerance` |
| 7.0 | cirugías | **componente** (1:N) | `Procedure` |
| 8.0 | transfusión | **componente** | `Procedure` |
| 10.0 | lesiones | **componente** (1:N) | `Procedure` ⚠️ (¿`Condition`?) |
| 11.0 | hospitalizaciones | **componente** (1:N) | `Encounter` |

> **Criterio (ADR 045):** es **componente** si es **1:N/N:N** o un **recurso de
> dominio** (evento clínico); es **form** si es una **pregunta de hábito** con
> **una** respuesta. Los hábitos no son 1:N → **form**.
> **Híbrido (ADR 045 / H5):** el `form` del banco lleva **solo** las preguntas
> nativas; el front reconoce la sección **por el `key` del `form`**
> (`antecedentes_pp`) e **inyecta** los componentes en su punto del orden.

> **Divergencias de la fuente:**
> - La numeración empieza en **`2.0`** (no hay `1.0`).
> - El nodo final dice **`Fin APNP`** (debería ser *Fin APP* / D).
> - `11.1.3 ¿Duración? (11.1.4.1 …)` — **sub-numeración descuadrada**.
> - Los *loops* de la fuente (`7.1.3 Agregar otra cirugía`, `10.1.5 Otra lesión`,
>   `11.1.7 Otra hospitalización`) son la **UI de "agregar registro"**, no preguntas.

## Origen de las listas

| Campo | Origen |
|---|---|
| 2.1–2.13 enfermedades (`2.0`) | catálogo `disease` |
| 6.0 `¿A qué?` categoría (Medicamentos/Alimentos/Ambiente/**Otro**) | catálogo `allergy_category` |
| 6.0 Medicamentos | catálogo `medication` (Vademecum) |
| 5.1.1 drogas `¿Cuál(es)?` | texto libre (regla por pregunta: ¿catálogo?) |
| 3.0A.1.1 lugares · 3.0B.1.1 sustancias · 3.0B.1.2 frecuencia · 11 duración/traslado | **enum** |
| Resto (Sí/No, `Nunca`/`Prefiere no decirlo`) | **enum** |

---

## `form` — bloques nativos

### 3.0 Tabaco
- **3.0 ¿Cómo describiría su consumo de tabaco?** — 3.1 Fuma a diario · 3.2 Fuma
  ocasionalmente · 3.3 Ex fumador/a · 3.4 Nunca ha fumado · 3.5 Prefiere no decirlo
  - 3.1.1 ¿Cuántos cigarros fuma al día? _(`NUMBER`, cond. `3.0 = Fuma a diario`)_
  - 3.3.1 ¿Cuántos fumaba? · 3.3.2 ¿A qué edad empezó? · 3.3.3 ¿A qué edad dejó?
    _(`NUMBER`, cond. `3.0 = Ex fumador/a`)_
- **3.0A ¿Alguien cercano a usted fuma?** — 3.0A.1 Sí · 3.0A.2 No
  - 3.0A.1.1 ¿Dónde ocurre la exposición? (Hogar / Trabajo / Lugares sociales) `MULTIPLE_CHOICE`
  - 3.0A.1.2 ¿Cuántas horas al día? · 3.0A.1.3 ¿Desde hace cuántos años? `NUMBER`
    _(cond. `3.0A = Sí`)_
- **3.0B ¿Usa o ha usado vapeadores?** — 3.0B.1 Sí, los uso actualmente · 3.0B.2
  Estoy intentando dejarlos · 3.0B.3 Los usaba antes · 3.0B.4 Nunca he usado
  - 3.0B.1.1 ¿Qué sustancia usa? (Nicotina / Cannabis-THC / Sólo sabor) `MULTIPLE_CHOICE`
  - 3.0B.1.2 ¿Cada cuánto? (A diario / Varias veces por semana / 1 vez por semana o
    menos / Rara vez) _(cond. `3.0B = Sí, los uso actualmente`)_

### 4.0 Alcohol
- **4.0 ¿Consume bebidas alcohólicas?** — 4.1 Sí · 4.2 No

### 5.0 Drogas
- **5.0 ¿Ha consumido algún tipo de droga?** — 5.1 Sí · 5.2 No
  - 5.1.1 ¿Cuál(es)? _(texto libre; cond. `5.0 = Sí`; ¿catálogo? — regla por pregunta)_

### 9.0 Donación
- **9.0 ¿Ha donado sangre?** — 9.1 Sí · 9.2 No

---

## Componentes — registros 1:N inyectados (modelado ⏳ H5)

### 2.0 Enfermedades — `Condition`
- _¿Padece o ha padecido alguna de estas enfermedades alguna vez en su vida?_ — 13
  categorías (2.1–2.13, CIE-11) con catálogo `disease`:
  2.1 Diabetes, colesterol y metabolismo · 2.2 Presión alta y corazón · 2.3 Cerebro y
  sistema nervioso · 2.4 Emociones, aprendizaje y desarrollo · 2.5 Pulmones y
  respiración · 2.6 Visión y ojos · 2.7 Estómago, intestino y digestión · 2.8 Hígado,
  riñón y páncreas · 2.9 Huesos, músculos y articulaciones · 2.10 Piel, cabello y
  uñas · 2.11 Cáncer y tumores · 2.12 Enfermedades hereditarias y autoinmunes · 2.13
  Enfermedades de la sangre y vasculares.
- **Registro 1:N**: una `Condition` por enfermedad seleccionada.
- ⏳ **Al modelar**: el filtro del catálogo `disease` **por categoría** no es expresable con
  `{source:"catalog", catalog:{key}}` (ADR 046 no tiene `filter`). Alternativas:
  catálogo por categoría, o categoría en el ítem + agrupación en UI.

### 6.0 Alergias — `AllergyIntolerance` (1:N)
- ¿Padece algún tipo de alergia? Sí → **¿A qué?** (Medicamentos *(Vademecum)* /
  Alimentos / Ambiente / Otro) / No · **registro**: sustancia + categoría.
- Vademecum = catálogo `medication`.

### 7.0 Cirugías — `Procedure` (1:N)
- ¿Ha tenido alguna operación o cirugía? Sí → **registro**: `fecha`; *Agregar otra*
  / *Finalizar* → repetible.

### 8.0 Transfusión — `Procedure`
- ¿Le han transfundido sangre? Sí → **registro**: `fecha` · `motivo` / No.

### 10.0 Lesiones — `Procedure` ⚠️ (1:N)
- ¿Ha sufrido alguna de estas lesiones? 10.1 Fractura · 10.2 Luxación · 10.3
  Esguince · 10.4 Ninguna.
  - Fractura → **registro**: ¿qué huesos? · ¿el hueso quedó expuesto? (Sí/No) ·
    ¿qué lado? (Derecho/Izquierdo/Ambos/No aplica) · fecha · secuelas; repetible
    (10.1.5 ¿otra lesión?).
- ⚠️ Duda: una *fractura/luxación/esguince* es más `Condition` que `Procedure`.

### 11.0 Hospitalizaciones — `Encounter` (1:N)
- ¿Ha estado hospitalizado alguna vez? Sí → **registro**: `motivo` · `fecha de
  ingreso` · `duración` (1–7 / 8–14 / 15–30 / más de 30 días) · `programada o
  urgencia` · `de dónde fue trasladado` (Casa / Consulta externa / Otro hospital);
  repetible (11.1.7 ¿otra hospitalización?).

## Pendientes
- **H5** (composición híbrida) → registro `key → componentes + orden` (front).
- **H3** (regla por pregunta): al modelar `disease` resolver el **filtro por
  categoría** y el **"Otro"**; `drug`/`body` según la regla.
- **10.0** (`Condition` vs `Procedure`).
- Banco: `bank/clinical_history/antecedentes_pp.json` (**solo el `form`**).
- **H2 cerrado**: los registros son **1:N** → **componentes**; la repetición vive en
  el dominio (no `answer.repetition`).
