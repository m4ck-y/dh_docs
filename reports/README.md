# Reportes Arquitectónicos y Auditoría

El objetivo de este directorio (`docs/reports/`) es almacenar el registro histórico de las decisiones arquitectónicas importantes, implementaciones mayores, refactorizaciones y auditorías del sistema **Digital Hospital**. 

Estos documentos actúan como puente de comunicación fundamental entre el equipo de ingeniería y los tomadores de decisiones (*stakeholders*) del negocio.

---

## 📖 Guía de Redacción para Nuevos Reportes

Para asegurar consistencia, profesionalismo y legibilidad, todos los reportes generados en esta carpeta **deben** seguir estas reglas estrictas:

### 1. Convención de Nombres
Los archivos deben utilizar el siguiente formato para ordenarse cronológicamente:
`YYYY-MM-DD_[TIPO]_descripcion-corta.md`

**Tipos válidos:**
- `ARCH`: Cambios a nivel de infraestructura, bases de datos o topología (ej. Migración a TimescaleDB).
- `FEATURE`: Integración de grandes componentes o flujos de negocio nuevos (ej. Middleware, Motor de reglas).
- `REFACTOR`: Cambios estructurales masivos sin alteración del comportamiento funcional.
- `BUGFIX`: Resolución de incidentes críticos, fallas de seguridad o *post-mortems*.

### 2. Tono y Voz (Tercera Persona)
- **Voz pasiva e impersonal**: Está estrictamente **prohibido** utilizar redacción en primera persona ("decidimos", "hicimos", "nuestro", "yo"). 
- **Correcto:** *"Se decidió implementar...", "En el ecosistema se almacenan...", "La arquitectura permite..."*

### 3. Estructura Obligatoria del Documento

Todo reporte técnico debe tener como prioridad el entendimiento de negocio antes de ahondar en el código. La estructura exacta y obligatoria debe ser la siguiente:

```markdown
**Proyecto o Apartado:** [Nombre del microservicio o área afectada, ej. API Middleware / Health Monitoring]

**Título de la actividad o tarea:** [Título claro y conciso de lo que se implementó]

**Descripción de la actividad o tarea:** 
[Aquí se redacta de qué trata, los beneficios principales y la visión de negocio para no-técnicos, junto con los detalles técnicos de la implementación. Siempre usando redacción en tercera persona].

**Estado de la actividad o tarea:** [Concluido / En desarrollo / Actualización continua]

**Avances de la actividad (si lo requiere):** 
[Listado de avances, pruebas realizadas, o siguientes pasos si la tarea aún está "En desarrollo" o en "Actualización continua"].
```

Mantener estos reportes bajo este estándar estricto permite trazar la evolución de la plataforma de manera uniforme y profesional.
