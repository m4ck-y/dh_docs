# Planning: TASK-001 - Migración Auth

## 1. Análisis
- **Situación Actual**: `api_core` tiene contextos vacíos o parciales. `template_backend_python` tiene una implementación robusta de Auth.
- **Riesgo**: Compromiso de seguridad en la migración de JWT.
- **Estrategia**: Usar `api_core/app/contexts/security` para toda la lógica de autenticación y autorización.

## 2. Fases
### Fase I: Estructura (Día 1)
- [ ] Definir schemas de Pydantic para JWT.
- [ ] Configurar inyección de dependencias para seguridad.

### Fase II: Lógica (Día 2)
- [ ] Migrar decoradores y utilidades de token.
- [ ] Integrar con el contexto de `person` para obtención de identidad.

### Fase III: Base de Datos (Día 3)
- [ ] Asegurar que las tablas de seguridad están en el esquema correcto de Postgres.
- [ ] Registrar logs de auditoría de inicio de sesión.
