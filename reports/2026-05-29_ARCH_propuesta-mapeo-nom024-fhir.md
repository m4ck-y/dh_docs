**Proyecto o Apartado:** Clinical Architecture / Interoperabilidad / NOM-024 / HL7 FHIR

**Título de la actividad o tarea:** Propuesta de Mapeo de Datos entre NOM-024-SSA3-2012 y HL7 FHIR

**Descripción de la actividad o tarea:**
En el desarrollo de la plataforma, es mandatorio unificar el estándar clínico nacional mexicano (NOM-024-SSA3-2012 para Consulta Externa y el subsistema SIS) con el estándar global HL7 FHIR. Para resolver la brecha entre la terminología local y los sistemas internacionales de intercambio, se estructuró una propuesta de mapeo unificado de interoperabilidad. Como caso de estudio y ejemplo concreto para esta alineación, se documenta la homologación de la identidad de género del paciente (`genero`) vinculando los códigos oficiales de la Secretaría de Salud (NOM-024) con los conceptos clínicos codificados de SNOMED CT en HL7 FHIR.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Elaboración de la matriz completa de traducción semántica entre el diccionario de datos oficial GIIS-B015-04-11 (NOM-024) y las especificaciones de terminologías de HL7 FHIR.
- Resolución de fallbacks: mapeo de la ausencia de opción de rechazo ("declined") en el catálogo oficial mexicano.

---

# **NOM-024**

**Source:** http://www.dgis.salud.gob.mx/contenidos/intercambio/gconsulta_externa_gobmx.html

**Section:** `GIIS-B015-04-11.DATOS DEL PACIENTE.genero`

**Description:** Identidad de género del paciente o atributos sociales aprendidos o adoptados por la persona.

**Data type:** `number`

**Cardinalidad:** Obligatorio

| Display | Value |
| --- | --- |
| NO ESPECIFICADO | 0 |
| MASCULINO | 1 |
| FEMENINO | 2 |
| TRANSGÉNERO | 3 |
| TRANSEXUAL | 4 |
| TRAVESTI | 5 |
| INTERSEXUAL | 6 |
| OTRO | 88 |

---

# HL7.FHIR

**Source:** https://terminology.hl7.org/5.2.0/ValueSet-gender-identity.html

| Display | Value | System |
| --- | --- | --- |
| Female gender identity | 446141000124107 | http://snomed.info/sct |
| Male gender identity | 446151000124109 | http://snomed.info/sct |
| Non-binary gender identity | 33791000087105 | http://snomed.info/sct |
| Asked But Declined | asked-declined | http://terminology.hl7.org/CodeSystem/data-absent-reason |
| Unknown | UNK | http://terminology.hl7.org/CodeSystem/v3-NullFlavor |

---

## Mapeo Unificado de Interoperabilidad (Libersalus / NOM-024 / HL7 FHIR)

Mapeo para homologar los valores de identidad de género del paciente entre los sistemas internos, los requerimientos de la NOM-024 y las terminologías de HL7 FHIR. Su objetivo es garantizar la interoperabilidad y el intercambio consistente de datos de salud entre sistemas nacionales e internacionales, permitiendo compatibilidad con estándares mexicanos de salud digital y plataformas basadas en FHIR.

| libersalus | NOM024 | FHIR |
| --- | --- | --- |
| null | 0 | UNK |
| Declined | 0 | asked-declined |
| Male | 1 | 446151000124109 |
| Female | 2 | 446141000124107 |
| Transgender | 3 | 33791000087105 |
| Transsexual | 4 | 33791000087105 |
| Transvestite | 5 | 33791000087105 |
| Intersex | 6 | 33791000087105 |
| Other | 88 | 33791000087105 |

- NOM024 no tiene “declined”
- por lo tanto:
    - `0 = NO ESPECIFICADO` actúa como fallback administrativo
    - `asked-declined` es el significado clínico real en FHIR

### Catálogo Interoperable de Identidad del Paciente

```json
[
    {
        "id": "uuid-0",
        "resource": "gender_identity",
        "value": "unknown",
        "translations": {
            "es": "No especificado",
            "en": "Not specified"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://terminology.hl7.org/CodeSystem/v3-NullFlavor",
                "value": "UNK",
                "display": "Unknown"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "0",
                "display": "NO ESPECIFICADO"
            }
        }
    },
    {
        "id": "uuid-1",
        "resource": "gender_identity",
        "value": "male",
        "translations": {
            "es": "Masculino",
            "en": "Male"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://snomed.info/sct",
                "value": "446151000124109",
                "display": "Male gender identity"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "1",
                "display": "MASCULINO"
            }
        }
    },
    {
        "id": "uuid-2",
        "resource": "gender_identity",
        "value": "female",
        "translations": {
            "es": "Femenino",
            "en": "Female"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://snomed.info/sct",
                "value": "446141000124107",
                "display": "Female gender identity"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "2",
                "display": "FEMENINO"
            }
        }
    },
    {
        "id": "uuid-3",
        "resource": "gender_identity",
        "value": "transgender",
        "translations": {
            "es": "Transgénero",
            "en": "Transgender"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://snomed.info/sct",
                "value": "33791000087105",
                "display": "Non-binary gender identity"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "3",
                "display": "TRANSGÉNERO"
            }
        }
    },
    {
        "id": "uuid-4",
        "resource": "gender_identity",
        "value": "transsexual",
        "translations": {
            "es": "Transexual",
            "en": "Transsexual"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://snomed.info/sct",
                "value": "33791000087105",
                "display": "Non-binary gender identity"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "4",
                "display": "TRANSEXUAL"
            }
        }
    },
    {
        "id": "uuid-5",
        "resource": "gender_identity",
        "value": "travesti",
        "translations": {
            "es": "Travesti",
            "en": "Transvestite"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://snomed.info/sct",
                "value": "33791000087105",
                "display": "Non-binary gender identity"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "5",
                "display": "TRAVESTI"
            }
        }
    },
    {
        "id": "uuid-6",
        "resource": "gender_identity",
        "value": "intersex",
        "translations": {
            "es": "Intersexual",
            "en": "Intersex"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://snomed.info/sct",
                "value": "33791000087105",
                "display": "Non-binary gender identity"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "6",
                "display": "INTERSEXUAL"
            }
        }
    },
    {
        "id": "uuid-88",
        "resource": "gender_identity",
        "value": "other",
        "translations": {
            "es": "Otro",
            "en": "Other"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/gender-identity",
                "system": "http://snomed.info/sct",
                "value": "33791000087105",
                "display": "Non-binary gender identity"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "88",
                "display": "OTRO"
            }
        }
    },
    {
        "id": "uuid-99",
        "resource": "gender_identity",
        "value": "declined",
        "translations": {
            "es": "Prefiere no decir",
            "en": "Declined to specify"
        },
        "mappings": {
            "fhir": {
                "value_set": "http://hl7.org/fhir/ValueSet/data-absent-reason",
                "system": "http://terminology.hl7.org/CodeSystem/data-absent-reason",
                "value": "asked-declined",
                "display": "Asked But Declined"
            },
            "nom024": {
                "value_set": "http://www.dgis.salud.gob.mx",
                "value": "0",
                "display": "NO ESPECIFICADO"
            }
        }
    }
]
```
