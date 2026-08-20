**Proyecto o Apartado:** Plataforma Libersalus — Frontend de paciente (`lsinciosesionweb`) / Módulo de cuestionarios de bienestar — Exportación a Excel

**Título de la actividad o tarea:** Planeación del export a Excel (.xlsx) de los cuestionarios completados: reporte por categoría con hoja de paciente, resumen de puntaje/interpretación y una hoja por instrumento

**Descripción de la actividad o tarea:**
Se elaboró el plan de una nueva capacidad de negocio: **descargar las respuestas de los cuestionarios completados como un archivo Excel (.xlsx) por categoría de bienestar**, listo para adjuntar al expediente o analizar por el profesional de salud. El valor de negocio es doble: (1) hoy las respuestas solo viven en `localStorage` del navegador y no existe forma alguna de extraerlas (ni export, ni reporte, ni impresión), y (2) en modo demo (totalmente offline, `VITE_DEMO=true`) el export funcionaría sin servidor ni conexión, lo que lo convierte en un cierre efectivo de presentación de venta.

El diseño acordado estructura cada archivo con **tres tipos de hoja**:

1. **Hoja "Datos del paciente"**: identidad y perfil (nombre, edad, sexo, perfil de salud, correo y datos opcionales como peso/sangre/estatura), poblada desde la persona demo activa o la cuenta registrada (`obtenerPerfilDemo()`), más fecha de generación y área del reporte.
2. **Hoja "Resumen"**: una tabla `Instrumento | Puntaje | Interpretación | Estado | Fecha` con el cálculo de scoring por instrumento.
3. **Hojas de instrumento** (una por cuestionario, nombre = `key` del JSON, ej. `PHQ-9`): columnas `pregunta_code | pregunta | answer`, donde `answer` es el **texto de la opción** (lo guardado en `localStorage` es el valor numérico 0-3; el export lo desnormaliza contra `list_options` para que la hoja sea legible sin el manual del instrumento).

**Fuente de los resultados e interpretaciones.** El puntaje no está almacenado: se calcula al momento del export sumando los valores de las respuestas guardadas (`respuestasCuestionario:{id}`) y se interpreta contra `scoring` + `interpretacion` declarados en los propios JSONs de los instrumentos (`src/config/cuestionarios/*.js`) — no hay tablas externas que mantener. Se verificó la cadena de procedencia: los JSONs tomaron las preguntas/opciones del diagrama **`.mmd`** y las tablas de interpretación de los **`*-review.md`** (que a su vez citan como fuente el `index.DEMO_quewstionnaire.drawio`); por ello, si se corrige un corte clínico, el orden de actualización es `drawio → review.md → JSON`.

**Hallazgo relevante durante la planeación.** Los 12 instrumentos del área Emocional no puntúan todos igual: **8 usan `scoring.tipo: "suma"`** (GAD-7, PHQ-9, CDI, GDS, CTH, SPIN, TAS-20, EAG) pero **4 usan `scoring.tipo: "subescalas"`**: HADS (A ansiedad / D depresión), ASRS (Parte A tamizaje / Parte B), EDAH (H, DA, DAH, TC) y DTS (F frecuencia / G gravedad / T total). Por lo tanto, la hoja Resumen debe generar **una fila por subescala** en esos instrumentos y la utilidad de scoring debe manejar ambos formatos. Regla adicional: **solo se interpreta lo completado** — con respuestas parciales el puntaje sería engañoso, así que la fila queda en estado "En progreso" sin interpretación.

**Puntos de descarga previstos.** (1) En el runner del cuestionario (`PlantillaQs.jsx`), botón "Descargar (Excel)" junto a Guardar/Limpiar, activo cuando hay respuestas — el clic más natural. (2) En el encabezado del tab del área (Bienestar Emocional), botón "Descargar Excel" que arma el archivo con las hojas de los instrumentos con respuestas. (3) Futuro: "Mis Cuestionarios" del Inicio, botón por instrumento. La descarga se genera en cliente (`Blob` → `URL.createObjectURL` → `<a download>`), sin servidor ni navegación.

**Decisiones de diseño cerradas en la planeación:** columnas de hoja de instrumento en **3** (`pregunta_code | pregunta | answer`), reservando una 4ª columna `answer_value` numérica solo si se planea re-importar a un backend (contrato `dh_forms`); **v1 exporta la última toma** (hoy `localStorage` solo conserva la aplicación más reciente por instrumento; el historial multi-toma requeriría versionar el storage en `logicPreg.js` y queda fuera de la propuesta); **sin ZIP en v1** (el zip "Descargar todo" se agregaría solo si se pide bajar varias categorías de una vez, con `jszip`); nombre de archivo `Reporte_Cuestionarios_{Área}_{YYYY-MM-DD}.xlsx`.

**Estado de la actividad o tarea:** En desarrollo (planeación — propuesta documentada, pendiente de validación e implementación)

**Avances de la actividad (si lo requiere):**
- Plan de feature completo en `docs/features/excel-export-cuestionarios.md` con estructura del archivo, reglas de export por tipo de pregunta (`SINGLE_CHOICE`, `MULTIPLE_CHOICE` unido con "; ", `TEXT`, condicionales ocultas omitidas, instrumento sin respuestas sin hoja), cambios técnicos (dependencia `xlsx` de SheetJS, utilidad `exportarExcel.js` con las funciones de hoja, botones) y tabla de decisiones pendientes.
- Verificación de la fuente de datos en los 12 JSONs: `scoring` y `interpretacion` presentes y consistentes en formato; detección y documentación de los dos tipos de scoring (`suma` / `subescalas`) con las listas de ítems de cada subescala.
- Verificación de la procedencia drawio → mmd → `*-review.md` → JSON, documentada en el plan con su implicación para correcciones clínicas.
- Pendiente: aprobación de las decisiones abiertas (identificación del paciente en la hoja 1, confirmación de 3 vs 4 columnas, alcance del resumen con puntaje) y auditoría de fidelidad de los 12 JSONs contra sus `*-review.md`.

**Próximos pasos:**
- **Auditoría de fidelidad**: comparar `scoring`/`interpretacion` de los 12 JSONs contra sus tablas en `mermaid/*-review.md` (mismo criterio aplicado a los diagramas mermaid) para confirmar que ningún corte clínico se perdió en la traducción al JSON.
- **Implementación v1**: instalar `xlsx` (SheetJS), crear la utilidad de export (hoja paciente, cálculo de puntaje con `suma`/`subescalas`, hoja resumen, hoja por instrumento, descarga), y los botones en runner y tab del área; validar con un cálculo real de ejemplo (p. ej. GAD-7) en el preview.
- Decidir si la cuenta demo requiere el botón "Restablecer demo" y el mini-formulario de registro rápido (pendientes del flujo demo, anotados en `demo-flujo.md`).

**Referencias:**
- Plan del feature: `docs/features/excel-export-cuestionarios.md` (propuesta)
- Instrumentos y contrato: `src/config/cuestionarios.config.js` · `src/config/cuestionarios/*.js`
- Storage de respuestas y progreso: `src/utils/logicPreg.js` · `src/utils/progreso.js`
- Runner actual: `src/pages/Cuestionarios/PlantillaQs.jsx` · `PreguntasQs.jsx`
- Fuente de diagramas y tablas de interpretación: `docs/historia_clinica/questionnaires/mermaid/` (`.mmd` + `*-review.md`)
- Perfil del paciente demo: `src/config/demo.config.js` (`obtenerPerfilDemo`)
