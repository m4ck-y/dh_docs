# PostgreSQL Schemas

Cada carpeta representa un schema de PostgreSQL.

| Schema | Descripcion |
|--------|-----------|
| care | Relaciones de cuidado (responsable/cuidado) |
| catalog | Catalogos (paises, estados, municipios, colonias, idiomas, religiones, etc) |
| expedient | Documentos e identificadores |
| health_profile | Perfil biologico y clinico (sexo biologico, tipo de sangre, alergias, condiciones cronicas) |
| people | Datos demograficos y contacto |
| public | Tablas publicas sin schema especifico |

## Convenciones

- Cada carpeta = 1 schema de PostgreSQL
- `erd.mmd` = Diagrama ERD (tablas)
- `views.sql` = Vistas del schema (futuro)
- Enums como bloques standalone con prefijo `E`