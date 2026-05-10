# ADR 034: UUID de Entidad como Único Identificador en Rutas de PATCH/DELETE/GET-single

## Estado
Aceptado

## Contexto

Los sub-recursos de una persona (Address, Email, Phone, PersonalIdentifier, EmergencyContact) son colecciones — una persona puede tener N de cada uno. Las rutas iniciales de update y delete usaban solo `uuid_person`, lo que obligaba al use case a tomar el primer registro encontrado (`LIMIT 1`). Esto hace imposible operar sobre un registro específico cuando existen varios.

Adicionalmente, los catálogos relacionados de otros contextos (ej. expediente clínico, organizaciones) siguen el mismo patrón: la FK al recurso padre es solo un dato de la entidad, no un segmento de ruta necesario para modificarla o eliminarla.

## Decisión

### Regla general

> Para operaciones GET-single, PATCH y DELETE sobre cualquier recurso que tenga su propio UUID, **el path solo requiere el UUID de la entidad afectada**. El UUID del recurso padre es información del registro y no necesita repetirse en la URL.

### Estructura de rutas

**Operaciones de colección** — requieren UUID del recurso padre:

```
GET  /v1/people/{uuid_person}/addresses     listar direcciones de una persona
POST /v1/people/{uuid_person}/addresses     crear dirección para una persona
```

**Operaciones de entidad** — solo UUID de la entidad:

```
GET    /v1/people/addresses/{uuid_address}   obtener dirección
PATCH  /v1/people/addresses/{uuid_address}   actualizar dirección
DELETE /v1/people/addresses/{uuid_address}   eliminar dirección
```

El mismo patrón aplica a: `emails`, `phones`, `identifiers`, `emergency-contacts`, y a cualquier sub-recurso con UUID propio en cualquier servicio del ecosistema.

### Sin conflicto de rutas

FastAPI/Starlette no confunde `/{uuid_person}/addresses` con `/addresses/{uuid_address}` porque el segmento literal `addresses` ocupa posiciones distintas en el path (penúltima vs antepenúltima). No se requiere ordenamiento especial.

## Consecuencias

**Positivas:**
- Los use cases de Update/Delete se simplifican: una sola query por UUID de entidad, sin JOIN ni resolución de ID padre.
- Los clientes no necesitan recordar el UUID del padre para modificar una entidad que ya conocen.
- Escalable a cualquier catálogo relacional del ecosistema (no solo `dh_core`).

**Negativas:**
- El cliente que solo tiene `uuid_person` y quiere eliminar una email específica debe primero listar (`GET /{uuid_person}/emails`) para obtener el `uuid_email`.
- Las rutas ya existentes en clientes deben actualizarse al cambiar de `PATCH /{uuid_person}/emails` a `PATCH /emails/{uuid_email}`.
