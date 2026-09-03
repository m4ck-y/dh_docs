# Propuesta de Migración: Módulo Auth (001)

> **Estado: SUPERSEDED**. La estrategia cambió: en lugar de integrar auth en `dh_core`, se creó un microservicio independiente `dh_auth` (TASK-004). Este documento se conserva solo como referencia histórica.

##  Resumen
Implementar el núcleo de autenticación en `dh_core` basándose en la lógica de la plantilla. Este módulo será el encargado de generar y verificar los tokens JWT que usará todo el ecosistema (Middleware y Microservicios).

## Análisis de la Plantilla
- **Ubicación**: `backend/template_backend_python/app/auth`
- **Componentes**:
  - `application/auth.py`: Lógica de login y generación de tokens.
  - `domain/schemas.py`: Esquemas Pydantic para `Token`, `TokenData`, y `Login`.
  - `infrastructure/implementation.py`: Lógica de hashing de contraseñas (usa `passlib`).
  - `services/routes.py`: Endpoints de `/login` y `/verify-token`.

## Plan de Adaptación para `dh_core`
- **Contexto Destino**: `app/contexts/auth` (Nuevo contexto).
- **Integración con `Account`**: La lógica de Auth consultará el contexto `account` existente en `dh_core` para validar credenciales.
- **Seguridad**: Se utilizarán las claves secretas definidas en `.env` para la firma de tokens HS256.

## Pasos de Ejecución (PLANIFICACIÓN)
1.  **Instalar dependencias**: `uv add "python-jose[cryptography]" passlib[bcrypt]`.
2.  **Crear estructura**: Generar carpetas `domain`, `application`, `infrastructure` dentro de `app/contexts/auth`.
3.  **Migrar Schemas**: Copiar y adaptar `Token` y `LoginRequest`.
4.  **Implementar Casos de Uso**: Crear el servicio de autenticación que valide el password hash.
5.  **Exponer Rutas**: Agregar el router de Auth al `main.py` de `dh_core`.

## WARNING: Riesgos y Consideraciones
- **Impacto**: Este es el cambio más crítico. Sin este módulo funcionando, el `api_middleware` no podrá validar sesiones de forma centralizada.
- **Desacoplamiento**: Debemos asegurar que `auth` no dependa circularmente de `account`.

---
*Propuesta archivada. Ver TASK-004 para la implementación real de `dh_auth`.*
