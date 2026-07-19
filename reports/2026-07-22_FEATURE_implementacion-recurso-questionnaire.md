**Proyecto o Apartado:** dh_shared / FHIR Questionnaire Resource

**Título de la actividad o tarea:** Implementación del Recurso FHIR R5 Questionnaire y sus Value Sets Asociados

**Descripción de la actividad o tarea:**
Se implementó el recurso **[Questionnaire](https://hl7.org/fhir/questionnaire.html)** del estándar HL7 FHIR R5 en la librería `dh_shared`, completando el par de recursos cuestionario-respuesta junto con `QuestionnaireResponse` que ya existía en el catálogo. Un Questionnaire define un conjunto estructurado de preguntas para guiar la recolección de respuestas de usuarios finales, con control detallado sobre orden, presentación, fraseo y agrupamiento.

El recurso cuenta con 4 backbones anidados:

- **QuestionnaireItem**: Elemento central que representa preguntas, grupos o texto de visualización. Es recursivo (un item puede contener sub-items), soporta tipado estricto mediante `QuestionnaireItemType` (15 tipos: group, display, boolean, decimal, integer, date, dateTime, time, string, text, url, coding, attachment, reference, quantity) e incluye 14 campos de control como `required`, `repeats`, `readOnly`, `maxLength`, `enableWhen`, `enableBehavior` y `answerConstraint`.
- **QuestionnaireEnableWhen**: Define condiciones para habilitar/deshabilitar items basadas en respuestas a otras preguntas. Incluye choice type `answer[x]` con 10 variantes (boolean, decimal, integer, date, dateTime, time, string, Coding, Quantity, Reference) y usa el value set `QuestionnaireItemOperator` (7 operadores: exists, =, !=, >, <, >=, <=).
- **QuestionnaireAnswerOption**: Representa una respuesta permitida para una pregunta. Usa choice type `value[x]` con 6 variantes (integer, date, time, string, Coding, Reference) más un indicador `initialSelected`.
- **QuestionnaireInitialItem**: Define valores iniciales pre-poblados al renderizar el cuestionario. Usa choice type `value[x]` con 12 variantes (boolean, decimal, integer, date, dateTime, time, string, uri, Attachment, Coding, Quantity, Reference).

Se crearon 7 value sets como dependencias del recurso:

| ValueSet | Binding | Códigos |
|---|---|---|
| `QuestionnaireItemType` | Required — `item.type` | 15 (group, display, boolean, decimal, integer, date, dateTime, time, string, text, url, coding, attachment, reference, quantity) |
| `QuestionnaireItemOperator` | Required — `enableWhen.operator` | 7 (exists, =, !=, >, <, >=, <=) |
| `EnableWhenBehavior` | Required — `item.enableBehavior` | 2 (all, any) |
| `QuestionnaireItemDisabledDisplay` | Required — `item.disabledDisplay` | 2 (hidden, protected) |
| `QuestionnaireAnswerConstraint` | Required — `item.answerConstraint` | 3 (optionsOnly, optionsOrType, optionsOrString) |
| `VersionAlgorithm` | Extensible — `versionAlgorithm[x]` | 5 (semver, integer, alpha, date, natural) |
| `ResourceType` | Required — `subjectType` | 157 (todos los tipos de recurso FHIR R5) |

La implementación sigue todas las reglas establecidas en `AGENTS.md`: bindeos Required/Preferred implementados como enums con propiedades `system`, `display` y `definition`; choice types validados mediante `model_validator` XOR; referencias tipadas donde corresponde; y `from __future__ import annotations` para backbones recursivos.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- 35 recursos FHIR totales (19 core + 16 adicionales).
- 117 value sets totales (62 core + 55 extended).
- Se descargaron 8 spec files de soporte para verificar dependencias previo a la implementación.
- Verificación de sintaxis AST parse exitosa en los 9 archivos creados/modificados.
- Sin dependencias externas adicionales: todos los datatypes (`Coding`, `Quantity`, `Attachment`, `Period`, `ContactDetail`, `UsageContext`, `Reference`) ya existían en el catálogo.
