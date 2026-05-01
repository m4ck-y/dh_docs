# Documentación Digital Hospital

Bienvenido al centro de documentación del proyecto. Este directorio sigue el estándar de **Research → Decision → Task**.

> [!IMPORTANT]
> **Política de Idioma**: Todos los archivos de documentación (.md) dentro de esta carpeta deben escribirse siempre en **Español**.

## Secciones Principales

- **[Investigación (research/)](research/)**: Análisis, comparativas y hallazgos técnicos previos a las decisiones.
- **[Decisiones (decisions/)](decisions/)**: Registro oficial de decisiones técnicas y arquitectónicas (ADRs).
- **[Tareas (tasks/)](tasks/)**: Gestión granular del progreso del desarrollo.
- **[Arquitectura (architecture/)](architecture/)**: Diagramas y especificaciones de alto nivel.
- **[Gestión (management/)](management/)**: Backlog del proyecto y pautas de comunicación interna. Incluye el flujo de **Onboarding Legacy**.
- **[Historial Clínico (historial_clinico/)](historial_clinico/)**: Estructura de formularios clínicos, mapeo de base de datos y diagramas de flujo Mermaid.
- **[Base de Datos (db/)](db/)**: Diccionario de datos, ERDs y definiciones de esquemas para PostgreSQL y MongoDB.
- **[Normativa (nom024/)](nom024/)**: Documentación relacionada con la norma NOM-024-SSA3-2012.

---

## Nomenclatura
- **`dh_`**: Prefijo utilizado en microservicios y componentes para abreviar el nombre del proyecto (**Digital Hospital**). Ejemplo: `dh_onboarding_back`.

---

## Estándares de Persistencia
- **Relacional**: PostgreSQL + SQLAlchemy.
- **Documental**: MongoDB + **Beanie ODM** (asíncrono y basado en Pydantic).

---

## Estado y Reportes
- **[Estado Actual (STATUS.md)](STATUS.md)**: Resumen ejecutivo del proyecto para IAs y humanos.
- **[Informes de Auditoría (reports/)](reports/)**: Reportes detallados de sesiones o hitos.

---
*Para guías técnicas de agentes en inglés, consulte el archivo [AGENTS.md](../../AGENTS.md) en la raíz.*
