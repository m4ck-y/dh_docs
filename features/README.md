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

| Módulo | Descripción | Estado |
|---|---|---|
| [`questionnaires/`](./questionnaires/) | Catálogo de cuestionarios: definición del instrumento y ejecución de respuestas | En definición |
