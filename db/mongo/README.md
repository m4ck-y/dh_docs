# mongo

Bases de datos y **colecciones** documentales de MongoDB (esquema flexible;
las colecciones de eventos son append-only). Ver
[ADR 003](../../decisions/003-estrategia-multi-base-de-datos.md) (reparto por
motor) y la [matriz de acceso](../service_database_access_matrix.md).

> **Estado:** 🟡 parcial — convención definida; el **contenido legal**
> (`dh_legal/`) está en propuesta y faltan diagramas de otras bases.

## Convención

| Pieza | Forma | Ejemplo |
|---|---|---|
| **Base de datos** | `dh_<servicio>` — **es la carpeta** | `dh_legal/` |
| **Colección** | plural, `snake_case` | `legal_documents` · `legal_acceptances` |
| **Clase** (en el diagrama) | la entidad en `PascalCase`; sus campos son el *shape* del documento | `LegalDocument` |
| **Enumeración** | `E` + `PascalCase` | `ELegalDocKey` |
| **Diagrama** | `CLASS.mmd`, uno por base | `dh_legal/CLASS.mmd` |
| **Ejemplo de registro** | `<colección>.jsonc`, uno por colección | `waitlist.jsonc` |

- **Carpeta = base**: el nombre de la carpeta es el nombre de la base en el
  servidor (`dh_mfa`, `dh_onboarding`, `dh_legal`…). No se crean carpetas por
  colección.
- **Un `CLASS.mmd` por base**: un solo `classDiagram` con todas sus colecciones;
  los enums compartidos viven en el mismo archivo. Misma convención que
  `CLASS.mmd` en las features y que `click_house/catalogs/erd.mmd`.
- **Una clase por colección**: la clase *es* la colección (1:1) y sus atributos
  son el *shape* del documento (el "esquema"); el nombre de la colección va en el
  comentario de la clase. Los **enums no son colecciones**: son los valores
  permitidos de un campo.
- **Un ejemplo por colección**: `<colección>.jsonc` — un registro de ejemplo con
  comentarios `//` y **valores ficticios** (nunca PII ni secretos reales). Anota
  qué es obligatorio, los valores del enum, quién escribe cada campo y lo que
  sigue pendiente. Misma convención `.jsonc` que las features: la extensión es
  porque el archivo lleva comentarios.
- **Referencias hacia PostgreSQL**: `uuid_*` (identificador externo, **sin FK** —
  [ADR 017](../../decisions/017-referencias-cross-service.md) ·
  [ADR 049](../../decisions/049-referencia-catalogos-id-vs-key.md)); hacia
  catálogos: `key_*`.
- Timestamps en **UTC** ([ADR 008](../../decisions/008-datetime-utc-standard.md));
  gobernanza y sentinels de listas ([ADR 044](../../decisions/044-catalogos-gobernados.md)).

## Bases

| Base | Servicio dueño | Colecciones | Diagrama |
|---|---|---|---|
| `dh_catalogs` | `dh_catalogs` | `catalogs` (registro) · `items` (ítems Mongo, filtrados por `catalog`) | [`features/catalogs/CLASS.mmd`](../../features/catalogs/CLASS.mmd) |
| `dh_mfa` | `dh_mfa` | `otp_challenges` | [CLASS.mmd](./dh_mfa/CLASS.mmd) |
| `dh_onboarding` | `dh_onboarding` | `waitlist` | [CLASS.mmd](./dh_onboarding/CLASS.mmd) · [README.md](./dh_onboarding/README.md) |
| `dh_legal` | `dh_legal` (propuesto) | `legal_documents` · `legal_acceptances` | [CLASS.mmd](./dh_legal/CLASS.mmd) — **propuesta** |
| `dh_telemetry` | `dh_logger` | `events` · `logs` · `metrics` · `traces` | 🔴 pendiente |

Notas:

- Las bases sin prefijo `dh_` (p. ej. `bot_whatsapp`) pertenecen a otros
  proyectos y no se documentan aquí.
- `auth/` está vacía: por definir si se documenta una base de Mongo para auth
  (hoy `auth` es esquema de PostgreSQL).
- `dh_catalogs` documenta su vista documental dentro de la feature
  (`features/catalogs/`), **no se replica** en este árbol.

## Contenido legal (propuesta)

El **texto no vive en la base**: es un **archivo** (`.md`/`.html`) con ruta
versionada en **object storage** (bucket privado) y Mongo guarda la **evidencia**.
Contrato HTTP y flujo de aceptación: [`features/legal/README.md`](../../features/legal/README.md).

| Colección | Qué guarda | Vínculo con PostgreSQL |
|---|---|---|
| `legal_documents` | la evidencia del texto: `url` interno · `mime_type` · `hash` (sha256 de los bytes) · `size_bytes` · `status` · vigencia | — (es contenido, no entidad) |
| `legal_acceptances` | la **aceptación**: quién, qué versión, cuándo, desde dónde | `uuid_person` → `people.person.uuid` — **sin FK** |

Ejemplos: [`legal_documents.jsonc`](./dh_legal/legal_documents.jsonc) ·
[`legal_acceptances.jsonc`](./dh_legal/legal_acceptances.jsonc).

**Reglas** (detalle en [`dh_legal/CLASS.mmd`](./dh_legal/CLASS.mmd)):

- El archivo **y** el documento son inmutables: un cambio = versión nueva
  (`version` = `"YYYY-MM"`); el candado es el índice único `(key, version)` y la
  ruta publicada **nunca se sobrescribe**.
- El `url` es **interno**: nunca se devuelve al cliente (la API lee el archivo y
  sirve el contenido).
- El vínculo texto ↔ aceptación es **`version` + `hash`**, no una FK; el servidor
  **estampa el `hash`** de la versión aceptada.
- La **versión vigente** = la `published` con mayor `effective_from` (sin índice aparte).
- Las versiones **`retired` se siguen sirviendo** (una aceptación vieja debe poder
  leerse); las `draft` no existen para el cliente.
- El **retiro** del consentimiento es una fila nueva (`revoked_at`), nunca un update.
- Ni el **binario** (un PDF firmado, un snapshot) ni el texto van en Mongo: van a
  object storage y se referencian.
- **Analítica**: `legal_acceptances` es un evento → candidato a ETL hacia
  **ClickHouse** ([`../click_house/`](../click_house/)).

> Decisión: [**ADR 050**](../../decisions/050-contenido-legal-en-mongodb.md) (contenido legal y aceptaciones en MongoDB).
