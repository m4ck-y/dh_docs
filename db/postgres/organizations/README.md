# Schema: Organizations

## Propósito
Este esquema agrupa toda la estructura corporativa, geográfica y laboral del sistema Digital Hospital. Define cómo se organizan las empresas (`company`), sus ubicaciones físicas (`location`) y su capital humano (`employee`).

## Estructura de Datos
- **Jerarquía Corporativa**: Soporta industrias, sub-industrias y una estructura de empresas madre/hijas.
- **Geolocalización**: Detalle exhaustivo de ubicaciones físicas vinculadas a las compañías.
- **Servicios**: Catálogo de servicios ofrecidos por las organizaciones.
- **Gestión Laboral**: Relación entre personas físicas y entidades legales, incluyendo detalles específicos para legislaciones locales (ej: `employee_mexican`).

## Diagramas
- **ERD Principal**: [ERD.mmd](./ERD.mmd)

## Diccionario de Datos
Los detalles técnicos de cada entidad se encuentran en el directorio [data_dictionary](./data_dictionary/):
- [Company](./data_dictionary/company.md)
- [Employee](./data_dictionary/employee.md)
- [Location](./data_dictionary/location.md)
- [Service](./data_dictionary/service.md)

## Relaciones Externas
- **IAM**: Los empleados se vinculan a roles definidos en el esquema de identidad.
- **People**: La entidad `employee` es una extensión de la entidad `person`.
