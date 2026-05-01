# ADR 017: Identificadores en APIs y Referencias Cross-Service

## Estado
Aceptado

## Contexto

El ADR 010 define `id` Integer para FKs y `uuid` para APIs externas. Con microservicios sobre la misma instancia PostgreSQL, es necesario definir qué identificadores se exponen según el consumidor y cómo se resuelven los FKs cross-service.

## Decisión

### Regla 1: Qué devolver según el consumidor

| Consumidor | `id` | `uuid` |
|---|---|---|
| Clientes externos via `api_middleware` (frontend, mobile) | ❌ Nunca | ✅ Siempre |
| Llamadas inter-servicio (backend ↔ backend) | ✅ Sí | ✅ Sí |

El `api_middleware` es responsable de filtrar el `id` de las respuestas antes de reenviarlas al exterior. Los microservicios entre sí sí se pasan el `id` para poder usarlo en FKs sin consultas adicionales.

### Regla 2: FK siempre Integer con constraint real en DB

Los FKs entre tablas — incluso cross-service — usan `id` Integer con `ForeignKey()` real. El constraint es válido porque todos los servicios comparten la misma instancia PostgreSQL.

```python
# ✅ FK integer real incluso apuntando a tabla de otro servicio
class AuthUser(BaseModel):
    id_person: MappedColumn[int] = mapped_column(
        Integer, ForeignKey("people.person.id"), nullable=False
    )
```

### Regla 3: Resolución uuid → id via llamada inter-servicio

Cuando un servicio necesita el `id` de una entidad de otro servicio, llama al endpoint del servicio dueño pasando el `uuid` y recibe `id` + `uuid` en la respuesta.

```python
# dh_onboarding_back resuelve id_person para crear auth.user
response = await core.get_person(person_uuid)  # GET /v1/people/persons/{uuid}
person_id = response["data"]["id"]
session.add(AuthUser(id_person=person_id, ...))
```

### Regla 4: Orden de arranque

El servicio dueño del schema referenciado debe arrancar primero.

```
1. dh_core              → crea people.*
2. dh_onboarding_back   → crea auth.*, expedient.* (FK a people.person.id)
```

## Tabla de referencia

| Escenario | Columna | `ForeignKey()` | Cómo obtener el `id` |
|---|---|---|---|
| Mismo servicio | `id_<entidad> INTEGER` | ✅ Sí | Flush + `obj.id` |
| Cross-service | `id_<entidad> INTEGER` | ✅ Sí | Llamada HTTP al servicio dueño |
| Respuesta a clientes externos | `uuid` solamente | — | `api_middleware` filtra el `id` |

## Dependencia circular resuelta por orden de create_all

Cuando existe una referencia circular entre schemas (ej. `people.personal_identifier.id_document → expedient.document.id` y `expedient.document.id_person → people.person.id`), la solución es controlar el orden de `create_all` en el lifespan del servicio dueño.

```python
# dh_core crea expedient primero, luego people
await conn.run_sync(ExpedientBase.metadata.create_all)  # crea expedient.document
await conn.run_sync(PeopleBase.metadata.create_all)     # crea people.personal_identifier (FK a expedient.document.id)
```

Esto es posible porque `dh_shared` expone ambos `Base` en el mismo paquete. Ambos FKs tienen constraint real en DB.

## Referencias
- [ADR 010: Estrategia de Identificadores en Base de Datos](010-database-id-strategy.md)
- [Matriz de Acceso a Datos](../db/service_database_access_matrix.md)
