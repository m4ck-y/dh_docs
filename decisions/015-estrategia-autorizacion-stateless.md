# ADR 015: Estrategia de Autorización Stateless via JWT

## Estado
Aceptado

## Contexto
Con la implementación de un sistema Multi-tenant basado en el esquema IAM (Identity and Access Management), el sistema necesita validar permisos en cada petición de forma extremadamente rápida. Conectar el `api_middleware` directamente a la base de datos PostgreSQL generaría un cuello de botella y un acoplamiento indeseado entre la infraestructura de red y el dominio de datos.

## Decisión
Adoptar un modelo de **Autorización Stateless** (sin estado) utilizando los claims del JWT como fuente de verdad para el control de acceso.

### Reglas de Implementación:
1. **Generación Única**: Solo el microservicio `dh_auth` tiene permiso para consultar las tablas de IAM (Tenants, Memberships, Roles, Permissions) y generar tokens.
2. **Tokens Autocontenidos**: El JWT debe incluir no solo la identidad del usuario (`sub`), sino también el contexto del `tenant` activo y la lista aplanada de `permissions` (formato `recurso:operación`).
3. **Validación en Middleware**: El `api_middleware` validará la firma del token (RS256/HS256) y autorizará o denegará el acceso basándose exclusivamente en los permisos contenidos en el payload.
4. **Desacoplamiento**: El `api_middleware` NO tendrá conexión a ninguna base de datos de negocio o identidad.

### Estructura del Payload (Propuesta):
El JWT generado por `dh_auth` deberá seguir esta estructura para permitir la validación stateless:

```json
{
  "iss": "dh_auth",
  "sub": "uuid-persona",        // person.uuid
  "iat": 1714160000,
  "exp": 1714163600,
  "identity": {
    "p_id": 123,                // person.id (interno)
    "email": "usuario@ejemplo.com",
    "name": "Nombre Usuario"
  },
  "context": {
    "tenant": "key-del-tenant", // tenant.key
    "m_id": "uuid-membresia"    // membership.uuid
  },
  "roles": ["admin", "editor"],
  "permissions": [
    "recurso:operacion",        // ej: "patient:read"
    "recurso:operacion"
  ]
}
```

## Consecuencias

### Positivas:
- **Performance**: Validación en microsegundos sin consultas I/O.
- **Escalabilidad**: El middleware puede escalar horizontalmente sin aumentar la carga en PostgreSQL.
- **Seguridad**: El radio de explosión se reduce al centralizar la lógica de emisión en un solo servicio.

### Negativas:
- **Tamaño del Token**: Tokens con demasiados permisos pueden incrementar el tamaño de las cabeceras HTTP.
- **Revocación**: La revocación inmediata de permisos requiere estrategias adicionales (como TTLs cortos o listas de revocación en caché/Redis).

## Referencias
- [JWT.io Introduction](https://jwt.io/introduction/)
- [Stateless Auth Patterns](https://auth0.com/blog/stateless-auth-for-stateful-apps/)
