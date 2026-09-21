# Secciones

Una ficha por sección del expediente. Cada ficha documenta la estructura de la
sección (preguntas, opciones y subrutas), que puede modelarse como **`form`**
(`type: CLINICAL_HISTORY`, secciones C/D/E) **o** como **componente/endpoint de
dominio** (A/B) — ver ADR 045.

| Sección | Ficha | Estado |
|---|---|---|
| A - Registro | [`A_registro.md`](./A_registro.md) — componente de dominio | ✅ (ADR 045) |
| B - Antecedentes heredofamiliares | [`B_ahf.md`](./B_ahf.md) — componente propio ([ADR 043](../../../decisions/043-ahf-componente-dedicado.md)) | ✅ ficha; ⏳ modelado |
| C - APNP | [`C_apnp.md`](./C_apnp.md) | ✅ |
| D - Antecedentes personales patológicos | [`D_antecedentes_pp.md`](./D_antecedentes_pp.md) — **híbrido** ([ADR 045](../../../decisions/045-historia-clinica-componentes-vs-formularios.md)) | ✅ ficha; ⏳ componentes (H5) |
| E - Padecimiento actual | [`E_padecimiento_actual.md`](./E_padecimiento_actual.md) | ✅ |

Fuente de los flujos: `docs/diagrams/0_HISTORIA_CLINICA/flows/`.

### ¿Cuándo es `form` y cuándo componente?

- **`form`** (cuestionario **lineal**): secuencia de preguntas con **una**
  respuesta cada una, guardadas como `answer` por `assignment`. Ej.: **C (APNP)**,
  **E (Padecimiento actual)**.
- **Componente/endpoint de dominio**: dato **persistente** con cardinalidad
  **1:N** (o matriz/registros), que se **actualiza/precarga** y mapea a entidades
  de dominio. Ej.: **A (Registro)**, **B (AHF)**.

> **A — Registro NO es un cuestionario lineal.** Aunque el flujo del drawio se vea
> como una **secuencia**, sus datos son el **perfil 1:N** — domicilios, teléfonos,
> correos, **tutor** (`person_responsible`) y **contacto de emergencia** — y es
> dato **persistente** (CRUD de `people`/`care`), **no** `answer` de un
> `assignment`. Por eso se modela como **componente/endpoint** y no como `form`
> (ver [ADR 045](../../../decisions/045-historia-clinica-componentes-vs-formularios.md)).

### ¿Estático o catálogo?

Regla derivada de los `.mmd`, aplicada **por pregunta** al crear cada ficha/bank:

| Se ve así en el `.mmd` | Se modela como |
|---|---|
| Opciones **pocas y cerradas** | **estático** → `list_options.items` |
| Un **vocabulario** (gobernado/extensible o masivo/estándar: CIE-11, Vademecum, estudios, body, …) | **catálogo** → `list_options.catalog.{key}` |

> La ficha/pregunta **solo apunta al `key`** del catálogo. El **motor**
> (PostgreSQL/ClickHouse/Mongo) y la **política** (`extensible`/`governed`) los
> define el **registro** de catálogos ([`../../catalogs/`](../../catalogs/),
> [ADR 044](../../../decisions/044-catalogos-gobernados.md)), **no** la ficha.

> **Terminología:** **`enum`** se reserva para **tipos de BD** (entidades de
> dominio, p. ej. `EBiologicalSex`). Las opciones de una **pregunta** son
> **estáticas** (`list_options.items`) o **de catálogo** (`list_options.catalog`);
> **no** se crea un `enum` de BD para ellas.

### Componentes (A/B/D) — qué se documenta

- **Estructura**: la ficha `sections/<x>.md` (✅).
- **Contrato del componente → dominio** (qué entidades/columnas lee/escribe el
  endpoint): documentados en [`../contracts/`](../contracts/). Medicación definida
  en [`../contracts/medication_statement.md`](../contracts/medication_statement.md);
  el resto (alergias, cirugías, AHF) pendiente de definir.
- **No** se documenta aquí: el **DDL/modelo** (vive en `db/postgres/…`) ni un
  **mapper** (el mapper es **solo preguntas** de `form`).

### Secciones híbridas

Una sección puede ser **mixta**: `form` **+** componentes. El `form` (banco) lleva
**solo las preguntas nativas**; los **componentes** se **inyectan** por el front,
que los reconoce **por el `key` (o `id`) del `form`** — **sin** cambiar el shape
del `form`. Ej.: **D** (tabaco/alcohol/drogas/donación = `form`;
alergias/cirugías/lesiones/transfusiones/hospitalizaciones = componentes). Ver
[ADR 045](../../../decisions/045-historia-clinica-componentes-vs-formularios.md).

## Convención — reconciliación con la fuente

Cadena de verdad: **drawio → `.mmd` → ficha → artefacto** (`bank/…json` para un
`form`, contrato de dominio para un componente).

- La **ficha** es **derivada**: antes de crear el artefacto de una sección, hay
  que **reconciliarla** con su `.mmd`
  (`docs/diagrams/0_HISTORIA_CLINICA/flows/<seccion>.mmd`).
- Si el `.mmd` (o el drawio) **cambió**, se actualiza la ficha.
- Si la ficha **agrega** un campo **ausente en la fuente** pero necesario
  (p. ej. el nombre del tutor), se marca como **divergencia intencional** con
  nota `⚠️` y se registra como **gap de la fuente**.
- Los **TODO del drawio** (p. ej. `FALTA PONER GRUPO ÉTNICO`) se conservan
  señalados y quedan como **pendientes**.
