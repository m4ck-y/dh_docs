**Proyecto o Apartado:** Core Domain / dh_shared / FHIR / Auditoría

**Título de la actividad o tarea:** Auditoría de Schemas FHIR vs Archivos .md Descargados

**Descripción de la actividad o tarea:**
Se realizó una revisión cruzada entre todos los archivos `.py` de schemas FHIR en `dh_shared` y los archivos `.md` descargados en `dh_fhir/files/`. Cada clase/documento FHIR referenciado en los schemas (vía docstring `Source:`, `ValueSet:`, o property `system`) debe tener su correspondiente `.md` descargado para asegurar trazabilidad total con la especificación FHIR R5.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad:**

## ✅ CUBIERTOS (24 archivos .md existentes)

| Archivo .md | Referenciado por |
|---|---|
| `datatypes.md` | address, attachment, code, contact_point, human_name, identifier, meta, narrative, period, reference, contact_detail |
| `domainresource.md` | base (DomainResource) |
| `extensibility.md` | extension |
| `metadatatypes.md` | extended_contact_detail |
| `narrative.md` | narrative |
| `organization.md` | organization |
| `patient.md` | patient |
| `practitioner.md` | practitioner |
| `relatedperson.md` | related_person |
| `resource.md` | base (Resource + Meta) |
| `types.md` | base (Base) |
| `references.md` | — (referenced por resources) |
| `endpoint.md` | — (referenced por Organization.endpoint) |
| `codesystem-address-use.md` | address_use |
| `valueset-administrative-gender.md` | gender_administrative |
| `valueset-all-languages.md` | Practitioner/RelatedPerson communication |
| `valueset-languages.md` | Practitioner/RelatedPerson communication |
| `valueset-link-type.md` | patient_link |
| `valueset-marital-status.md` | marital_status |
| `valueset-narrative-status.md` | narrative |
| `valueset-patient-contactrelationship.md` | patient_contact_relationship |

## 🔴 FALTANTES (7 archivos .md no descargados)

| HTML | .md requerido | Referenciado por |
|---|---|---|
| `datatypes-definitions.html` | `datatypes-definitions.md` | `period.py` — docstring: `Source: https://build.fhir.org/datatypes-definitions.html#Period` |
| `valueset-address-use.html` | `valueset-address-use.md` | `address_use.py` — docstring: `ValueSet: http://hl7.org/fhir/ValueSet/address-use` |
| `valueset-identifier-use.html` | `valueset-identifier-use.md` | `identifier.py` — docstring: `ValueSet: http://hl7.org/fhir/ValueSet/identifier-use` |
| `valueset-contact-point-system.html` | `valueset-contact-point-system.md` | `contact_point_system.py` — docstring: `ValueSet: http://hl7.org/fhir/ValueSet/contact-point-system` |
| `valueset-contact-point-use.html` | `valueset-contact-point-use.md` | `contact_point_use.py` — docstring: `ValueSet: http://hl7.org/fhir/ValueSet/contact-point-use` |
| `valueset-name-use.html` | `valueset-name-use.md` | `name_use.py` — docstring: `ValueSet: http://hl7.org/fhir/ValueSet/name-use` |
| `valueset-organization-type.html` | `valueset-organization-type.md` | `organization_type.py` — docstring: `ValueSet: http://hl7.org/fhir/ValueSet/organization-type` |

## 📝 Observaciones

1. ~~`ornanization_type.py`~~ → renombrado a `organization_type.py`.
2. **`datatypes-definitions.md`** es una página auxiliar de FHIR que contiene las definiciones detalladas (id, definition, comments, requirements) de cada elemento de los datatypes. No es estrictamente necesaria para la implementación del schema, pero está referenciada en el docstring de `Period`.
3. **`valueset-contact-point-system.md`** y **`valueset-contact-point-use.md`**: los archivos `codesystem-xxx.md` correspondientes cubren el mismo contenido, pero el docstring del enum apunta específicamente al ValueSet, no al CodeSystem.
4. **`practitioner_role.py`** está vacío — el recurso `PractitionerRole` no tiene schema implementado aún.
5. **`money.py`** no referencia ninguna URL FHIR.
