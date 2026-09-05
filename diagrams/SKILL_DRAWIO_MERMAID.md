# Skill — Conversión drawio → Mermaid

Guía para **interpretar y convertir** diagramas `.drawio` a **Mermaid**
(`.mmd`), extraída del legacy (`reference_frontend_app_legacy`). Aplica a
cualquier carpeta de este workspace que tenga drawios (p. ej. `docs/diagrams/`).

## Principio general

- Conversión **tab por tab**: cada `diagram` (página) dentro de un `.drawio`
  produce **un** archivo `.mmd` por separado.
- Se escribe **a mano**, interpretando el contenido del drawio (no se usa
  script generador). Python se usa **solo en modo lectura** para inspeccionar
  celdas `<mxCell>`, valores y aristas.
- **Ser fiel al drawio**: valores y conexiones se leen del XML real, no se
  asumen del estándar clínico. Si el drawio contradice el estándar, se sigue
  el drawio y se anota la discrepancia en `%%` y/o `-review.md`.

## Estructura del drawio (cómo leerlo)

- `<diagram name="...">` = cada página/tab. El `name` da el nombre del tab.
- Dentro de `mxGraphModel > root > mxCell`:
  - `vertex="1"` y `parent="1"` = nodos del nivel raíz (con `mxGeometry x/y`
    para deducir el orden visual y `value` con el texto, a veces HTML).
  - `edge="1"` = aristas; `source`/`target` conectan nodos por `id`.
  - `parent` distinto de `"1"` = celdas anidadas (filas de tablas `childLayout`,
    bloques de resultados). Su `value` puede contener un `mxGraphModel` embebido
    (blob `%3C...`): ignorar esos blobs, no son texto de contenido.
- Los bloques de "Resultados" (puntuación/interpretación) suelen estar en
  celdas anidadas (tabla) → son el material del `-review.md`.

## Convención de nombres

- Diagrama: `{tab_name}.mmd` en `snake_case` (p. ej. `cuestionario_phq.mmd`,
  `padecimiento_actual.mmd`, `anexo_c.mmd`, `a.mmd`).
- Tabla de interpretación: `{tab_name}-review.md` (mismo `snake_case` +
  sufijo `-review`). **Solo** los instrumentos psicométricos llevan
  `-review.md`; los formularios estructurales no.
- Índice por familia: `index.md` que enlista los `.mmd` generados.

## Patrón aprobado (cuestionarios psicométricos)

- **Un nodo por ítem** con el enunciado + sus opciones numeradas con valor,
  p. ej. `A.1.1 Nunca (0)`, `A.1.2 De vez en cuando (1)`, ...
- La cadena es **secuencial** (no un árbol paralelo): una flecha por línea para
  que la conexión entre ítems quede explícita
  (`A.1 --> D.1`, `D.1 --> A.2`, ...).
- Un `{tab}-review.md` por cuestionario con tabla Markdown
  `Puntuación | Interpretación` (ver abajo).
- Notas de escalas invertidas / ítems invertidos van en el bloque `%%` del `.mmd`.

## Patrón (formularios estructurales)

- `flowchart TD` con un nodo por campo/pregunta y sus opciones numeradas en el
  mismo nodo (ver `a.mmd`, `b.mmd`, `c.mmd` del legacy).
- Conservar los lazos de repetición ("registrar otra lesión / cirugía /
  hospitalización") explícitos.
- Los `TODO` del original ("FALTA PONER GRUPO ÉTNICO") se conservan señalados.

## Rúbricas de derivación / activación (anexos)

- Mapeo `condición → cuestionario habilitado`:
  - Tablas de mapeo → `flowchart LR`.
  - Flujos de derivación según respuestas → `flowchart TD`.

## Tablas de interpretación (`-review.md`)

```markdown
| Puntuacion | Interpretacion |
|---|---|
| 0-7 | Normalidad |
| 8-10 | Probable ansiedad |
| 11-21 | Caso de ansiedad |
```

Convención: fila de cabecera `| cabecera |`, separador `|---|---|`, filas
`| valor | texto |`. Usar exactamente la tabla tal como aparece en el drawio
(y, si el drawio omite bandas numéricas, marcarlo como referencia estándar).

## Reglas de formato del `.mmd`

- Declarar `flowchart TD` (o `LR`) **primero**, y los comentarios `%%` después.
  Los `%%` **antes** del `flowchart` rompen el parseo de Mermaid.
- Los textos largos del drawio se conservan completos como comentarios `%%`
  cuando se acortan para legibilidad del render.
- Anotar en `%%` las raridades/correcciones: rotulaciones erróneas del drawio,
  ítems duplicados, ítems invertidos, textos truncados, etc.

## Validación

Renderizar cada `.mmd` con mermaid-cli y auditar:

```bash
npx --yes @mermaid-js/mermaid-cli@10 -p <puppeteer-config-no-sandbox.json> -i X.mmd -o X.svg
```

Puppeteer config (no-sandbox):

```json
{"args":["--no-sandbox","--disable-setuid-sandbox"]}
```

**Auditoría visual del orden** (para flujos secuenciales):
- Renderizar a SVG y leer las coordenadas `x` de los nodos (cada nodo trae
  `transform="translate(x,y)"`).
- El orden de `x` debe coincidir con la cadena esperada
  (`A.1 < D.1 < A.2 < ...`).
- El número de flechas (`marker-end`) debe ser igual al número de conexiones
  de la cadena.
- No fiarse solo del conteo de ítems: verificar la cadena flecha-por-flecha y
  vigilar flujos condicionales y rótulos duplicados que pierden conexiones.

## Errores comunes ya resueltos (referencia)

- Comentarios `%%` antes de `flowchart` → moverlos después.
- Rotulaciones erróneas en el drawio (p. ej. opciones del ítem A.2 como
  "3.2/3.3/3.4", opción "4.1" donde debía ser "D.2.1"): corregir y anotar en `%%`.
- Ítems duplicados o faltantes (DTS ítem 13 duplica el 12; TAS-20 falta el
  ítem 20; EAG 7 y 8 duplican enunciado): seguir el drawio y anotar.
- Ítems invertidos respecto al estándar (CDI ítem 25): seguir el drawio, anotar
  en `%%` y `-review.md`.
- Doble rótulo en opciones (CDI ítem 5 "5.1"; ASRS ítem 15 "15.1"): anotar.
- Nodos con `value` = blob `mxGraphModel` embebido (tablas anidadas): ignorar.
