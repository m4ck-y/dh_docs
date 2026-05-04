# ADR 026: Resolucion Local del `id` Interno Post-Respuesta de Microservicio

## Estado
Aceptado

## Contexto

Todos los microservicios usan `BaseModelMixin` (ADR 010) que define dos identificadores: `id` (Integer PK, interno) y `uuid` (UUID v4, publico). La regla establece que `id` nunca se expone en API.

Sin embargo, cuando un microservicio A llama a un microservicio B para crear un recurso, A frecuentemente necesita el `id` (Integer) del nuevo registro para insertar registros relacionados via FK (ej. `AuthUser.id_person`).

Historicamente, `dh_core` retornaba tanto `id` como `uuid` en su respuesta de creacion, y `dh_onboarding_back` accedia `response["data"]["id"]` para obtener el integer PK. Esto viola el ADR 010 y el ADR 024.

## Decision

**Todo microservicio devuelve exclusivamente `uuid` en sus respuestas API. El `id` (Integer PK) nunca se serializa.**

Si un microservicio llamador necesita el `id` para inserts relacionados via FK, debe **resolverlo localmente** consultando el modelo compartido (`dh_shared`) en la misma base de datos:

```python
# Servicio A (creacion via API)
response = await http_client.create_resource(payload)
uuid_resource = response["data"]["uuid"]

# Resolucion local del id (sin pasar por API)
async with AsyncSessionLocal() as session:
    result = await session.execute(
        select(SharedModel.id).where(SharedModel.uuid == UUID(uuid_resource))
    )
    id_resource = result.scalar_one()
```

### Reglas

1. **Respuestas API**: Solo `uuid`. Nunca `id` (integer), ni siquiera en respuestas inter-service.
2. **Resolucion local**: El servicio llamador resuelve `uuid -> id` consultando el modelo de `dh_shared` directamente en su propia sesion de base de datos.
3. **Misma transaccion**: La resolucion del `id` y la insercion del registro dependiente deben ocurrir en la misma sesion/transaccion cuando sea posible.
4. **Sin endpoint de resolucion**: No se crean endpoints como `GET /resources/{uuid}/internal-id` — eso reintroduce la exposicion del `id` en API.

### Patron de implementacion

```python
# dh_shared/queries/__init__.py
async def resolve_uuid_to_id(session, model, uuid_val):
    result = await session.execute(
        select(model.id).where(model.uuid == uuid_val)
    )
    return result.scalar_one()
```

### Aplicacion concreta

En `dh_onboarding_back`, tras `core.create_person()`:

```python
response = await core.create_person(payload)
uuid_person = response["data"]["uuid"]

# Resolver id_person localmente (nunca via API)
async with AsyncSessionLocal() as session:
    from dh_shared.models.people.person import Person
    result = await session.execute(
        select(Person.id).where(Person.uuid == UUID(uuid_person))
    )
    id_person = result.scalar_one()

    session.add(AuthUser(id_person=id_person, username=dto.email, is_active=True))
    await session.commit()
```

## Consecuencias

- **Positivas**:
    - `id` integer nunca se expone en ninguna API, ni publica ni inter-service.
    - El frontend solo ve UUIDs, consistente con ADR 024.
    - La resolucion local es mas rapida que una llamada HTTP adicional.
    - El patron es reutilizable en cualquier microservicio.
- **Negativas**:
    - Cada insercion dependiente requiere una query adicional de resolucion `uuid -> id`.
    - El servicio llamador necesita acceso a los modelos de `dh_shared` y a la base de datos compartida.

## Referencias

- [ADR 010: Estrategia de IDs en Base de Datos](./010-database-id-strategy.md)
- [ADR 024: Endpoints API con UUIDs](./024-endpoints-uuid-only.md)
