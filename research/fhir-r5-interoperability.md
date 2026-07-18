---
type: research
id: fhir-r5-interoperability
title: "Exploracion del estandar HL7 FHIR R5 para interoperabilidad clinica"
category: interoperability
status: concluded
created: "2026-05-27"
last_updated: "2026-07-18"
related:
  - ../reports/2026-05-27_ARCH_exploracion-estandar-interoperabilidad-fhir.md
  - ../reports/2026-05-29_ARCH_propuesta-mapeo-nom024-fhir.md
  - ../decisions/036-fhir-r5-adoption.md
  - ../tasks/TASK-014-dh-fhir-shared-schemas/README.md
---

# Exploracion del estandar HL7 FHIR R5 para interoperabilidad clinica

## Proposito

Investigar y seleccionar un estandar internacional para el modelado de datos clinicos en el ecosistema Digital Hospital, evitando modelos propietarios que dificulten la interoperabilidad con otros sistemas de salud.

## Opciones Evaluadas

| Opcion | Pros | Contras |
|---|---|---|
| Modelos propios por servicio | Control total, rapido inicialmente | Fragmentacion, duplicacion, sin interoperabilidad |
| FHIR R4 | Maduro, amplia adopcion | Recursos y bindings ligeramente diferentes a R5 |
| FHIR R5 | Version mas reciente, bindings refinados, alineado con la vision del proyecto | Menor cantidad de implementaciones de referencia |
| OpenEHR | Enfoque en arquetipos clinicos | Curva de aprendizaje alta, menor adopcion en la region |

## Conclusiones

- **HL7 FHIR R5** es el estandar mas adecuado para Digital Hospital.
- Proporciona estructuras modulares para pacientes, profesionales, organizaciones, observaciones, condiciones, medicacion, documentos y encuentros.
- Facilita la interoperabilidad con laboratorios, clinicas externas y sistemas gubernamentales.
- La seleccion de LOINC para `Observation` y la propuesta de mapeo NOM-024 a FHIR fueron insumos clave.

## Recursos Nucleares Identificados

- `Patient` — datos demograficos, contactos, sexo y estado civil.
- `Practitioner` — personal de salud, especialidades y cedulas.
- `Organization` — unidades administrativas y aseguradoras.
- `Observation` — mediciones clinicas, signos vitales y resultados de laboratorio.
- `Questionnaire` / `QuestionnaireResponse` — cuestionarios clinicos dinamicos.

## Referencias

- [Reporte: Exploracion del estandar FHIR](../reports/2026-05-27_ARCH_exploracion-estandar-interoperabilidad-fhir.md)
- [Reporte: Propuesta de mapeo NOM-024 a FHIR](../reports/2026-05-29_ARCH_propuesta-mapeo-nom024-fhir.md)
- [ADR 036: Decision formal de adopcion de FHIR R5](../decisions/036-fhir-r5-adoption.md)
- [HL7 FHIR R5 Specification](https://hl7.org/fhir/R5/)
