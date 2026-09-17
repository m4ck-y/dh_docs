# B. AHF (Antecedentes Heredofamiliares)

> **Fuente:** `flows/antecedentes_heredofamiliares.mmd` (drawio
> `0_DEMO_HISTORIA_CLINICA.drawio`, tab "B - ANTECEDENTES HEREDOFAMILIARES").
> **Modelado:** **componente/endpoint de dominio** (no `form`): **matriz familiar
> × enfermedad** (`FamilyMemberHistory`) — ver [ADR 043](../../../decisions/043-ahf-componente-dedicado.md).

## Naturaleza (por qué no es `form`)

- Es una **matriz** (~6 familiares × ~60 enfermedades en **13 categorías** CIE-11),
  no una lista plana de preguntas; + "¿vive?" + causa de fallecimiento **por
  familiar** + "**Otro**" por celda.
- Dato **persistente de dominio** (`id_person`), precargable; **no** `answer` de un
  `assignment`.
- **Componente propio** (captura tipo family-tree) — [ADR 043](../../../decisions/043-ahf-componente-dedicado.md);
  prototipos en [`../proposals/family_condition/`](../proposals/family_condition/).

## Bloques de captura

`Familiar → ¿Vive? (+ causa) → Categoría → Enfermedades (multiselect) → ¿Otro familiar? → Guardar`

## Presentación (UI)

La idea de UI en el **frontend** es un **árbol genealógico (genograma)**, como la
propuesta interactiva
[`../proposals/family_condition/family_tree.html`](../proposals/family_condition/family_tree.html)
(ver [ADR 037](../../../decisions/037-family-conditions-ui-prototype.md)). Las otras
vistas de la carpeta (matriz / listas) son prototipos alternativos, **no** el
diseño final.

## Estructura (del `.mmd`)

- **1.0** _Registre aquí las enfermedades o condiciones de salud que conozca en sus
  familiares (padres, hijos o abuelos)._ — instrucción general.
- **2.0 Seleccione el familiar sobre el que desea proporcionar información**
  - 2.1 Padre · 2.2 Madre · **2.3 Hijos** _(repetible)_ · 2.4 Abuelo materno ·
    2.5 Abuelo paterno · 2.6 Abuela materna · 2.7 Abuela paterna
- **3.0 ¿Esta persona vive actualmente?** — Sí / No
  - 3.2 No → **3.2.1 ¿Cuál fue la causa de su fallecimiento?** (texto libre /
    3.2.1.2 No lo sé)
- **4.0 Seleccione la categoría de salud** donde desea registrar un padecimiento
  (4.1–4.13).
- **4.1A–4.13A Seleccione la enfermedad o enfermedades** que presenta o presentó
  su familiar (multiselect por categoría).
- **5.0 ¿Desea completar los antecedentes de otro familiar?** — 5.1 Sí _(repite
  flujo)_ / 5.2 No
- **6.0 Guardar**.

### Categorías (4.1–4.13) y enfermedades (CIE-11)

- **4.1 Diabetes, colesterol y metabolismo** — Diabetes · Prediabetes · Obesidad ·
  Colesterol/triglicéridos altos · Hipotiroidismo · Hipertiroidismo · Otro
- **4.2 Presión alta y corazón** — Presión alta · Infarto · Arritmias ·
  Insuficiencia cardiaca · Otro
- **4.3 Cerebro y sistema nervioso** — Migraña · Embolia/derrame · Alzheimer ·
  Demencia · Parkinson · Epilepsias · Huntington · Otro
- **4.4 Mente, emociones y aprendizaje** — Depresión · Ansiedad · Bipolar ·
  Autismo · TDAH · Esquizofrenia · Otro
- **4.5 Pulmones y respiración** — Asma · EPOC · Rinitis alérgica · Ronquidos ·
  Fibrosis pulmonar · Otro
- **4.6 Visión y ojos** — Cataratas · Glaucoma · Problemas de graduación ·
  Retinopatía diabética · Otro
- **4.7 Estómago, intestino y digestión** — Gastritis/úlceras · Reflujo ·
  Colitis/intestino irritable · Enfermedad inflamatoria intestinal · Piedras en la
  vesícula · Otro
- **4.8 Hígado, riñón y páncreas** — Hígado graso no alcohólico · Hígado graso por
  alcohol · Hepatitis por virus · Cirrosis · Enfermedad renal crónica · Piedras en
  los riñones · Pancreatitis · Otro
- **4.9 Huesos, músculos y articulaciones** — Artritis reumatoide · Osteoporosis ·
  Desgaste de articulaciones · Fibromialgia · Otro
- **4.10 Piel, cabello y uñas** — Dermatitis · Psoriasis · Vitiligo · Alopecia ·
  Otro
- **4.11 Cáncer y tumores** — Cáncer de mama · Próstata · Colon · Leucemia ·
  Ovario · Otro
- **4.12 Hereditarias y autoinmunes** — Síndrome de Down · Lupus · Esclerosis
  múltiple · Fibrosis quística · Otro
- **4.13 Enfermedades de la sangre** — Anemia · Problemas de coagulación · Várices
  · Trombosis venosa · Otro

> Los códigos CIE-11 por enfermedad están en el `.mmd` (p. ej. Diabetes `Block
> 2-5A1`, Infarto `BlockL1-BA4`, Depresión `BlockL2-6A7`).

## Entidades (dominio, a modelar — H1)

| Entidad | Campos | Rol |
|---|---|---|
| `family_member` | `id_person`, `type_relationship`, `alive`, `death_cause`, `name?` | Un familiar (Hijos repetibles) |
| `family_condition` | `id_family_member`, `id_disease`, `other_text` | La **celda** familiar × enfermedad |
| `disease` / `disease_category` | código CIE-11, categoría | Catálogo (`key`) |

- Mapea a FHIR **`FamilyMemberHistory`** (relación + condiciones + fallecimiento).

## Vocabularios y catálogos

- **`disease` / `disease_category`** (CIE-11) — **catálogo** (la ficha apunta al `key`;
  el motor lo resuelve el registro — `catalogs/`). El "Otro" del `.mmd` se resuelve al
  modelar (buscar en CIE-11 completo vs crear) — H3.
- **`type_relationship`** (Padre/Madre/Hijo/abuelos) — **enum** (cerrado).
- **"Otro"** (texto por celda) — ⏳ definir grano (**por categoría** vs **por
  enfermedad**) — H1.

## Divergencias de la fuente

- **`2.3 Hijos` es repetible** ("número máximo de repetición de llenado, sólo
  hijos", nota del drawio).
- Los **loops** "¿otro familiar?" (5.0) y "¿otro padecimiento?" se resuelven en UI
  con botones (ver [`../proposals/family_condition/README.md`](../proposals/family_condition/README.md)),
  no como preguntas.

## Pendiente (H1)

- Modelado de las entidades de dominio + endpoint (`family_member`,
  `family_condition`, catálogo `disease`): schema de destino (`family_history` vs
  `health_profile`), reuso de CIE-11 (`form.cie11_code`) y grano de "Otro".
  Ver [`OPEN-QUESTIONS.md`](../../../tasks/TASK-017-historia-clinica/planning/OPEN-QUESTIONS.md) (H1, H3).
