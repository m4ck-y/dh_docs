# Propuesta de Migración: Módulo Auth (001)

## 📝 Resumen
Implementar el núcleo de autenticación en `api_core` basándose en la lógica de la plantilla. Este módulo será el encargado de generar y verificar los tokens JWT que usará todo el ecosistema (Middleware y Microservicios).

## 🔍 Análisis de la Plantilla
- **Ubicación**: `template_backend_python/app/auth`
- **Componentes**:
  - `application/auth.py`: Lógica de login y generación de tokens.
  - `domain/schemas.py`: Esquemas Pydantic para `Token`, `TokenData`, y `Login`.
  - `infrastructure/implementation.py`: Lógica de hashing de contraseñas (usa `passlib`).
  - `services/routes.py`: Endpoints de `/login` y `/verify-token`.

## 🏗️ Plan de Adaptación para `api_core`
- **Contexto Destino**: `app/contexts/auth` (Nuevo contexto).
- **Integración con `Account`**: La lógica de Auth consultará el contexto `account` existente en `api_core` para validar credenciales.
- **Seguridad**: Se utilizarán las claves secretas definidas en `.env` para la firma de tokens HS256.

## 🚀 Pasos de Ejecución (PLANIFICACIÓN)
1.  **Instalar dependencias**: `uv add "python-jose[cryptography]" passlib[bcrypt]`.
2.  **Crear estructura**: Generar carpetas `domain`, `application`, `infrastructure` dentro de `app/contexts/auth`.
3.  **Migrar Schemas**: Copiar y adaptar `Token` y `LoginRequest`.
4.  **Implementar Casos de Uso**: Crear el servicio de autenticación que valide el password hash.
5.  **Exponer Rutas**: Agregar el router de Auth al `main.py` de `api_core`.

## ⚠️ Riesgos y Consideraciones
- **Impacto**: Este es el cambio más crítico. Sin este módulo funcionando, el `api_middleware` no podrá validar sesiones de forma centralizada.
- **Desacoplamiento**: Debemos asegurar que `auth` no dependa circularmente de `account`.

---
*Para dar el visto bueno y que empiece a preparar los archivos (sin ejecutar todavía), por favor responde "Aprobar Propuesta Auth".*
