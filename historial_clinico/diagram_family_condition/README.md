# Diagrama Family Condition Matrix

## Archivos en este directorio

| Archivo | Tipo | Descripción |
|---|---|---|
| `Diagram_family-condition-matrix.drawio` | Diagrama Draw.io | Diagrama original con la lógica completa del wizard |
| `FAMILY_CONDITION_MATRIX.mmd` | Diagrama Mermaid | Flujo de decisión: familiar → categoría → enfermedad |
| `family_first_matrix.md` | Cuestionario markdown | Vista: familiar primero, luego enfermedades |
| `condition_first_matrix.md` | Cuestionario markdown | Vista: enfermedad primero, luego familiares |
| `condition_first.html` | Vista interactiva (autónoma) | Condición primero: se navega por padecimientos y se marcan los familiares |
| `family_first.html` | Vista interactiva (autónoma) | Familiar primero: tabs por miembro con categorías desplegables |
| `matrix.html` | Vista interactiva (autónoma) | Matriz 2D: filas = padecimientos, columnas = familiares |
| `family_tree.html` | Vista interactiva (autónoma) | Árbol genealógico interactivo (Material You): genograma visual con panel lateral |
| `family_tree_v2.html` | Vista interactiva (autónoma) | Árbol genealógico v2 (Light Glassmorphism): diseño claro con íconos vectoriales online (man, woman, elderly, person) |

## Vistas interactivas (HTML autónomos)

Las **cinco vistas** capturan los mismos datos y comparten las mismas reglas de captura:

- **"Otro"**: cada categoría termina en una opción `Otro` que despliega un input de texto libre con **capitalización automática** (`capFirst` al escribir, `capSpec` al salir). Las claves de estado son compuestas (`catId||disease[||fi]`) para evitar colisiones entre categorías y familiares.
- **"¿Vive actualmente?"**: respondido **una vez por familiar** (no por padecimiento), evitando redundancia. Si responde "No", aparece el campo de causa de fallecimiento.
- **Barra de acción superior**: botón **"Exportar CSV"** y **"Limpiar todo"** (con confirmación). En las vistas listadas, separada de los tabs de filtro; en el árbol, anclada en la barra superior.
- **Filtros**: búsqueda por texto (tabs de categorías "Todas + 4.1–4.13" en las vistas listadas; en el árbol, la búsqueda vive dentro del panel lateral).
- Fila **"¿Aún vive?"** en matrix: los checkboxes están **marcados por defecto** (viven); al desmarcar uno aparece el input de causa en esa celda.

### Export CSV

Las cinco vistas exportan el **mismo formato transpuesto** (por eso el nombre del archivo no revela la vista de origen):

- **Columnas**: los 6 familiares.
- **Filas**: `¿Aún vive?` (`Sí`/`No`, vacío si no se respondió) → `Causa de muerte` → una fila separadora por categoría → una fila por padecimiento.
- **Celdas de padecimiento**: `X` si el familiar lo padece, vacío si no; en las filas `Otro` va el texto personalizado.
- **Codificación**: UTF-8 con BOM (para que Excel renderice tildes/ñ) y escaping RFC 4180.
- **Nombre de archivo**: `export_family_conditions_YYYYMMDD_HHMMSS.csv` (hora local). El sufijo fecha+hora ordena cronológicamente los archivos y evita colisiones.

## Reglas de usabilidad

### Loop "¿Otro familiar?" eliminado

El diagrama original incluye el paso 5.0 "¿Desea completar los antecedentes de otro familiar?" con loop. En UI esto se resuelve mediante un botón **"Agregar familiar"** (+), eliminando la necesidad de preguntar explícitamente.

### Loop "¿Otro padecimiento?" eliminado

Mismo criterio: el usuario puede seleccionar múltiples enfermedades dentro de cada categoría mediante checkboxes, sin necesidad de un paso intermedio de confirmación.

### Categorías como separadores

Las 13 categorías (4.1–4.13) se conservan como **separadores visuales** (h2/h3) para mantener la organización por sistemas del cuerpo. Las enfermedades se listan como checkboxes dentro de cada categoría.

### Duplicidad de "¿Vive?" en condition-first

En el flujo `condition_first_matrix.md` el usuario navega por padecimientos y selecciona qué familiares lo han padecido. Si se preguntara "¿Vive?" por cada familiar en cada padecimiento, se generaría redundancia:

1. Usuario selecciona "Diabetes" → marca "Padre" → se pregunta "¿Padre vive?"
2. Usuario selecciona "Hipertensión" → vuelve a marcar "Padre" → se preguntaría "¿Padre vive?" de nuevo

**Solución implementada:** La pregunta "¿Vive?" está elevada al ámbito del familiar, no del padecimiento. Se responde **una vez por familiar** y el estado se conserva durante la sesión (en condition-first y family-first dentro de la tarjeta del familiar en el sidebar; en matrix como fila fija "¿Aún vive?" bajo la cabecera; en el árbol, dentro del panel lateral del familiar).

### Mapa de almacenamiento por vista

Cada vista define su estado en memoria; el esquema exacto está comentado en el encabezado del `<script>` de cada archivo. Resumen:

| Vista | Clave de padecimiento | Clave del texto "Otro" | Estado de "¿Vive?" |
|---|---|---|---|
| `condition_first.html` | nombre plano; `catId\|\|disease` solo para "Otro" | `otherSpecs[catId\|\|disease]` — **compartido por categoría** | `sidebar[fi].vive` (boolean o null) + `sidebar[fi].cause` |
| `family_first.html` | nombre plano; `catId\|\|disease` solo para "Otro" | `otherSpecs[catId\|\|disease\|\|fi]` — **por miembro** | `viveState[fi] = { vive, cause }` |
| `matrix.html` | `catId\|\|disease` **para todos** (anti-colisión) | `otherSpecs[catId\|\|Otro\|\|fi]` — **por coordenada** | `viveState[fi] = { dead, cause }` (fila "¿Aún vive?" marcada por defecto) |
| `family_tree.html` | nombre plano; `catId\|\|disease` solo para "Otro" | `otherSpecs[catId\|\|disease\|\|fi]` — **por miembro** | `viveState[fi] = { vive, cause }` |
| `family_tree_v2.html` | nombre plano; `catId\|\|disease` solo para "Otro" | `otherSpecs[catId\|\|disease\|\|fi]` — **por miembro** | `viveState[fi] = { vive, cause }` |

Diferencias clave a recordar antes de modificar:
- El texto "Otro" **no** se almacena igual en todas las vistas (por categoría vs por miembro vs por coordenada).
- En matrix **todas** las claves son compuestas; en las demás solo las de "Otro".
- El árbol (`family_tree.html` / `family_tree_v2.html`) guarda el texto "Otro" **por miembro** (igual que `family_first`) y usa los mismos acordeones del catálogo dentro de un panel lateral.
- La capitalización del texto libre se hace en JS (`capFirst` en vivo, `capSpec` al salir), no con CSS, para que el valor exportado ya llegue formateado.

## Origen de los datos

Este diagrama fue extraído del módulo de **Antecedentes Heredofamiliares (AHF)** de la Historia Clínica Digital. Los códigos entre paréntesis corresponden a la clasificación **CIE-11**.
