**Proyecto o Apartado:** Historia Clínica / Antecedentes Heredo-Familiares (AHF)

**Título de la actividad o tarea:** Prototipo de árbol genealógico (genograma interactivo) para antecedentes heredofamiliares — v1 Material You y v2 Light Glassmorphism

**Descripción de la actividad o tarea:**
Partiendo del mismo diagrama fuente `Diagram_family-condition-matrix.drawio` que define la lógica del módulo de **Antecedentes Heredo-Familiares (AHF)**, y continuando con la exploración de UI iniciada en el reporte del 2026-07-29 (vistas `condition_first`, `family_first` y `matrix`), se decidió construir una **cuarta representación del flujo y del llenado de datos**, más interactiva que las anteriores: un **árbol genealógico interactivo** (genograma) que representa visualmente a los 6 familiares en tres niveles jerárquicos —abuelos, padres y paciente— en lugar de recorrer el catálogo en listas o matrices.

Al igual que las tres vistas previas, esta representación es una **propuesta de UI** (sin backend, estado en memoria), no el diseño final: su objetivo es evaluar si la navegación por familiar mediante un genograma reduce la fricción de captura frente a los flujos listados, antes de comprometer la ruta definitiva.

El prototipo materializa las decisiones de captura ya establecidas (claves compuestas anti-colisión del "Otro", pregunta "¿Vive?" una sola vez por familiar, capitalización del texto libre en JS y exportación CSV transpuesta uniforme) en un modelo de interacción distinto: la tarjeta de cada familiar refleja su estado de vida y los padecimientos registrados mediante insignias de categoría con tooltips, y al tocarla se despliega un panel lateral para editar sus antecedentes.

### Estructura del árbol

El lienzo del árbol se organiza en tres niveles:

- **Abuelos** (nivel superior): cuatro tarjetas (abuelo/abuela paterno y materno), agrupadas por rama paterna y materna.
- **Padres** (nivel medio): tarjeta de Padre y Madre.
- **Paciente** (nivel inferior): nodo de referencia no editable.

Las tarjetas se conectan entre niveles mediante **líneas SVG calculadas dinámicamente en JavaScript** (`drawConnectorLines`), que se recalculan al redimensionar la ventana. Cada tarjeta muestra:

- **Avatar con ícono Material Symbols** (`elderly`, `elderly_woman`, `man`, `woman`, `person`).
- **Punto de estado vital** (`alive`/`deceased`/`unknown`) con color indicador.
- **Insignias de categoría** por cada padecimiento marcado del familiar, con tooltip del nombre de la categoría (4.1–4.13).
- **Contador global**: familiares registrados (`N / 6`) y total de padecimientos.

### Panel lateral de captura

Al tocar una tarjeta se abre un **drawer lateral** que concentra la captura de un familiar:

- **Estado vital**: toggle segmentado "¿Vive actualmente?" (Sí, vive / No, falleció). Si falleció, aparece el campo de causa de fallecimiento.
- **Catálogo CIE-11**: las 13 categorías (4.1–4.13) en acordeones colapsables con buscador por texto, checkboxes por padecimiento y la opción `Otro`/`Otro (Especifique)` con texto libre capitalizado en JS (`capFirst` en vivo, `capSpec` al salir).

### V1 y V2: mismo modelo, dos lenguajes visuales

Se generaron dos versiones del prototipo que comparten el **mismo modelo de datos en memoria** (`registered` con claves compuestas `catId||disease`, `otherSpecs` para el texto del "Otro" y `viveState[fi] = { vive, cause }`):

- `family_tree.html` (v1): lenguaje visual **Material You** con tarjetas `node-card`.
- `family_tree_v2.html` (v2): rediseño **Light Glassmorphism** con paleta clara, orbes ambientales difuminados, tarjetas de vidrio, tipografía Plus Jakarta Sans y avatares con íconos Material Symbols cargados por CDN.

Ambas conservan la **barra de acciones superior** (Exportar CSV / Limpiar todo con confirmación), el mismo formato de exportación CSV transpuesto (UTF-8 con BOM, escaping RFC 4180, nombre `export_family_conditions_YYYYMMDD_HHMMSS.csv`) y las reglas de usabilidad del ADR 037 (loops de confirmación eliminados, "¿Vive?" elevado al ámbito del familiar).

### Referencias

- Diagrama fuente: `docs/historial_clinico/diagram_family_condition/Diagram_family-condition-matrix.drawio`
- Prototipos: `docs/historial_clinico/diagram_family_condition/family_tree.html`, `family_tree_v2.html`
- Documentación de la propuesta: `docs/historial_clinico/diagram_family_condition/README.md`
- Vistas previas: `condition_first.html`, `family_first.html`, `matrix.html`
- [ADR 037 — Prototipos UI de Antecedentes Familiares](../decisions/037-family-conditions-ui-prototype.md)
- Reporte previo: [2026-07-29 — Prototipo de UI multi-vista](2026-07-29_ARCH_prototipo-ui-antecedentes-familiares.md)

**Estado de la actividad o tarea:** Concluido (fase de exploración / prototipo)

**Avances de la actividad (si lo requiere):**
- Construido el genograma interactivo en dos versiones visuales (`family_tree.html` Material You y `family_tree_v2.html` Light Glassmorphism) con los 6 familiares en tres niveles jerárquicos y nodo de paciente como referencia.
- Implementada la captura por panel lateral: estado vital con causa de fallecimiento y catálogo CIE-11 en acordeones con buscador, reutilizando las reglas del ADR 037 (claves compuestas, "¿Vive?" por familiar, capitalización en JS).
- Añadida retroalimentación visual en las tarjetas: punto de estado vital, insignias de categoría con tooltip, resaltado de miembros registrados y líneas SVG conectoras recalculadas en `resize`.
- Mantenida la uniformidad con las vistas previas: mismo formato CSV transpuesto, botón "Limpiar todo" con modal de confirmación y estadísticas de avance.
- Actualizado el `README.md` del directorio con los dos nuevos archivos del árbol genealógico.
- Los prototipos se entregan como propuesta de UI: el estado vive en memoria y se pierde al recargar; no hay backend ni persistencia.
- Próximo paso: validar con stakeholders cuál de las cuatro direcciones (condición-primero, familiar-primero, matriz o árbol) es la ruta de captura definitiva, y articular el modelo de persistencia con TASK-015 (FHIR R5 híbrido PostgreSQL + MongoDB).
