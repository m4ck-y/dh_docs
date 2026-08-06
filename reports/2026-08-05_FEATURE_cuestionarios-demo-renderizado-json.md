**Proyecto o Apartado:** Plataforma Libersalus — Frontend de paciente (`lsinciosesionweb`) / Módulo de cuestionarios de bienestar (modo demo)

**Título de la actividad o tarea:** Cuestionarios de bienestar en modo demo: aterrizaje de los diagramas drawio a Mermaid, perfiles de usuario de demostración y renderizado de instrumentos desde JSON

**Descripción de la actividad o tarea:**
Se consolidó el ciclo completo del módulo de cuestionarios en modo demo (totalmente offline, `VITE_DEMO=true`): desde el diagrama fuente de 17 páginas (`index.DEMO_quewstionnaire.drawio`) hasta el renderizado real de los instrumentos dentro de la aplicación. El objetivo de negocio es permitir explorar la plataforma —y evaluar el flujo de evaluación de bienestar— sin depender del backend, con datos de ejemplo coherentes y fieles a los instrumentos clínicos definidos en el drawio.

El trabajo se articuló en cuatro frentes:

**1. Aterrizaje de los diagramas (drawio → Mermaid).** Las 17 pestañas del drawio se convirtieron **a mano** (sin script generador) a diagramas `.mmd` individuales en `docs/historia_clinica/questionnaires/mermaid/` (12 cuestionarios + 5 anexos/secciones), cada uno con su tabla de interpretación en `*-review.md` (Markdown clásico `Puntuacion | Interpretacion`). El patrón aprobado es un nodo por ítem con opciones numeradas con valor (`A.1.1 Nunca (0)`), cadena secuencial una-flecha-por-línea, y flujos condicionales explícitos. Todos renderizan con mermaid-cli (`mmdc`) y se auditaron sobre el SVG renderizado (orden de coordenadas `x` de los nodos + conteo de `marker-end`). Durante la auditoría se corrigieron y documentaron discrepancias del drawio: HADS como flujo secuencial (no árbol paralelo), valores de la Parte B del ASRS, el ítem 13 del DTS (duplicado del 12) renumerando 14-18, el ítem 25 del CDI invertido respecto al estándar, y rarezas de rotulación (doble rótulo en CDI 5 y ASRS 15, GDS 11) anotadas en comentarios `%%`.

**2. Perfiles de usuario demo.** Se crearon 4 personas demo en `src/config/demo.config.js`, cada una con variante visual (avatar/mancha) y perfil de salud que alimenta el gating por perfil de los cuestionarios: **María** (34, `adulto_activo`), **Juan** (50, `adulto_activo`), **Rosa** (68, `mayor_asistido`) y **Sofía** (10, `menor_tutor`). El selector de perfil (badge flotante de demo) se rediseñó con una cuadrícula fluida que depende del ancho de pantalla: los 4 perfiles en línea cuando caben (2×2 en móvil).

**3. JSONs de instrumentos para renderizado automático.** Se generaron **a mano**, a partir del análisis de cada cuestionario, los 12 instrumentos del área **Bienestar Emocional** como módulos JS con el contrato `dh_forms` en `src/config/cuestionarios/`: `gad7.js`, `phq9.js`, `hads.js`, `cdi.js`, `gds.js`, `cth.js`, `edah.js`, `asrs.js`, `dts.js`, `spin.js`, `tas20.js` y `eag.js`. Cada JSON declara `id`/`key`, nombre, descripción, `target_age_group`, lista de preguntas con opciones de valor numérico y la tabla de interpretación proveniente de su `-review.md`. Caso notable: el **DTS** quedó fiel al contrato con 36 ítems (frecuencia = impares, gravedad = pares) y el `order` 1-36 respeta el drawio; la pregunta de gravedad es condicionada (solo aparece si la frecuencia respondida es distinta de "Nunca"). El catálogo `src/config/cuestionarios.config.js` conecta cada instrumento a su JSON por import dinámico y filtra por perfiles (p. ej. CDI/EDAH solo `menor_tutor`, GDS solo `mayor_asistido`, TAS-20 solo 18-59).

**4. Interfaz del flujo de cuestionarios.** Se unificó el lenguaje visual de las tres pantallas del flujo y del Inicio:
- **Runner** (`/cuestionarios/:area/:key`): hero con gradiente de la marca, métricas en vivo (reactivos, tiempo, respondidas), cuerpo en 2 columnas con panel de progreso sticky, opciones de respuesta custom (radio/checkbox), badge con el `order` del instrumento (fiel en el DTS) y gating frecuencia→gravedad verificado en vivo.
- **Lista principal** (`/cuestionarios`): pasó de maqueta con datos falsos corporativos a pantalla funcional con hero, métricas globales reales, 4 tarjetas de área clicables con progreso real, evaluación destacada, seguimiento por área y detalle de avance.
- **Página del área** (`/cuestionarios/emocional`): se reescribió con hero, métricas reales (instrumentos/completados/en progreso/avance), buscador, tabs en español, tarjetas con acrónimo del instrumento, badge de estado con color y CTA contextual (Iniciar/Continuar/Ver respuestas). Causa raíz corregida: `area.module.css` estaba **vacío (0 bytes)**, por lo que la página se renderizaba sin estilos (clases `undefined`).
- **Inicio / "Mis Cuestionarios"**: se creó el componente reutilizable `ListaCuestionarios` (lista en columna, scroll vertical de 5px/thin, selección de detalle) usado por las 5 vistas (Todos, Físico, Emocional, Social, Nutricional), eliminando la duplicación del patrón lista+detalle y los `@import` cruzados de CSS.
- Componentes de tarjetas hechos reutilizables con props reales: `TarjetaProgresoArea`, `TarjetaEvaluacion` (gráfica circular `conic-gradient`), `TrjEstadoCuestionario` (navegación con `Link`, corrigiendo el bug de `<a href>` fuera del `basename="/panel"`) y `TarjetaListadoAvance`.

**Estado de la actividad o tarea:** En desarrollo (Actualización continua)

**Avances de la actividad (si lo requiere):**
- Los 17 diagramas `.mmd` renderizan con `mmdc` y la auditoría de SVG (orden de `x` + `marker-end`) dio OK; tablas de interpretación en los 12 `*-review.md`.
- 4 perfiles demo configurados (`demo.config.js`) con selector rediseñado responsive.
- 12 JSONs de instrumentos creados en `src/config/cuestionarios/` y conectados por import dinámico en `cuestionarios.config.js`, con gating por perfil/edad.
- Motor de activación `unlock_if` implementado en `src/utils/progreso.js` (`isUnlocked`/`evalRule` con reglas `percent` y `answer` y combinadores `all`/`any`); hoy solo el follow-up de ejemplo "Hábitos de Ejercicio" del área Física lo usa.
- Flujo completo verificado en preview: lista → área → runner (GAD-7, PHQ-9, DTS con gating) y tabs del Inicio con el listado reutilizable. Build de producción verde.

**Próximos pasos:**
- **Implementar la lógica de activación de cuestionarios a partir de los activadores/triggers del drawio**: que un instrumento se libere según el resultado o respuestas de otro (p. ej. reglas `percent >=` o `answer includes` como las que ya soporta `evalRule`), aplicadas a los 12 instrumentos emocionales — hoy todos tienen `unlock_if: null`. Esto incluye revisar los flujos condicionales dentro de cada cuestionario (como frecuencia→gravedad del DTS) tal como están en el drawio.
- Poblar las áreas Físico, Social y Nutricional con instrumentos reales (hoy solo Emocional tiene los 12 JSONs; Físico conserva un placeholder `propuesta2.json`).
- Commit pendiente de los cambios demo/selector/cuestionarios (Conventional Commits, en inglés), según el STATUS de `docs/historia_clinica/questionnaires/`.

**Referencias:**
- Fuente de diagramas: `docs/historia_clinica/questionnaires/index.DEMO_quewstionnaire.drawio` → `mermaid/` (índice `index.md`, estado en `STATUS.md`)
- Perfiles demo: `src/config/demo.config.js` · `src/features/autenticacion/vistas/VistaSeleccionDemo.jsx`
- JSONs de instrumentos: `src/config/cuestionarios/*.js` · catálogo: `src/config/cuestionarios.config.js`
- Motor de activación: `src/utils/progreso.js` · documento de propuesta demo: `docs/features/demo.md`
