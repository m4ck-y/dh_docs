# Diagrama Family Condition Matrix

## Archivos en este directorio

| Archivo | Tipo | Descripción |
|---|---|---|
| `Diagram_family-condition-matrix.drawio` | Diagrama Draw.io | Diagrama original con la lógica completa del wizard |
| `FAMILY_CONDITION_MATRIX.mmd` | Diagrama Mermaid | Flujo de decisión: familiar → categoría → enfermedad |
| `family_first_matrix.md` | Cuestionario markdown | Vista: familiar primero, luego enfermedades |
| `condition_first_matrix.md` | Cuestionario markdown | Vista: enfermedad primero, luego familiares |

## Reglas de usabilidad

### Loop "¿Otro familiar?" eliminado

El diagrama original incluye el paso 5.0 "¿Desea completar los antecedentes de otro familiar?" con loop. En UI esto se resuelve mediante un botón **"Agregar familiar"** (+), eliminando la necesidad de preguntar explícitamente.

### Loop "¿Otro padecimiento?" eliminado

Mismo criterio: el usuario puede seleccionar múltiples enfermedades dentro de cada categoría mediante checkboxes, sin necesidad de un paso intermedio de confirmación.

### Categorías como separadores

Las 13 categorías (4.1–4.13) se conservan como **separadores visuales** (h2/h3) para mantener la organización por sistemas del cuerpo. Las enfermedades se listan como checkboxes dentro de cada categoría.

### Duplicidad de "¿Vive?" en condition-first

En el flujo `condition_first_matrix.md` el usuario navega por padecimientos y selecciona qué familiares lo han padecido. Si se preguntara "¿Vive?" por cada familiar en cada padecimiento, se generaría redundancia:

1. Usuario selecciona "Diabetes" → marca "Padre" → se pregunta "¿Padre vive?"
2. Usuario selecciona "Hipertensión" → vuelve a marcar "Padre" → se preguntaría "¿Padre vive?" de nuevo

**Solución recomendada:** Elevar la pregunta "¿Vive?" al ámbito del familiar, no del padecimiento. Responderla una vez por familiar y cachear el estado durante la sesión.

## Origen de los datos

Este diagrama fue extraído del módulo de **Antecedentes Heredofamiliares (AHF)** de la Historia Clínica Digital. Los códigos entre paréntesis corresponden a la clasificación **CIE-11**.
