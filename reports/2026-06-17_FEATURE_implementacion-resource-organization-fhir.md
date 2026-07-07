**Proyecto o Apartado:** Core Domain / dh_shared / FHIR Organization

**Título de la actividad o tarea:** Implementación del Esquema Pydantic para el Recurso Organization (FHIR)

**Descripción de la actividad o tarea:**
Continuando con la fase de adopción del estándar FHIR, se procedió a la implementación del esquema de validación Pydantic para el recurso **Organization** en la librería compartida `dh_shared`. Este recurso es fundamental para modelar las entidades jurídico-operativas del ecosistema hospitalario: hospitales corporativos, clínicas, laboratorios, departamentos gubernamentales y aseguradoras. La implementación cubre la estructura completa del recurso según FHIR R5, incluyendo sus tipos de datos anidados y value sets vinculados.

**Detalles Técnicos y de Código:**
Se programó la estructura de validación en `dh_shared/src/dh_shared/schemas/shared/fhir/resources/organization.py`. Los componentes implementados incluyen:

- **`Organization(DomainResource)`**: Clase principal con los atributos `identifier` (lista de `Identifier`), `active`, `type` (lista de `CodeableConcept` con binding a `OrganizationType`), `name`, `alias`, `description`, `telecom` (lista de `ContactPoint`), `address` (lista de `Address`), `partOf` (`Reference` a Organization para jerarquía), `contact` (lista de `OrganizationContact`) y `endpoint` (lista de `Reference` a Endpoint).

- **`OrganizationContact(Element)`**: Modelo para contactos administrativos de la organización, con `purpose` (`CodeableConcept` vinculado a `ContactEntityType`), `name` (`HumanName`), `telecom` (lista de `ContactPoint`) y `address` (`Address`).

- **Value sets implementados**:
  - `OrganizationType` en `valueset/organization_type.py`: clasificación FHIR `organization-type` (códigos: prov, dept, team, govt, ins, pay, edu, reli, crs, cg, bus, other).
  - `ContactEntityType` en `valueset/contact_entity_type.py`: tipos de contacto administrativo según FHIR.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Escritura y depuración del archivo `organization.py` con herencia desde `DomainResource` y uso de `Element` para `OrganizationContact`.
- Implementación de los value sets `OrganizationType` y `ContactEntityType` con docstrings, system URIs y properties `display`/`definition` según el estándar definido en `AGENTS.md`.
- Validación de estructura jerárquica mediante el campo `partOf` para permitir modelado de organizaciones padre-hijo.
- Sincronización de imports con los datatypes existentes (`Identifier`, `CodeableConcept`, `ContactPoint`, `HumanName`, `Address`, `Reference`).
