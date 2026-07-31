# Clinical History Documentation

Technical and functional specifications for the Digital Hospital Clinical History module.

## Directory Structure
- [diagram/](./diagram/): Machine-readable Mermaid (.mmd) workflow diagrams.
- [diagram_family_condition/](./diagram_family_condition/): **Prototipo UI (propuesta)** de Antecedentes Familiares derivado de la interpretación del diagrama `Diagram_family-condition-matrix.drawio`.
- `*.md`: Structural breakdown of forms (questions, options, sub-routes).
- `*.MAPPER.md`: Database mapping (PostgreSQL) for each clinical field.

## Documentation Files
- [A.REGISTRO.md](./A.REGISTRO.md): Registration form structure (Tutor & General Data).
- [A.REGISTRO.MAPPER.md](./A.REGISTRO.MAPPER.md): Database mapping for Registration section.

## Prototipos UI de Antecedentes Familiares

> **Estado: prototipo de propuesta de UI, NO el diseño final.** Sirve para entender y validar el flujo derivado de la interpretación del diagrama de flujo fuente. Ver [README.md](./diagram_family_condition/README.md) y [ADR 037](../decisions/037-family-conditions-ui-prototype.md).

El directorio contiene tres vistas HTML autónomas (sin backend) que capturan los mismos datos:

- `condition_first.html` — padecimiento primero: se navega por enfermedades y se marcan los familiares.
- `family_first.html` — familiar primero: tabs por miembro con categorías desplegables.
- `matrix.html` — matriz 2D: filas = padecimientos, columnas = familiares.

Cada vista exporta el **mismo formato CSV** (`export_family_conditions_YYYYMMDD_HHMMSS.csv`).

## Source of Truth
The [diagram/README.md](./diagram/README.md) contains the index of all clinical workflows (A to I) and system logic annexes. These diagrams serve as the definitive specification for implementation.
