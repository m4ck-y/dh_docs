# ADR 018: Migración de Entidad User de People a Auth

**Estado**: Aceptado  
**Fecha**: 2026-04-26  
**Contexto**: Refactorización de modelos compartidos en `dh_shared`

## Contexto

Durante el desarrollo de `dh_shared` para compartir modelos entre microservicios, se identificó una duplicación y confusión de responsabilidades en las entidades `user`:

1. **`people.user`**: Cuenta de usuario del sistema (username, password_hash, is_active)
2. **`auth.user`**: Credenciales de autenticación (type, provider, provider_id)

Esta duplicación generaba:
- Conflictos de nombres en importaciones
- Responsabilidades mezcladas entre esquemas
- Duplicación del campo `password_hash`
- Confusión conceptual sobre qué entidad usar

## Decisión

**Mover la entidad `user` del schema `people` al schema `auth`** y eliminar la entidad `user` duplicada de `auth`.

### Cambios Realizados

#### 1. Schema `auth`
- **Antes**: `user` con credenciales (type, provider, provider_id)
- **Después**: `user` con cuenta del sistema (username, password_hash, is_active)
- **Relación**: `person ||--|| user` (1:1 con person)

#### 2. Schema `people`
- **Eliminado**: Entidad `user` completa
- **Actualizado**: Referencias en `emergency_contact` ahora apuntan a `auth.user`

#### 3. Modelos en `dh_shared`
- **Actualizado**: `dh_shared.models.auth.user.AuthUser` con nueva estructura
- **Eliminado**: Referencias a `ECredentialType` y campos de OAuth

### Nueva Estructura

```sql
-- Schema: auth
user {
    Integer id PK
    UUID uuid
    Integer id_person FK
    String(254) username  -- Always equals email (RFC 5321 max length)
    String password_hash
    Boolean is_active
}
```

### Convención de Username

**Decisión**: El campo `username` siempre será igual al email del usuario.

**Justificación**:
- Simplifica el proceso de registro (no requiere selección de username)
- Garantiza unicidad automática (emails ya son únicos)
- Facilita el proceso de login (usuarios usan su email)
- Elimina la necesidad de validaciones de disponibilidad de username

## Consecuencias

### Positivas
- **Responsabilidad única**: `auth` maneja cuentas de usuario
- **Eliminación de duplicación**: Un solo `password_hash`
- **Claridad conceptual**: No hay confusión entre entidades
- **Importaciones limpias**: `from dh_shared.models.auth import AuthUser`

### Negativas
- **Migración requerida**: Servicios existentes deben actualizar importaciones
- **Dependencia cruzada**: `people.emergency_contact` referencia `auth.user`

### Mitigación
- Actualizar todos los servicios que importen `User` de `people`
- Documentar la nueva ubicación en `dh_shared`
- Mantener compatibilidad durante período de transición

## Implementación

1. ✅ Actualizar ERD de `auth` y `people`
2. ✅ Modificar `AuthUser` en `dh_shared`
3. 🔄 Actualizar servicios que usen el modelo
4. 🔄 Ejecutar migraciones de base de datos

## Referencias

- [ADR 010: Database ID Strategy](010-database-id-strategy.md)
- [ADR 017: Referencias Cross-Service](017-referencias-cross-service.md)
- [AGENTS.md: Backend Architecture](../AGENTS.md#backend-architecture)