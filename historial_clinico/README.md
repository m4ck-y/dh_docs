# historial_clinico

Documentación del flujo y estructura del historial clínico del sistema.

Cada sección del historial clínico tiene su origen en un diagrama de flujo draw.io. Al documentar una sección se generan **dos archivos con el mismo nombre base**:

| Archivo | Descripción |
|---|---|
| `<SECCIÓN>.md` | Estructura en markdown del diagrama: secciones, preguntas, opciones y subrutas — ignorando la lógica de flujo |
| `<SECCIÓN>.MAPPER.md` | Mapeo de cada campo hacia su `schema.entidad.columna` en PostgreSQL, con indicadores de cobertura (🟢 modelado / 🟡 parcial / 🔴 pendiente) |

## Archivos

| Archivo | Descripción |
|---|---|
| [A.REGISTRO.md](./A.REGISTRO.md) | Estructura de la sección "A. Registro": datos de tutor/responsable y datos generales del usuario |
| [A.REGISTRO.MAPPER.md](./A.REGISTRO.MAPPER.md) | Mapeo DB de la sección "A. Registro" |
