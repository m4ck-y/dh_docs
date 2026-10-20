# Legal (feature)

Textos legales **versionados** (términos y condiciones, aviso de privacidad) y las
**aceptaciones** que los referencian. El contenido **no** vive en la base: el texto
es un **archivo** (`.md`/`.html`) con ruta versionada en object storage, y la base
guarda la **evidencia** (`version` + `hash`).

**Estado:** 🟡 propuesta ([ADR 050](../../decisions/050-contenido-legal-en-mongodb.md))
— el servicio `dh_legal` (puerto 8093) está 🔴 sin implementar.

**Usado por:** el registro/onboarding (aceptación de términos y aviso) y, más
adelante, telemedicina (consentimiento, NOM-024), consentimiento informado y
derechos ARCO.

## Modelo

| Colección | Clase | Qué guarda |
|---|---|---|
| `legal_documents` | `LegalDocument` | `key` · `version` · `url` interno · `mime_type` · `hash` · `size_bytes` · `status` · vigencia |
| `legal_acceptances` | `LegalAcceptance` | `uuid_person` · `key` · `version` · `hash` · `accepted_at` · `method` · `source` |

Diagrama de clases y ejemplos: [`db/mongo/dh_legal/`](../../db/mongo/dh_legal/).

- `key` — qué documento es (`TERMS` | `PRIVACY`; enum cerrado, sin “Otro” → ADR 044).
- `version` — `YYYY-MM`; el archivo es inmutable y una corrección es **versión nueva**.
- La **versión vigente** es la `PUBLISHED` con mayor `effective_from`.

## Contrato de API

Rutas canónicas del repo ([mapeo de endpoints](../../architecture/service-endpoint-mapping.md)):
vía gateway `/api/middleware/legal/v1/…` · directo `/api/legal/v1/…`.

| Endpoint (vía gateway) | Devuelve |
|---|---|
| `GET /api/middleware/legal/v1/documents/{key}` | la versión **vigente** (metadatos + `content`) |
| `GET /api/middleware/legal/v1/documents/{key}/{version}` | una versión concreta (metadatos + `content`) |
| `GET /api/middleware/legal/v1/documents/{key}/{version}/file` | los **bytes** del archivo |
| `POST /api/middleware/legal/v1/acceptances` | registra la aceptación |
| `GET /api/middleware/legal/v1/acceptances/{uuid_person}` | historial del titular (perfil + ARCO) |

Ejemplo:

```
https://<host>/api/middleware/legal/v1/documents/TERMS/2026-10
```

`content` es el archivo ya leído por el servicio (`mime_type` dice cómo
renderizarlo: markdown o HTML sanitizado). El `{version}/file` responde:

```
Content-Type: text/markdown; charset=utf-8     ← o text/html
ETag: "sha256:9f2c…"                            ← el hash del documento
Cache-Control: public, max-age=31536000, immutable
Content-Length: 8123
```

Códigos: `200` · `404` (versión inexistente o `DRAFT`) · `409` (el `hash` que vio
el cliente ya no es el de la versión).

## Flujo de aceptación

1. El front pide `GET /documents/{key}` y renderiza `content`.
2. El usuario acepta.
3. `POST /acceptances` con `{ key, version }`.
4. El servidor **estampa el `hash`** de esa versión publicada (nunca confía en el
   hash que mande el cliente) y guarda el evento.
5. Si el cliente manda además el `hash` que vio y no coincide → `409` (la versión
   cambió a mitad de camino).

La aceptación requiere `uuid_person`: ocurre **después** de crear la persona (lo
orquesta el onboarding, no el formulario).

## Reglas de evidencia

- Las versiones **`RETIRED` se siguen sirviendo** (una aceptación vieja debe poder
  leerse como evidencia); solo `DRAFT` da `404`.
- El bucket es **privado** y el `url` es **interno**: **nunca** se devuelve al cliente.
- El servicio **verifica el `hash`** de los bytes que sirve (si el objeto fue
  alterado, no sirve contenido inconsistente).
- La lectura es **pública** (los términos se leen antes de tener sesión).
- Si el storage no responde, el flujo **falla cerrado**: no se acepta un texto que
  no se puede leer.
- El retiro de un consentimiento es **fila nueva** (`revoked_at`), nunca un update.
- `legal_acceptances` es un evento → candidato a **ETL a ClickHouse**.

## Autoría y publicación

- La fuente de verdad es el **archivo en git**: publicar una versión es un **PR**
  (revisión legal con diff).
- El **publish/sync** sube el archivo a storage (ruta versionada), calcula el
  `hash` de los bytes publicados y hace **upsert** del documento
  (`status: PUBLISHED`). Mismo patrón que el `seed/` de
  [catálogos](../catalogs/).
- Nunca se sobrescribe una ruta publicada: una corrección es versión nueva.

## Pendientes

| # | Punto | Estado |
|---|---|---|
| 1 | Servicio `dh_legal` (puerto 8093 · TASK) | 🔴 |
| 2 | `publish/sync` (git → storage → MongoDB) | 🔴 |
| 3 | Decidir si el archivo vive en el repo del servicio o en este repo | 🔴 |
| 4 | Adelante: consentimiento de telemedicina, consentimiento informado y derechos ARCO | 🔴 |

## Referencias

- [ADR 050 — Contenido legal y aceptaciones en MongoDB](../../decisions/050-contenido-legal-en-mongodb.md)
- [Base `dh_legal`](../../db/mongo/dh_legal/) · [MongoDB](../../db/mongo/README.md)
- [ADR 017 — Referencias cross-service](../../decisions/017-referencias-cross-service.md) · [ADR 049 — `id` vs `key`](../../decisions/049-referencia-catalogos-id-vs-key.md)
- [ADR 044 — Catálogos con gobernanza](../../decisions/044-catalogos-gobernados.md)
