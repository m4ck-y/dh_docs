# ADR 050: Contenido legal y aceptaciones en MongoDB (`dh_legal`)

## Estado
Aceptado (2026-10-18)

## Contexto

El registro necesita **persistir la aceptación de los textos legales** (términos y
condiciones, aviso de privacidad) que ya usa el frontend (`aceptaTerminos`). El
material de referencia guardaba el **texto dentro del registro** y la aceptación
como un booleano: eso impide saber *qué* texto se aceptó y no deja evidencia.

Reglas ya decididas que condicionan el diseño:

- Referencias cross-servicio con **`uuid_*` sin FK** ([ADR 017](017-referencias-cross-service.md));
  `id_*` solo dentro de la misma base, `key_*` cuando cruza motor ([ADR 049](049-referencia-catalogos-id-vs-key.md)).
- Reparto por motor ([ADR 003](003-estrategia-multi-base-de-datos.md)) y
  **UTC** en todos los timestamps ([ADR 008](008-datetime-utc-standard.md)).
- Un vocabulario **con “Otro”** es catálogo; **sin “Otro”**, enum de texto con la
  lista estática en la app ([ADR 044](044-catalogos-gobernados.md)).
- Los **binarios** (un PDF firmado) no van en la base: van a object storage y se
  referencian por URL.

`dh_storage` queda descartado como casa: su alcance definido en el
[mapa de arquitectura](../ARCHITECTURE_OVERVIEW.md) es *“gestión de archivos
físicos: fotos, documentos, expedientes”* — el cumplimiento legal es otro dominio
(consentimientos, aviso versionado, derechos ARCO) y crece por obligación
normativa, no por producto.

## Decisión

1. **Servicio propio**: el dominio legal vive en **`dh_legal`** (base Mongo
   `dh_legal`, puerto **8093**, gateway `/api/middleware/legal`), no dentro de
   `dh_storage`.
2. **El contenido no va en la base**: el texto es un **archivo** (`.md`/`.html`)
   con **ruta versionada** (`legal/<key>/<version>.md`) en object storage. El
   bucket es **privado** y la ruta publicada **nunca se sobrescribe**.
3. **`legal_documents`** guarda la **evidencia**: `key`, `version` (`YYYY-MM`),
   `url` (interno), `mime_type`, `hash` (sha256 de los **bytes publicados**),
   `size_bytes`, `status` (`DRAFT | PUBLISHED | RETIRED`), `effective_from`,
   `retired_at`, `created_by`. Índice único `(key, version)`; la **versión
   vigente** es la `PUBLISHED` con mayor `effective_from`.
4. **`legal_acceptances`** es un **evento append-only**: `uuid_person` (sin FK),
   `key`, `version`, `hash`, `accepted_at`, `method` (`CHECKBOX | SIGNATURE |
   IMPLICIT`), `source`, `ip`, `user_agent`, `revoked_at`. El **retiro** del
   consentimiento es una **fila nueva**, nunca un update. El vínculo con el texto
   es **lógico** (`version` + `hash`), no una FK.
5. **La API es la única puerta**: el cliente recibe `key` + `version` y el
   **contenido** servido por `dh_legal`; **nunca** la `url` del archivo. El
   servidor **estampa el `hash`** de la versión aceptada (no confía en el cliente)
   y sirve las versiones `RETIRED`; las `DRAFT` dan `404`.
6. **Autoría con revisión**: la fuente de verdad es el **archivo en git** (publicar
   = PR con diff) y un **publish/sync** lo sube a storage, calcula el `hash` de los
   bytes y hace upsert del documento — el mismo patrón que el `seed/` de catálogos (ADR 044).
7. **Analítica**: `legal_acceptances` es un evento → candidato a **ETL hacia
   ClickHouse**; el DW no necesita el texto.

## Consecuencias

- **Se gana**: trazabilidad real (*quién aceptó qué versión, con qué hash y desde
  dónde*); el texto es un artefacto revisable, inmutable y **fuera** de la base;
  el front no conoce storage (una sola puerta, sin URLs públicas ni CORS extra);
  Mongo queda liviano y el DW no carga el texto.
- **Se paga**: un servicio nuevo (repo, CI, puerto, registros) ✗; dos sistemas en
  el camino crítico (storage + Mongo) ⇒ el endpoint debe **cachear** (las versiones
  son inmutables) y **fallar cerrado** si el storage no responde; y el `hash` debe
  calcularse sobre los **bytes publicados** (si el sync transforma el archivo, el
  hash del repo no sirve).
- `mime_type` reusa la convención del dominio `storage`
  ([`db/postgres/storage/erd.mmd`](../db/postgres/storage/erd.mmd)) en lugar de un
  enum propio de formato.
- Habilita lo que viene encima del mismo mecanismo: consentimiento de telemedicina
  (NOM-024), consentimiento informado y derechos ARCO (acceso, rectificación,
  cancelación, oposición).

## Pendientes

- El servicio `dh_legal` (TASK) y su registro en el mapa de arquitectura, puertos,
  endpoints y matriz de acceso.
- El `publish/sync` y **dónde vive el archivo en git** (repo del servicio o `docs/`).
- Los textos que se publiquen (`TERMS`, `PRIVACY`) y sus fechas de vigencia.

## Referencias

- [ADR 017 — Referencias Cross-Service](017-referencias-cross-service.md)
- [ADR 044 — Catálogos con gobernanza](044-catalogos-gobernados.md)
- [ADR 049 — `id` en la misma BD, `key` cuando cruza motor](049-referencia-catalogos-id-vs-key.md)
- [Feature legal](../features/legal/README.md) · [Base `dh_legal`](../db/mongo/dh_legal/)
- [Estrategia Multi-Base de Datos](003-estrategia-multi-base-de-datos.md) · [Estándar UTC](008-datetime-utc-standard.md)
