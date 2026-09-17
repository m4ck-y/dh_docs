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
| D - Antecedentes personales patológicos | — | ⏳ pendiente |
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

### ¿Catálogo o enum?

Regla (derivada de los `.mmd`): si la lista de un campo incluye **"Otro" /
"Especifique"**, es un **catálogo gobernado** (`extensible: true`, con curaduría —
[ADR 044](../../../decisions/044-catalogos-gobernados.md)); si la lista es
**cerrada**, es un **enum**.

> **"Otro" → create-request:** crea un ítem `PENDING` en el catálogo; al curarse
> pasa a `VALIDATED` (o se fusiona vía `merged_into`) — ADR 044. Modelo, política y
> flujo en [`../../catalogs/`](../../catalogs/).

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
