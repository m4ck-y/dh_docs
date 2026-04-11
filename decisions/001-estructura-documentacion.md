# ADR 001: Estructura de Documentación y Gestión de Tareas

## Estado
Aceptado

## Contexto
El proyecto Hospital Digital involucra múltiples microservicios y colaboración con IAs. Se necesita una estructura de documentación que sea organizada, escalable y fácil de navegar para herramientas automatizadas.

## Decisión
Se ha decidido implementar una carpeta centralizada `docs/` con la siguiente organización:
1. `adr/`: Para registros de decisiones arquitectónicas.
2. `ideas/`: Para discutir nuevas propuestas (RFCs).
3. `tasks/`: Para el backlog y análisis de tareas.
4. `STATUS.md`: Un documento de contexto rápido para IAs.

## Consecuencias
- **Positivas**: Mayor claridad en el porqué de las decisiones, mejor contexto para asistentes de IA, separación clara entre tareas terminadas y pendientes.
- **Negativas**: Mayor sobrecarga de mantenimiento (cada decisión importante debe documentarse).
