**Proyecto o Apartado:** Frontend web de Libersalus — Módulo de Cuestionarios e Historia Clínica (`lsinciosesionweb`)

**Título de la actividad o tarea:** Corrección de bugs críticos, implementación de estados de cuestionario, glassmorphism y preparación para módulo de Historia Clínica

**Descripción de la actividad o tarea:**
Se realizó una ronda completa de correcciones y mejoras en el módulo de cuestionarios, abordando bugs de persistencia, navegación y experiencia de usuario. Además, se implementó un sistema de estados visuales con badges de color, se unificó el diseño glassmorphism en todas las pantallas del módulo, y se creó la página de "Mi Historia Clínica" con tres propuestas de UI intercambiables.

En primer lugar, se corrigió un bug crítico de persistencia donde el `storageKey` utilizaba el `name` del cuestionario ("Programa ISSET en tu casa - Calidad de Vida SF-12") en lugar del `key` ("CALIDAD_VIDA_SF12"), causando que el progreso no se mostrara en la vista de área. Se actualizó la función `storageKeyFor()` para usar `key > id > name` como prioridad.

En segundo lugar, se corrigió el comportamiento del botón "Volver a área": anteriormente solo mostraba un modal si existían cambios sin guardar, pero el auto-guardado ya había sincronizado el estado. Se cambió la condición a `answeredCount > 0 && !completado` para que siempre muestre el modal informativo cuando hay respuestas.

En tercer lugar, se resolvió un bug de navegación donde el botón "Volver" llevaba a la página de todos los cuestionarios en lugar del área específica. La causa era que `forceArea` recibía `areaData.area3D` ("Físico" con tilde) pero la ruta esperaba el `id` ("fisico" sin tilde). Se corrigió en `Run.jsx` para pasar el parámetro `area` del URL.

Se implementó un sistema de estados visuales con badges de color para las cards de cuestionarios:
- **Completado** (verde): 100% respondido y guardado formalmente
- **Pendiente** (naranja): 100% respondido pero sin confirmar guardado
- **En progreso** (amarillo): parcialmente respondido
- **No iniciado** (gris): sin respuestas

Se unificó el diseño glassmorphism en todas las pantallas del módulo de cuestionarios (`/cuestionarios`, `/cuestionarios/{area}`, `/cuestionarios/{area}/{key}`) con fondos translúcidos, blur sutil y bordes minimalistas. Se eliminaron bordes de color excesivos que rompían la estética minimalista.

Se creó la página "Mi Historia Clínica" (`/mi-salud/historia-salud`) con tres propuestas de UI intercambiables mediante un selector flotante: Cards Expandibles (Acordeón), Tabs Horizontales y Timeline Vertical. Cada propuesta incluye secciones de Antecedentes Heredofamiliares, Antecedentes Patológicos y Padecimientos Actuales con iconos SVG personalizados y glassmorphism.

Se actualizó la documentación técnica con diagramas Mermaid detallados del comportamiento de botones, modales y estados por cada escenario del flujo de cuestionarios.

Se creó un workflow de GitHub Actions (`deploy-frontend.yml`) para despliegue automático a GitHub Pages en cada push a la rama `dev-questionnaires`.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad:**
- Corrección de `storageKey` en `PlantillaQs.jsx`: agregado `cuestionario.key` como prioridad en `storageKeyFor()`.
- Corrección de modal "Volver": condición cambiada de `hayCambiosSinGuardar` a `answeredCount > 0 && !completado`.
- Corrección de navegación "Volver": `Run.jsx` ahora pasa `area` (param del URL) en lugar de `areaData.area3D`.
- Persistencia del estado `guardado`: se guarda en `${storageKey}:guardado` en localStorage y se lee al cargar el cuestionario.
- Nuevo estado "pendiente" en `progressState()`: distingue entre 100% guardado (completado) y 100% sin guardar (pendiente).
- Badges visuales: CSS en `area.module.css` y `trjEstadoCuestionario.module.css` con colores por estado.
- Glassmorphism minimalista aplicado a: `plantillaQs.module.css`, `preguntasQS.module.css`, `cuestionarios.module.css`, `area.module.css`.
- Página "Mi Historia Clínica": `HistoriaSalud.jsx` con 3 propuestas, selector flotante, iconos SVG personalizados.
- Documentación: `docs/features/cuestionarios-comportamiento.md` actualizado con diagramas Mermaid de botones, modales y estados.
- Workflow: `.github/workflows/deploy-frontend.yml` para deploy automático a GitHub Pages.
- **Pruebas realizadas:** flujo completo verificado en preview: SF-12 al 19% con modal "Volver" funcionando, PHQ-9 guardado mostrando badge "Completado" verde, GAD-7 al 100% sin guardar mostrando badge "Pendiente" naranja, navegación a áreas correcta.
- **Siguientes pasos:** Viernes 22 de agosto — iniciar módulo de Historia Clínica con diagramas Draw.io.
