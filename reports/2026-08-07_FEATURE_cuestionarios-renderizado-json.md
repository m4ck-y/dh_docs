**Proyecto o Apartado:** Plataforma Libersalus — Frontend de paciente (`lsinciosesionweb`) / Módulo de cuestionarios de bienestar (modo demo)

**Título de la actividad o tarea:** Renderizado de cuestionarios psicométricos desde JSON y unificación de la interfaz del flujo

**Descripción de la actividad o tarea:**
Se implementó el renderizado automático de los 12 instrumentos psicométricos del área Bienestar Emocional a partir de JSONs que siguen el contrato de datos de `dh_forms`. El objetivo de negocio es permitir explorar los instrumentos clínicos (HADS, CDI, GDS, PHQ-9, GAD-7, CTH, EDAH, ASRS, DTS, SPIN, TAS-20, EAG) en modo demo con datos fieles a los diagramas fuente, sin depender del backend.

El trabajo se articuló en tres frentes:

**1. Aterrizaje de los diagramas (drawio → Mermaid).** Las 17 pestañas del drawio se convirtieron **a mano** (sin script generador) a diagramas `.mmd` individuales en `docs/historia_clinica/questionnaires/mermaid/` (12 cuestionarios + 5 anexos/secciones), cada uno con su tabla de interpretación en `*-review.md` (Markdown clásico `Puntuacion | Interpretacion`). El patrón aprobado es un nodo por ítem con opciones numeradas con valor (`A.1.1 Nunca (0)`), cadena secuencial una-flecha-por-línea, y flujos condicionales explícitos. Todos renderizan con mermaid-cli (`mmdc`) y se auditaron sobre el SVG renderizado (orden de coordenadas `x` de los nodos + conteo de `marker-end`). Durante la auditoría se corrigieron y documentaron discrepancias del drawio: HADS como flujo secuencial (no árbol paralelo), valores de la Parte B del ASRS, el ítem 13 del DTS (duplicado del 12) renumerando 14-18, el ítem 25 del CDI invertido respecto al estándar, y rarezas de rotulación (doble rótulo en CDI 5 y ASRS 15, GDS 11) anotadas en comentarios `%%`.

**2. JSONs de instrumentos para renderizado automático.** Se generaron **a mano**, a partir del análisis de cada cuestionario, los 12 instrumentos del área **Bienestar Emocional** como módulos JS con el contrato `dh_forms` en `src/config/cuestionarios/`: `gad7.js`, `phq9.js`, `hads.js`, `cdi.js`, `gds.js`, `cth.js`, `edah.js`, `asrs.js`, `dts.js`, `spin.js`, `tas20.js` y `eag.js`. Cada JSON declara `id`/`key`, nombre, descripción, `target_age_group`, lista de preguntas con opciones de valor numérico y la tabla de interpretación proveniente de su `-review.md`. Caso notable: el **DTS** quedó fiel al contrato con 36 ítems (frecuencia = impares, gravedad = pares) y el `order` 1-36 respeta el drawio; la pregunta de gravedad es condicionada (solo aparece si la frecuencia respondida es distinta de "Nunca"). El catálogo `src/config/cuestionarios.config.js` conecta cada instrumento a su JSON por import dinámico y filtra por perfiles (p. ej. CDI/EDAH solo `menor_tutor`, GDS solo `mayor_asistido`, TAS-20 solo 18-59).

**3. Interfaz del flujo de cuestionarios.** Se unificó el lenguaje visual de las tres pantallas del flujo y del Inicio:
- **Runner** (`/cuestionarios/:area/:key`): hero con gradiente de la marca, métricas en vivo (reactivos, tiempo, respondidas), cuerpo en 2 columnas con panel de progreso sticky, opciones de respuesta custom (radio/checkbox), badge con el `order` del instrumento (fiel en el DTS) y gating frecuencia→gravedad verificado en vivo.
- **Lista principal** (`/cuestionarios`): pasó de maqueta con datos falsos corporativos a pantalla funcional con hero, métricas globales reales, 4 tarjetas de área clicables con progreso real, evaluación destacada, seguimiento por área y detalle de avance.
- **Página del área** (`/cuestionarios/emocional`): se reescribió con hero, métricas reales (instrumentos/completados/en progreso/avance), buscador, tabs en español, tarjetas con acrónimo del instrumento, badge de estado con color y CTA contextual (Iniciar/Continuar/Ver respuestas). Causa raíz corregida: `area.module.css` estaba **vacío (0 bytes)**, por lo que la página se renderizaba sin estilos (clases `undefined`).
- **Inicio / "Mis Cuestionarios"**: se creó el componente reutilizable `ListaCuestionarios` (lista en columna, scroll vertical de 5px/thin, selección de detalle) usado por las 5 vistas (Todos, Físico, Emocional, Social, Nutricional), eliminando la duplicación del patrón lista+detalle y los `@import` cruzados de CSS.
- Componentes de tarjetas hechos reutilizables con props reales: `TarjetaProgresoArea`, `TarjetaEvaluacion` (gráfica circular `conic-gradient`), `TrjEstadoCuestionario` (navegación con `Link`, corrigiendo el bug de `<a href>` fuera del `basename="/panel"`) y `TarjetaListadoAvance`.

**Estado de la actividad o tarea:** Completado

**Avances de la actividad (si lo requiere):**
- Los 17 diagramas `.mmd` renderizan con `mmdc` y la auditoría de SVG (orden de `x` + `marker-end`) dio OK; tablas de interpretación en los 12 `*-review.md`.
- 12 JSONs de instrumentos creados en `src/config/cuestionarios/` y conectados por import dinámico en `cuestionarios.config.js`, con gating por perfil/edad.
- Motor de activación `unlock_if` implementado en `src/utils/progreso.js` (`isUnlocked`/`evalRule` con reglas `percent` y `answer` y combinadores `all`/`any`); hoy solo el follow-up de ejemplo "Hábitos de Ejercicio" del área Física lo usa.
- Flujo completo verificado en preview: lista → área → runner (GAD-7, PHQ-9, DTS con gating) y tabs del Inicio con el listado reutilizable. Build de producción verde.

**Próximos pasos:**
- **Implementar la lógica de activación de cuestionarios a partir de los activadores/triggers del drawio**: que un instrumento se libere según el resultado o respuestas de otro (p. ej. reglas `percent >=` o `answer includes` como las que ya soporta `evalRule`), aplicadas a los 12 instrumentos emocionales — hoy todos tienen `unlock_if: null`. Esto incluye revisar los flujos condicionales dentro de cada cuestionario (como frecuencia→gravedad del DTS) tal como están en el drawio.
- Poblar las áreas Físico, Social y Nutricional con instrumentos reales (hoy solo Emocional tiene los 12 JSONs; Físico conserva un placeholder `propuesta2.json`).
- Commit pendiente de los cambios cuestionarios (Conventional Commits, en inglés), según el STATUS de `docs/historia_clinica/questionnaires/`.

**Referencias:**
- Fuente de diagramas: `docs/historia_clinica/questionnaires/index.DEMO_quewstionnaire.drawio` → `mermaid/` (índice `index.md`, estado en `STATUS.md`)
- JSONs de instrumentos: `src/config/cuestionarios/*.js` · catálogo: `src/config/cuestionarios.config.js`
- Motor de activación: `src/utils/progreso.js`
- Documento de propuesta: `docs/features/cuestionarios-demo.md`
