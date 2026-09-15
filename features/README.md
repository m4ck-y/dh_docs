# Especificaciones de Módulos (features/)

Especificaciones de producto por módulo. Cada submódulo documenta su dominio,
su modelo de datos (ERDs, diagramas de clases, DDL) y sus decisiones.

## Estructura

- Una carpeta por módulo (`kebab-case` o nombre del dominio).
- Cada módulo tiene un `README.md` como índice, con su estado y pendientes.
- Las capas internas del módulo (p. ej. definición vs ejecución) se separan en
  subcarpetas con su propio `README.md`.
- Los diagramas Mermaid (`.mmd`) y ejemplos de payload (`.jsonc`) viven en la
  capa a la que pertenecen.
- El DDL consolidado del módulo (`schema.sql`) vive en la raíz del módulo.

## Módulos

| Nº | Módulo | Descripción | Depende de | Estado |
|---|---|---|---|---|
| 1 | [`questionnaires/`](./questionnaires/) | Motor + catálogo de formularios: definición del instrumento, ejecución de respuestas y banco (instrumentos e historia clínica vía `kind`). | — | En definición |
| 2 | [`clinical_history/`](./clinical_history/) | Dominio de la historia clínica: secciones A-E, mappers a DB y propuestas UI. | `questionnaires` | Propuesta |

> La numeración marca el orden base → consumidor (`clinical_history` se almacena
> con el modelo de `questionnaires`). Las carpetas **no** llevan prefijo; la
> dependencia se declara aquí.
