# Diagrams — Fuente de la verdad para el MVP

Concentrado de diagramas `.drawio` que definen el **Producto Mínimo Viable (MVP)**.
Esta es la referencia canónica de la lógica de negocio de la historia clínica,
los cuestionarios clínicos y su lógica de activación/derivación.

## Convención de carpetas

Cada dominio separa sus artefactos por **formato**:

| Carpeta | Contenido |
|---|---|
| `source/` | Original binario: `.drawio` (+ algoritmos `.pseint`). |
| `flows/` | Conversión legible a Mermaid (`.mmd`), tab por tab. |
| `reviews/` | Tabla derivada `Puntuacion \| Interpretacion` (`-review.md`). |
| `activation/` | Rúbricas de activación/derivación (anexos C y D). |

Transversal:

| Carpeta | Contenido |
|---|---|
| `conventions/` | Guía de conversión drawio → Mermaid (`SKILL_DRAWIO_MERMAID.md`). |
| `catalog/` | Catálogo de instrumentos con metadata (`instruments.csv`). |
| `schemas/` | Contratos de referencia (motor de cuestionarios). |

## Estructura

| Dominio | Drawio (`source/`) | Contenido (páginas/tabs) |
|---|---|---|
| `0_HISTORIA_CLINICA/` | `0_DEMO_HISTORIA_CLINICA.drawio` | A Registro, B Antecedentes heredofamiliares, C APNP, D Antecedentes PP, E Padecimiento actual, ANEXO C, ANEXO D |
| `1_CUESTIONARIO_MENTAL/` | `1_DEMO_CUESTIONARIOS_MENTAL.drawio` | HADS, CDI, GDS, PHQ, GAD, PSS |
| `2_CUESTIONARIO_SOCIAL/` | `2_DEMO_CUESTIONARIOS_SOCIAL.drawio` | CRAFFT (tamizaje de alcohol/drogas, partes A y B) |
| `3_CUESTIONARIO_FISICO/` | `3_DEMO_CUESTIONARIOS_FISICO.drawio` | IPAQ |

## Conversión a Mermaid

Cada drawio se convirtió **tab por tab** a diagramas **Mermaid** (`.mmd`) en
`flows/`, siguiendo la convención del legacy (un nodo por ítem/pregunta, cadena
secuencial), y un `reviews/-review.md` con la tabla
`Puntuación | Interpretación` para los instrumentos psicométricos.

| Carpeta | Índice | `flows/` | `reviews/` | `activation/` |
|---|---|---|---|---|
| `0_HISTORIA_CLINICA/` | `index.md` | `registro`, `antecedentes_heredofamiliares`, `apnp`, `antecedentes_pp`, `padecimiento_actual` | — | `anexo_c`, `anexo_d` |
| `1_CUESTIONARIO_MENTAL/` | `index.md` | `hads`, `cdi`, `gds`, `phq`, `gad`, `pss` | `hads`, `cdi`, `gds`, `phq`, `gad`, `pss` | — |
| `2_CUESTIONARIO_SOCIAL/` | `index.md` | `crafft` | `crafft` | — |
| `3_CUESTIONARIO_FISICO/` | `index.md` | `ipaq` | `ipaq` | — |

Los formularios estructurales de la historia clínica (A-E y anexos) no llevan
`-review.md` (solo los instrumentos psicométricos lo llevan).

## Cómo leer esto

### Historia clínica (`0_HISTORIA_CLINICA/`)

- Cada **tab** del drawio `0_DEMO_HISTORIA_CLINICA` es una **sección** del
  expediente. Funciona como un formulario/cuestionario de varias secciones
  habilitadas para edición por defecto mientras no estén completas.
- Incluye además los **anexos de la lógica de activación** de cada
  cuestionario (`activation/anexo_c.mmd` y `activation/anexo_d.mmd`): la
  condición que habilita o deriva al cuestionario correspondiente.

### Cuestionarios (`1_`, `2_`, `3_`)

- Los cuestionarios se separaron **por categoría** para no cargar un único
  drawio demasiado pesado y para que sea más fácil de entender.
- Cada cuestionario tiene su **puntuación** y la **interpretación de los
  resultados**.
- **Sobre CRAFFT (categoría social):** en realidad el CRAFFT pertenece a
  **dos categorías** (`Bienestar físico` **y** `Bienestar social`). Como el
  MVP necesitaba incluir **al menos un instrumento de la categoría social**,
  el CRAFFT se dibujó dentro del drawio `2_CUESTIONARIO_SOCIAL`. **Nota**: en
  la práctica, durante la programación del MVP, el CRAFFT debe representarse
  **obligatoriamente en ambas categorías** (física y social), no solo en una.

## Catálogo de instrumentos (CSV)

El archivo `catalog/instruments.csv` es el **catálogo con metadata** de los
cuestionarios. Cada registro describe un instrumento con:

- `Clave` — sigla/código del instrumento.
- `Nombre de la herramienta` — nombre completo.
- `Instrucciones` / `Descripción` / `¿Qué evalúa?` — propósito y contenido.
- `Referencias` — fuente/bibliografía.
- `Grupo etario` y `Población específica` — a quién se aplica.
- `Tiempo aplicativo` y `No. de ítems` — duración y extensión.
- `CIE-11` — código(s) de clasificación.
- `LS` — **categoría de bienestar** asignada (ej. `Bienestar mental`,
  `Bienestar físico`, `Bienestar social`, o combinaciones como
  `Bienestar físico y social`).

La columna `LS` es la que determina a qué **categoría** pertenece cada
cuestionario y, por tanto, en qué drawio/carpeta de la familia debe incluirse
(`1_` mental, `2_` social, `3_` físico), **representándolo en todas las
categorías** que le asigne esta columna.

## Estado

| Drawio | Estado |
|---|---|
| `0_HISTORIA_CLINICA` | ✅ Completo (7 páginas) |
| `1_CUESTIONARIO_MENTAL` | ✅ Completo (6 páginas: HADS, CDI, GDS, PHQ, GAD, PSS) |
| `2_CUESTIONARIO_SOCIAL` | ✅ CRAFFT (partes A y B + interpretación) |
| `3_CUESTIONARIO_FISICO` | 🟡 Parcial (solo IPAQ) |

> Nota: la conversión a Mermaid de la versión legacy monolítica (17 páginas)
> vive en `reference_projects/reference_frontend_app_legacy/lsinciosesionweb/docs/historia_clinica/questionnaires/`.

## Pendientes

- Ninguno.
