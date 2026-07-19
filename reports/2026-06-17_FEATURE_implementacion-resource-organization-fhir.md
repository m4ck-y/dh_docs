**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Organization

**Título de la actividad o tarea:** Implementación del Esquema Pydantic para el Recurso [Organization](https://hl7.org/fhir/R5/organization.html) (FHIR)

**Descripción de la actividad o tarea:**
Continuando con la fase de adopción del estándar FHIR, se procedió a la implementación del esquema de validación Pydantic para el recurso [**Organization**](https://hl7.org/fhir/R5/organization.html) en la librería compartida `dh_shared`. Este recurso es fundamental para modelar las entidades jurídico-operativas del ecosistema hospitalario: hospitales corporativos, clínicas, laboratorios, departamentos gubernamentales y aseguradoras. La implementación cubre la estructura completa del recurso según FHIR R5, incluyendo sus tipos de datos anidados y value sets vinculados.

**Detalles Técnicos y de Código:**
Se programó la estructura de validación en `dh_shared/src/dh_shared/schemas/shared/fhir/resources/organization.py`. Los componentes implementados incluyen:

- [**Organization(DomainResource)**](https://hl7.org/fhir/R5/organization.html): Clase principal con los atributos `identifier` (lista de `Identifier`), `active`, `type` (lista de `CodeableConcept` con binding a `OrganizationType`), `name`, `alias`, `description`, `contact` (lista de `ExtendedContactDetail`), `partOf` ([`Reference`](https://hl7.org/fhir/R5/organization.html) a Organization para jerarquía), `qualification` (lista de `OrganizationQualification`) y `endpoint` (lista de [`Reference`](https://hl7.org/fhir/R5/endpoint.html) a Endpoint).  
  *Nota R5: `telecom` y `address` directos se eliminaron; ahora van dentro de `contact` como `ExtendedContactDetail`.*

- **`ExtendedContactDetail`**: Tipo de datos de contacto reutilizable definido en `extensibility/extended_contact_detail.py` con `purpose` (`CodeableConcept`), `name` (`HumanName`), `telecom` (lista de `ContactPoint`), `address` (`Address`) y otros atributos. Reemplaza al antiguo backbone `OrganizationContact` de R4.

- **`OrganizationQualification(Element)`**: Backbone anidado para credenciales, certificaciones y licencias de la organización, con `identifier` (lista de `Identifier`), `code` (`CodeableConcept`), `period` (`Period`) e `issuer` ([`Reference(Organization)`](https://hl7.org/fhir/R5/organization.html)). Nuevo en R5.

- **Value sets implementados**:
  - `OrganizationType` en `valueset/organization_type.py`: clasificación FHIR `organization-type` (códigos: prov, dept, team, govt, ins, pay, edu, reli, crs, cg, bus, other).
  - `ContactEntityType` en `valueset/contact_entity_type.py`: tipos de propósito de contacto según FHIR.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Escritura y depuración del archivo `organization.py` con herencia desde `DomainResource`, uso de `ExtendedContactDetail` para contactos y `OrganizationQualification(Element)` como backbone anidado.
- Migración R4→R5: `contact` pasó de ser `BackboneElement` (`OrganizationContact`) a `ExtendedContactDetail`, un tipo de datos reutilizable compartido con Practitioner, Patient, etc.
- Implementación de los value sets `OrganizationType` y `ContactEntityType` con docstrings, system URIs y properties `display`/`definition` según el estándar definido en `AGENTS.md`.
- Validación de estructura jerárquica mediante el campo `partOf` para permitir modelado de organizaciones padre-hijo.
- Sincronización de imports con los datatypes existentes (`Identifier`, `CodeableConcept`, `ExtendedContactDetail`, `Reference`).
