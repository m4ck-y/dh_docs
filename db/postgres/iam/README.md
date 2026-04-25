# iam

Schema de PostgreSQL para control de acceso, roles y permisos (multi-tenant).

Implementa un modelo RBAC (Role-Based Access Control) donde los permisos se componen de recurso + operacion, los roles son por tenant, y los usuarios acceden via membresías.

## Entidades

| Entidad | Descripcion |
|---|---|
| `tenant` | Empresa u organizacion (soporte multi-tenant) |
| `membership` | Vinculo persona-tenant con estado de invitacion |
| `role` | Rol dentro de un tenant (no global) |
| `resource` | Dominio funcional del sistema (ej: billing, crm) |
| `operation` | Verbo del sistema (ej: create, read, update, delete) |
| `permission` | Combinacion resource + operation (ej: billing.create) |

## Tablas intermediarias (N:N)

| Tabla | Relacion |
|---|---|
| `user_role` | membership + role |
| `role_permission` | role + permission |

## Enums

| Enum | Valores |
|---|---|
| `EMembershipStatus` | `PENDING`, `ACTIVE`, `SUSPENDED` |

## Dependencias externas

| Schema | Tabla | Uso |
|--------|-------|-----|
| `people` | `person` | `membership` referencia `person` via `id_person FK` |

## Archivos

| Archivo | Descripcion |
|---|---|
| [ERD.mmd](./ERD.mmd) | Diagrama ERD del schema en Mermaid |