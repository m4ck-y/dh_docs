# health_profile

Schema de PostgreSQL para perfiles de salud biologica y clinica.

Almacena atributos biologicos y clinicos estables del individuo, como sexo biologico, tipo de sangre y alergias.

## Entidades (FK a person)

| Entidad | Descripcion |
|---|---|
| `biological_profile` | Perfil biologico (sexo biologico, tipo de sangre). Relacion 1:1 con person. |
| `person_allergy` | Alergias del paciente. Relacion 1:N con person. |
| `vaccination_record` | Historial de vacunacion. Relacion 1:N con person. |
| `death` | Detalles de fallecimiento (fecha, causa). Relacion 1:1 con person; existe **solo si** la persona fallecio. |

> Las **condiciones/enfermedades** viven en `clinical_history.condition` (no aqui).

## Enums

| Enum | Valores |
|---|---|
| `EBiologicalSex` | `HOMBRE=1`, `MUJER=2`, `INTERSEXUAL=3` |
| `EBloodType` | `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-` |

## Archivos

| Archivo | Descripcion |
|---|---|
| [erd.mmd](./erd.mmd) | Diagrama ERD del schema en Mermaid |

## Catalogos futuros

| Catalogo | Descripcion |
|---|---|
| `allergy_severity` | Severidad de alergias (LEVE, MODERADA, SEVERA) |
| `allergy_reaction_type` | Tipos de reaccion (RESPIRATORIA, CUTANEA, DIGESTIVA) |
| `vaccine_catalog` | Vacunas disponibles |
