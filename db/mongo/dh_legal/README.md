# dh_legal

Base documental del servicio `dh_legal` (propuesto): **textos legales versionados**
y las **aceptaciones** que los referencian. El contenido **no** vive acá: el archivo
(`.md`/`.html`) va a object storage y esta base guarda la **evidencia**
(`version` + `hash`).

| Colección | Clase | Qué guarda |
|---|---|---|
| `legal_documents` | `LegalDocument` | la evidencia del texto: `url` del archivo + `mime_type` + `hash` + `size_bytes` + vigencia |
| `legal_acceptances` | `LegalAcceptance` | la aceptación: `uuid_person` + `key` + `version` + `hash` + `accepted_at` |

- Diagrama: [CLASS.mmd](./CLASS.mmd) — 2 colecciones + 3 enums.
- Ejemplos: [legal_documents.jsonc](./legal_documents.jsonc) · [legal_acceptances.jsonc](./legal_acceptances.jsonc)
- Contrato HTTP y flujo de aceptación: [`features/legal/README.md`](../../../features/legal/README.md) — sin repetirlo acá
- Decisión: [ADR 050](../../../decisions/050-contenido-legal-en-mongodb.md).

## Pendientes

| # | Punto | Estado |
|---|---|---|
| 1 | Servicio `dh_legal`: puerto 8093 · `/api/middleware/legal` · TASK | 🔴 |
| 2 | Publish/sync: archivo en git → storage + upsert del doc (patrón `seed/` de catálogos) | 🔴 |
| 3 | Dónde vive el archivo: repo del servicio `dh_legal` o este repo `docs/` | 🔴 |
| 4 | `ENUM` de formato: se reusa la convención de `storage` (`mime_type`, sin enum) | 🟢 |
