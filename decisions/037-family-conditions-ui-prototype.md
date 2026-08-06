# ADR 037: Prototipos UI de Antecedentes Familiares — Claves Compuestas, "¿Vive?" por Familiar y Export CSV

## Estado
Aceptado (prototipo de propuesta de UI — no es el diseño final)

## Contexto

El diagrama de flujo `Diagram_family-condition-matrix.drawio` define la lógica del módulo de **Antecedentes Heredofamiliares (AHF)**. Para validar el flujo y permitir su interpretación visual, se construyeron **tres vistas HTML autónomas** (sin backend) en `docs/historial_clinico/diagram_family_condition/`:

- `condition_first.html` — se navega por padecimientos y se marcan los familiares que lo han padecido.
- `family_first.html` — se navega por familiar (tabs) y se marcan sus padecimientos.
- `matrix.html` — matriz 2D: filas = padecimientos, columnas = familiares.

Las tres capturan los mismos datos (familiar × padecimiento, estado de vida y causa de fallecimiento), pero cada vista define su propio estado en memoria. El diseño debía resolver tres problemas reales del catálogo:

1. **Colisión del "Otro"**: cada categoría (4.1–4.13) termina en una opción `Otro`/`Otro (Especifique)`. Usar el nombre plano `Otro` como clave de estado haría que seleccionar "Otro" en una categoría marcara el "Otro" de todas las demás.
2. **Texto personalizado del "Otro"**: el usuario puede escribir un padecimiento libre. Sin clave por familiar, el texto de un miembro sobrescribiría el de otro.
3. **Duplicidad de "¿Vive?"**: preguntar "¿Vive?" por cada familiar en cada padecimiento genera redundancia y fricción.

## Decisión

### Claves de estado compuestas (anti-colisión)

Toda opción `Otro` se almacena con clave compuesta `catId||disease` (ej. `c4_1||Otro`). En matrix **todos** los padecimientos usan clave compuesta `catId||disease` para mantener un único mecanismo.

### Texto personalizado "Otro" — granularidad por vista

| Vista | Clave del texto "Otro" | Alcance |
|---|---|---|
| `condition_first.html` | `catId||disease` | Compartido **por categoría** (un solo input por categoría) |
| `family_first.html` | `catId||disease||fi` | **Por miembro** (`fi` = índice del familiar) |
| `matrix.html` | `catId||Otro||fi` | **Por coordenada** (celda = familiar × padecimiento) |

### Capitalización del texto libre en JS

El texto libre ("Otro" y causa de fallecimiento) se capitaliza **en JavaScript**, no con CSS `text-transform` (que no alteraría el valor exportado):

- `capFirst(s)` — en vivo (`oninput`): capitaliza palabras pero **no recorta** el espacio final para no impedir la escritura de palabras múltiples.
- `capSpec(s)` — al salir (`onblur`): recorta extremos y capitaliza cada palabra. Es el valor **realmente almacenado** y exportado.

### "¿Vive?" elevado al ámbito del familiar

Se responde **una vez por familiar**, no por padecimiento:

- `condition_first.html` y `family_first.html`: radios dentro de la tarjeta del familiar en el sidebar (`viveState[fi]`/`sidebar[fi].vive`); al marcar "No" aparece el campo de causa de fallecimiento.
- `matrix.html`: fila fija **"¿Aún vive?"** bajo la cabecera, con checkboxes **marcados por defecto** (viven). Al desmarcar un familiar aparece en esa celda un input de causa.

### Export CSV uniforme y transpuesto

Las tres vistas exportan el **mismo formato de datos** (fila `Padecimiento` como cabecera, columnas = familiares):

```
Padecimiento | Padre | Madre | Abuelo materno | ...
¿Aún vive?   |  Sí   |   No  |      Sí        | ...
Causa de muerte | Infarto | |                | ...
4.1 ...      |       |       |                | ...
Diabetes     |   X   |       |       X        | ...
```

- Filas: `¿Aún vive?` (`Sí`/`No`, vacío si no se respondió) → `Causa de muerte` → una fila separadora por categoría → una fila por padecimiento (`X`/vacío; en "Otro" el texto personalizado).
- Codificación UTF-8 **con BOM** (para que Excel renderice tildes/ñ) y escaping RFC 4180.
- Nombre de archivo genérico: `export_family_conditions_YYYYMMDD_HHMMSS.csv` (hora local). El sufijo fecha+hora ordena cronológicamente y evita colisiones; el nombre no revela la vista de origen porque el formato de datos es idéntico.

## Consecuencias

**Positivas:**
- Las tres vistas comparten un modelo de datos equivalente, verificable visualmente y exportable a un único formato CSV.
- El estado en memoria es explícito y comentado en cada archivo (los `.html` incluyen comentarios en inglés con el mapa clave→estado).
- La capitalización en JS garantiza que el dato exportado (ej. a Excel) ya lleve formato correcto.

**Negativas:**
- Son prototipos de propuesta de UI: el estado vive en memoria y se pierde al recargar; no hay persistencia ni backend.
- El almacenamiento del texto "Otro" difiere por vista (por categoría vs por miembro vs por coordenada), lo que exige leer el bloque de comentarios de cada archivo antes de modificarlo.
- La vista `condition_first.html` comparte el texto "Otro" por categoría: no permite textos distintos por familiar en un mismo "Otro".

## Actualización (2026-07-31): genograma interactivo

Posteriormente se añadieron dos versiones de un **árbol genealógico interactivo** — `family_tree.html` (Material You) y `family_tree_v2.html` (Light Glassmorphism) — en el mismo directorio, como cuarta/quinta representación de exploración del flujo. Mantienen las reglas de este ADR (claves compuestas para el "Otro", "¿Vive?" elevado al ámbito del familiar, capitalización del texto libre en JS y export CSV transpuesto uniforme) y añaden un panel lateral de captura por familiar, insignias de categoría con tooltip y líneas SVG conectoras. La granularidad del texto "Otro" es **por miembro** (`catId||disease||fi`), igual que en `family_first.html`. Ver [reporte 2026-07-31](../reports/2026-07-31_FEATURE_prototipo-arbol-genealogico-antecedentes-familiares.md).

## Referencias
- Diagrama fuente: `docs/historial_clinico/diagram_family_condition/Diagram_family-condition-matrix.drawio`
- Documentación de la propuesta: `docs/historial_clinico/diagram_family_condition/README.md`
- Cuestionarios de referencia: `family_first_matrix.md`, `condition_first_matrix.md`
