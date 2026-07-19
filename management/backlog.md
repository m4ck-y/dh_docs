# Backlog de Tareas: Hospital Digital

Este documento es el centro de control para todas las tareas del proyecto.

## Done: En Progreso (Doing)
- [x] Estructurar directorio `docs/` optimizado para LLMs.
- [x] Migrar diagramas Draw.io de Historia Clínica a Mermaid.
- [ ] Implementar estrategia de **Identidad Unificada** (Unified Onboarding) y escalamiento de roles.
- [ ] Iniciar migración del módulo `auth` a `dh_core`.

## Próximas Tareas (To Do)

### dh_core
- [ ] Integrar `passlib` y `jose` para gestión de tokens.
- [ ] Crear capa de dominio para `Security`.
- [ ] Refactorizar `Person` para cumplir con Clean Architecture al 100%.

### app_questionnaire
- [ ] Crear cliente interno para conectar con `dh_core`.

### Infraestructura
+
- [ ] Configurar variables de entorno globales (.env central).

### Persistencia FHIR (TASK-015)
- [ ] Fase 0: Infraestructura base (Beanie docs, sync service, mapping utilities).
- [ ] Fase 1: RBAC + Admin seed.
- [ ] Fase 2: Organization (company → FHIR Organization).
- [ ] Fase 3: Patient (person → FHIR Patient).
- [ ] Fase 4: Practitioner (person+employee → FHIR Practitioner).

## Ideas y Backlog (Icebox)
- [ ] Monitoreo en tiempo real de signos vitales (app_health_monitoring).
- [ ] Generación automática de reportes PDF para pacientes.

---
*Para ver el análisis de lo que falta, consulta el [Análisis de Brechas](gap_analysis_core_api.md).*
