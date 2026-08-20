**Proyecto o Apartado:** Frontend web de Libersalus — Módulo de Cuestionarios (`lsinciosesionweb`)

**Título de la actividad o tarea:** Exportación a Excel de todas las categorías en un ZIP y acceso directo a Cuestionarios desde el menú lateral

**Descripción de la actividad o tarea:**
Se completó el cierre del flujo de descarga de cuestionarios con dos adiciones orientadas a la experiencia del usuario final y a la utilidad clínica de la información.

En primer lugar, se implementó el botón **"Descargar todo (ZIP)"** en el encabezado de la página principal de Cuestionarios. Su propósito de negocio es permitir que el profesional de la salud (o el propio paciente) obtenga en un solo paso el reporte completo de las categorías con respuestas guardadas, sin tener que entrar área por área. Técnicamente, la función `descargarZipTodo()` recorre las áreas configuradas (`AREAS`), arma un archivo `.xlsx` por cada categoría que tenga al menos un cuestionario con respuestas (reutilizando la misma estructura de hojas: "Datos del paciente", "Resumen" con puntaje/interpretación y una hoja por instrumento) y los empaqueta en `Reporte_Cuestionarios_Todas_las_Categorias_{fecha}.zip` mediante la librería `jszip`. El botón se habilita únicamente cuando existe alguna respuesta guardada en cualquier categoría, evitando descargas vacías, y muestra el estado "Generando…" durante el proceso. Todo el procesamiento ocurre en el cliente, por lo que la funcionalidad opera completa en modo demo offline, sin servidor.

En segundo lugar, se agregó el ítem **"Cuestionarios"** al menú lateral de la plataforma (entre "Monitor de salud" y "Franky te acompaña"), con iconografía propia (clipboard con checklist) en sus variantes normal y activa, consistente con el estilo del resto de los íconos del menú. La ruta quedó centralizada en la configuración (`ROUTES.CUESTIONARIOS`) y el enlace funciona tanto en el menú de escritorio (colapsable a iconos) como en el menú móvil. El valor de negocio es reducir la fricción de navegación: el usuario ya no depende de llegar a Cuestionarios desde el inicio, sino que accede directamente desde cualquier pantalla.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad:**
- Instalación de la dependencia `jszip@3.10.1` (única adición; `vite-plugin-pwa` intacto).
- Implementación de `descargarZipTodo()` en `src/utils/exportarExcel.js`, con nombres de archivo sin colisiones y omisión de categorías sin respuestas.
- Botón "Descargar todo (ZIP)" en el hero de `Cuestionarios.jsx` con estilos consistentes con el botón "Descargar Excel" de las áreas.
- Nuevas rutas e ítem de menú: `ROUTES.CUESTIONARIOS` en `src/config/routes.jsx` y link en `src/components/Header/menu/Menu.jsx`, con los íconos `icoCuestionarios.svg` e `icoActiveCuestionarios.svg`.
- Actualización del plan de feature en `docs/features/excel-export-cuestionarios.md` (el ZIP pasó de pendiente a implementado).
- **Pruebas realizadas:** el ZIP descargado se validó como archivo real (magic `PK`) conteniendo `Reporte_Bienestar_Emocional_2026-08-14.xlsx` con las hojas de paciente y resumen; el ítem del menú navega correctamente a `/panel/cuestionarios` y muestra el estado activo; build de producción sin errores.
- **Siguientes pasos posibles:** botón de ZIP también en "Mis Cuestionarios" del Inicio, historial multi-toma (versionado por fecha en `logicPreg.js`) y Fase 3 (mostrar puntaje/interpretación en pantalla al terminar).
