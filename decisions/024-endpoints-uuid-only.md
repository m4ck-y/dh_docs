---
type: decision
id: 024
title: Endpoints API con UUIDs — Prohibición de IDs autoincrementales en la interfaz pública
status: accepted
date: 2026-05-02
category: security
layer: presentation
keywords: [uuid, id, security, api, endpoints]
language: es
---

# ADR 024: Endpoints API con UUIDs — Prohibición de IDs autoincrementales en la interfaz pública

## Contexto

Todos los modelos del sistema heredan de `BaseModelMixin` (ADR 010), que define dos identificadores:

- `id`: entero autoincremental (`INTEGER PK`), usado exclusivamente para **joins entre tablas en la base de datos**.
- `uuid`: identificador único universal (`UUID v4`), usado como **identificador público** expuesto en APIs.

En fases tempranas del desarrollo, algunos endpoints aceptaban `id` (entero) como parámetro de ruta, query o body. Esto introduce problemas de seguridad y mantenimiento:

1. **Enumeración de recursos**: Los IDs autoincrementales (1, 2, 3...) permiten a un atacante adivinar fácilmente otros identificadores y acceder/modificar recursos ajenos con peticiones manuales.
2. **Acoplamiento interno**: Exponer `id` obliga a los clientes (frontend mobile/web) a conocer detalles de implementación de la base de datos.
3. **Integración cross-service**: Cuando un microservicio (ej. `dh_onboarding_back`) necesita referirse a un recurso de otro servicio (ej. una `person`), debe usar el `uuid`, no el `id` interno, porque el `id` solo es significativo dentro de la base de datos del servicio propietario.

## Decisión

**Todo endpoint público** en cualquier microservicio del ecosistema Digital Hospital **debe usar exclusivamente UUIDs** para identificar recursos provenientes del exterior.

### Reglas

1. **Parámetros de ruta**: Usar `{resource_uuid}` no `{resource_id}`.
2. **Parámetros query**: Usar `resource_uuid` no `resource_id`.
3. **Campos en body de solicitudes (DTOs)**: Usar `resource_uuid` no `resource_id`. Ejemplo: `tenant_uuid`, `person_uuid`, `permission_uuids`, `role_uuids`.
4. **Respuestas**: Los DTOs de respuesta incluyen `uuid` (no `id`) como identificador principal del recurso.
5. **IDs internos**: El campo `id` (autoincremental) **nunca se expone en la API**. Solo se usa internamente para:
   - Joins entre tablas en consultas SQLAlchemy.
   - Claves foráneas en el modelo de datos.
   - Operaciones internas dentro de un mismo microservicio.

### Nomenclatura

Todos los campos que referencien un UUID desde el exterior siguen el patrón:

```
{entidad}_uuid
```

Ejemplos:

| Contexto | Campo correcto | Campo incorrecto |
|----------|----------------|------------------|
| Crear permiso | `resource_uuid`, `operation_uuid` | `id_resource`, `id_operation` |
| Crear rol | `tenant_uuid`, `permission_uuids` | `id_tenant`, `permission_ids` |
| Crear membresía | `person_uuid`, `tenant_uuid`, `role_uuids` | `id_person`, `id_tenant`, `role_ids` |
| Listar roles por tenant | `?tenant_uuid=...` | `?tenant_id=...` |
| Listar membresías | `?person_uuid=...` | `?person_id=...` |

### Implementación

Los use cases resuelven el UUID a ID interno inmediatamente después de recibir la solicitud:

```python
# Ejemplo en permission_use_case.py
async def create(self, dto: PermissionCreateDTO) -> PermissionResponseDTO:
    resource = await self.db.execute(
        select(Resource).where(Resource.uuid == dto.resource_uuid)
    )
    resource = resource.scalar_one_or_none()
    if not resource:
        raise HTTPException(status_code=404, detail="Resource not found.")
    # ... usar resource.id internamente
```

### Excepciones

No hay excepciones. Todos los endpoints públicos deben seguir esta regla.

## Consecuencias

### Positivas

- **Seguridad**: Los UUIDs no son secuenciales ni adivinables, eliminando el riesgo de enumeración de recursos.
- **Desacoplamiento**: Los clientes no dependen de detalles de la base de datos.
- **Portabilidad**: Un `uuid` puede migrarse entre entornos sin conflictos, a diferencia de un `id` autoincremental.
- **Consistencia**: Unificación del estándar para todos los microservicios.

### Negativas

- **Mayor costo de resolución**: Cada solicitud que recibe un UUID debe hacer una consulta adicional para resolverlo al ID interno. Esto es aceptable por las ganancias en seguridad y desacoplamiento.

## Referencias

- [ADR 010: Estrategia de IDs en Base de Datos](./010-database-id-strategy.md) — Define `BaseModelMixin` con `id` + `uuid`.
- [ADR 017: Referencias Cross-Service sin FK](./017-referencias-cross-service.md) — Define que las FK entre servicios son lógicas, no de base de datos.
- Código de referencia: `dh_iam/app/contexts/iam/application/use_cases/permission_use_case.py`, `role_use_case.py`, `membership_use_case.py`.