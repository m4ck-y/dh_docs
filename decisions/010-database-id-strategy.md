# ADR 010: Estrategia de Identificadores en Base de Datos

## Estado
Aceptado

## Contexto

Los identificadores de registros en base de datos tienen dos audiencias distintas con necesidades distintas:

- **Interna (base de datos)**: necesita índices rápidos, JOINs eficientes, menor uso de almacenamiento.
- **Externa (API, frontend, móvil)**: necesita identificadores seguros que no revelen información sobre el volumen de datos ni permitan predecir otros IDs.

Usar un UUID como PK resuelve el problema externo pero degrada el rendimiento de índices en comparación con un entero. Usar un Integer autoincremental como PK resuelve el rendimiento interno pero expone IDs secuenciales al cliente (enumeración trivial, data leaking).

## Decisión

Todos los modelos no-intermediarios heredan de `BaseModel` que define **dos identificadores**:

| Columna | Tipo | Visibilidad | Propósito |
|---|---|---|---|
| `id` | `Integer` PK, autoincrement | **Interno** — nunca expuesto en APIs | JOINs, FKs, índices eficientes |
| `uuid` | `UUID`, auto-generado (`uuid4`) | **Externo** — usado en todas las respuestas y rutas de API | Lookups seguros, sin enumeración |

### Reglas de uso

1. **Los FKs entre tablas usan `id` (Integer)** — mantiene la eficiencia de las relaciones.
2. **Las respuestas de API exponen `uuid`** — nunca el `id` entero.
3. **Las rutas de API usan `uuid_<entity>`** — e.g. `GET /v1/people/persons/{uuid_person}`, nunca `GET /v1/people/persons/{id}` ni `GET /v1/people/persons/{person_uuid}`.
4. **Los use cases resuelven UUID → Integer** antes de operar sobre tablas relacionadas:
   ```python
   id_person: int = await session.scalar(
       select(Person.id).where(Person.uuid == uuid_person)
   )
   ```
5. **La variable resuelta usa prefijo `id_`** porque ya es integer: `id_person`, `id_tenant`, `id_document`.
6. **El parametro de entrada mantiene prefijo `uuid_`** porque aun es UUID: `uuid_person`, `uuid_tenant`.

## Consecuencias

- **Positivas**:
    - Índices de FK sobre Integer — rendimiento óptimo en JOINs.
    - UUIDs externos no revelan conteo ni secuencia de registros.
    - Distribución segura de IDs a clientes sin riesgo de enumeración.
- **Negativas**:
    - Cada use case que recibe un UUID del cliente necesita un paso adicional de resolución UUID → Integer antes de operar con FKs.
    - Ligero overhead de almacenamiento (Integer + UUID por registro).

## Convención de Naming

La regla raiz es: **`uuid_` como prefijo para todo UUID. `id_` como prefijo para todo integer (PK, FK, variables internas). Solo existen estos dos prefijos.**

### Contexto Externo (API, DTOs, parametros publicos)

| Contexto | Convencion | Ejemplo |
|---|---|---|
| Parametro de ruta en endpoint | `uuid_<entity>` | `uuid_person`, `uuid_document` |
| Parametro de query string | `uuid_<entity>` | `uuid_person`, `uuid_tenant` |
| Campo en DTO de request (body) — UUID propio | `uuid` | `uuid` |
| Campo en DTO de request (body) — referencia a otra entidad | `uuid_<entity>` | `uuid_person`, `uuid_document_subtype` |
| Campo en DTO de respuesta — UUID propio de la entidad | `uuid` | `uuid` |
| Campo en DTO de respuesta — referencia a otra entidad | `uuid_<entity>` | `uuid_person`, `uuid_tenant` |
| Campo en DTO de respuesta — lista de UUIDs referenciados | `uuid_<entity>s` | `uuid_roles`, `uuid_permissions` |

### Contexto Interno (variables, parametros de funcion, DB)

| Contexto | Convencion | Ejemplo |
|---|---|---|
| Columna PK en modelo SQLAlchemy (integer) | `id` | `id` |
| Columna FK en modelo SQLAlchemy (integer) | `id_<entity>` | `id_person`, `id_document` |
| Columna UUID en modelo SQLAlchemy (BaseModel) | `uuid` | `uuid` |
| Parametro de funcion que recibe UUID desde capa externa | `uuid_<entity>: str \| UUID` | `uuid_person`, `uuid_tenant` |
| Parametro de funcion que recibe integer ya resuelto | `id_<entity>: int` | `id_person`, `id_tenant` |
| Variable local que almacena un UUID sin resolver | `uuid_<entity>: UUID` | `uuid_person`, `uuid_tenant` |
| Variable local que almacena un integer ya resuelto | `id_<entity>: int` | `id_person`, `id_tenant` |

### Reglas Estrictas

1. **`uuid_` como prefijo** para todo UUID: rutas HTTP, query params, DTOs request/response, parametros de funcion, variables locales.
2. **`id_` como prefijo** para todo integer: columnas FK en SQLAlchemy, parametros de funcion, variables locales que almacenan un ID resuelto.
3. El campo UUID propio de una entidad en respuestas siempre se llama `uuid` (sin entidad), porque el contexto ya indica a que entidad pertenece.
4. La PK autoincremental en modelos SQLAlchemy siempre se llama `id` (sin entidad), definida en BaseModel.
5. **Nunca** usar sufijos `_id`, `_uuid`, `_ids`, `_uuids`. Todo se resuelve por prefijo.

### Prohibiciones Explicitas

| Contexto | Prohibido | Ejemplo incorrecto | Correcto |
|---|---|---|---|
| Ruta HTTP | `{entity}_uuid` | `GET /persons/{person_uuid}` | `GET /persons/{uuid_person}` |
| Ruta HTTP | `{entity}_id` | `GET /persons/{person_id}` | `GET /persons/{uuid_person}` |
| DTO request (referencia) | `entity_uuid` | `person_uuid: UUID` | `uuid_person: UUID` |
| DTO request (referencia) | `entity_id` | `person_id: UUID` | `uuid_person: UUID` |
| DTO request (referencia) | `id_entity` con UUID | `id_person: UUID` | `uuid_person: UUID` |
| DTO response (referencia) | `entity_uuid` | `person_uuid: str` | `uuid_person: str` |
| DTO response (referencia) | `entity_id` | `person_id: str` | `uuid_person: str` |
| DTO response (referencia) | `id_entity` con UUID | `id_document: str` | `uuid_document: str` |
| DTO response | exponer integer PK | `id_person: int = 42` | No incluir el campo |
| Parametro de funcion (UUID) | `entity_uuid` | `def f(person_uuid: str)` | `def f(uuid_person: str)` |
| Parametro de funcion (UUID) | `entity_id` | `def f(person_id: str)` | `def f(uuid_person: str)` |
| Parametro de funcion (integer) | `entity_id` | `def f(person_id: int)` | `def f(id_person: int)` |
| Parametro de funcion (integer) | `id_entity` con UUID | `def f(id_person: UUID)` | `def f(uuid_person: UUID)` |
| Variable local (UUID) | `entity_uuid` | `person_uuid = dto.uuid` | `uuid_person = dto.uuid` |
| Variable local (integer resuelto) | `entity_id` | `person_id: int = 42` | `id_person: int = 42` |
| MongoDB / NoSQL (UUID) | `entity_id` | `person_id = "abc-123"` | `uuid_person = "abc-123"` |
| MongoDB / NoSQL (UUID lista) | `entity_ids` | `role_ids = [...]` | `uuid_roles = [...]` |

### Principio Nemotecnico

- **`uuid_`** = "es un UUID" (identificador publico, seguro, expuesto en API)
- **`id_`** = "es un integer ID" (identificador interno, PK/FK de base de datos)
- Solo dos prefijos. Sin sufijos. Sin excepciones.

## Convención en ERDs

Los ERDs de `docs/db/postgres/` muestran `Integer id PK` + `UUID uuid` en cada entidad. Los FKs se tipifican como `Integer id_<entidad> FK`. Los campos de BaseModel (`created_at`, `updated_at`, `deleted_at`, campos de auditoría) NO se repiten en los diagramas de entidades hija — solo se documenta en el comentario de cabecera de cada ERD.

## Implementación

Ver `app/shared/database/postgres.py` — clase `BaseModel`.
Ver `.agents/rules/PYTHON_INFRA_DB_BASE_MODEL.md`.
