# Estado del Proyecto (LLM Context)

**Última actualización**: 2026-04-25

## Resumen Ejecutivo
El proyecto ha completado la **Auditoría de Estándares de Base de Datos** y ha definido la **Arquitectura de Onboarding**. Se está procediendo con la implementación del microservicio de Waitlist y la integración del flujo "Person-first".

## Estado de los Servicios

| Servicio | Estado | Notas |
| :--- | :--- | :--- |
| `api_middleware` | Activo | Gateway único. |
| `api_core` | En Refactor | Auditoría de DB completada. Schemas actualizados. |
| `app_waitlist` | Planeado | TASK-001 creada. Persistencia en MongoDB. |
| `app_questionnaire` | Estable | FormFlow operativo. |

## Bloqueos Actuales
- Ninguno.

## Objetivos Inmediatos
1. Implementar `TASK-002`: Microservicio de Waitlist (MongoDB).
2. Desarrollar `TASK-003`: Microservicio de Onboarding (`dh_onboarding_back`).
3. Ejecutar `TASK-004`: Extracción de la lógica de Auth y MFA a `app_auth`.
4. Finalizar la migración de `iam` en `api_core`.

---
*Este documento es la fuente de verdad para el contexto de la IA.*
