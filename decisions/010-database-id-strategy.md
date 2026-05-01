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
3. **Las rutas de API usan `uuid`** — e.g. `GET /persons/{uuid}`, nunca `GET /persons/{id}`.
4. **Los use cases resuelven UUID → Integer** antes de operar sobre tablas relacionadas:
   ```python
   int_id = await session.scalar(select(Person.id).where(Person.uuid == uuid.UUID(external_id)))
   ```

## Consecuencias

- **Positivas**:
    - Índices de FK sobre Integer — rendimiento óptimo en JOINs.
    - UUIDs externos no revelan conteo ni secuencia de registros.
    - Distribución segura de IDs a clientes sin riesgo de enumeración.
- **Negativas**:
    - Cada use case que recibe un UUID del cliente necesita un paso adicional de resolución UUID → Integer antes de operar con FKs.
    - Ligero overhead de almacenamiento (Integer + UUID por registro).

## Convención de Naming

| Contexto | Prefijo | Ejemplo |
|---|---|---|
| Columna FK en DB (integer) | `id_` | `id_person`, `id_document` |
| Columna UUID en DB (externo) | `uuid` (campo de BaseModel) | `uuid` |
| Parámetro de ruta / query en API | `uuid_` | `uuid_person`, `uuid_document` |
| Campo en DTO de respuesta (UUID) | `uuid_` | `uuid_person` |
| Variable interna resuelta a integer | sin prefijo o `_id` sufijo | `person_id`, `int_id` |

**Nunca** usar `id_` como prefijo en parámetros HTTP — indica siempre un UUID externo.

## Convención en ERDs

Los ERDs de `docs/db/postgres/` muestran `Integer id PK` + `UUID uuid` en cada entidad. Los FKs se tipifican como `Integer id_<entidad> FK`. Los campos de BaseModel (`created_at`, `updated_at`, `deleted_at`, campos de auditoría) NO se repiten en los diagramas de entidades hija — solo se documenta en el comentario de cabecera de cada ERD.

## Implementación

Ver `app/shared/database/postgres.py` — clase `BaseModel`.
Ver `.agents/rules/PYTHON_INFRA_DB_BASE_MODEL.md`.
