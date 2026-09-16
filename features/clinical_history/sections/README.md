# Secciones

Una ficha por sección del expediente. Cada ficha documenta la estructura de la
sección (preguntas, opciones y subrutas), que puede modelarse como **`form`**
(`type: CLINICAL_HISTORY`, secciones C/D/E) **o** como **componente/endpoint de
dominio** (A/B) — ver ADR 045.

| Sección | Ficha | Estado |
|---|---|---|
| A - Registro | [`A_registro.md`](./A_registro.md) — componente de dominio | ✅ (ADR 045) |
| B - Antecedentes heredofamiliares | componente propio ([ADR 043](../../../decisions/043-ahf-componente-dedicado.md)) | ⏳ modelado pendiente |
| C - APNP | [`C_apnp.md`](./C_apnp.md) | ✅ |
| D - Antecedentes personales patológicos | — | ⏳ pendiente |
| E - Padecimiento actual | [`E_padecimiento_actual.md`](./E_padecimiento_actual.md) | ✅ |

Fuente de los flujos: `docs/diagrams/0_HISTORIA_CLINICA/flows/`.

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
