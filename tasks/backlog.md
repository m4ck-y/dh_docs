# Backlog de Tareas: Hospital Digital

Este documento es el centro de control para todas las tareas del proyecto.

## 🏁 En Progreso (Doing)
- [x] Estructurar directorio `docs/` optimizado para LLMs.
- [ ] Iniciar migración del módulo `auth` a `api_core`.

## 📋 Próximas Tareas (To Do)

### api_core
- [ ] Integrar `passlib` y `jose` para gestión de tokens.
- [ ] Crear capa de dominio para `Security`.
- [ ] Refactorizar `Person` para cumplir con Clean Architecture al 100%.

### app_questionnaire
- [ ] Crear cliente interno para conectar con `api_core`.

### Infraestructura
+
- [ ] Configurar variables de entorno globales (.env central).

## 💡 Ideas y Backlog (Icebox)
- [ ] Monitoreo en tiempo real de signos vitales (app_health_monitoring).
- [ ] Generación automática de reportes PDF para pacientes.

---
*Para ver el análisis de lo que falta, consulta el [Análisis de Brechas](gap_analysis_core_api.md).*
