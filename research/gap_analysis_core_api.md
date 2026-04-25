# Dashboard de Migración: `api_core` 📊

Este tablero muestra el estado de alineación de cada módulo de `api_core` respecto a los estándares de la plantilla de referencia.

## Estado por Módulo

| Módulo | Estado | Nivel de Alineación | Documento de Propuesta |
| :--- | :--- | :--- | :--- |
| **Auth (JWT/Auth)** | 🔴 Pendiente | 0% | [propuesta-001-auth.md](../ideas/propuesta-001-auth.md) |
| **Security (RBAC)** | 🔴 Pendiente | 10% | TBD |
| **Account** | 🟡 Parcial | 40% | TBD |
| **Person** | 🟡 Parcial | 60% | TBD |
| **Company** | 🟡 Parcial | 40% | TBD |
| **Employee** | 🟡 Parcial | 30% | TBD |
| **Health Facility** | 🔴 Pendiente | 0% | TBD |
| **Health Profile** | 🔴 Pendiente | 0% | TBD |
| **Health Monitoring**| 🔴 Pendiente | 0% | TBD |

---

## Leyenda de Estados
- 🔴 **Pendiente**: No existe en `api_core` o está vacío.
- 🟡 **Parcial**: Existe pero no sigue Clean Architecture o le faltan entidades clave.
- 🟢 **Completo**: Alineado al 100% con la plantilla y Clean Architecture.
- 🔍 **En Revisión**: Propuesta generada y esperando aprobación del usuario.

## Última Revisión Técnica
- **Fecha**: 2026-04-11
- **Observación**: `api_core` tiene estructuras básicas pero carece de la capa de `application` (Casos de Uso) en la mayoría de sus módulos.
