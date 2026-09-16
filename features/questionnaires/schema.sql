-- ===================================================================
-- TIPOS DE ENUMERACIÓN
-- ===================================================================
-- Se crean tipos ENUM para los campos status
CREATE TYPE EAssignmentStatus AS ENUM ('ENABLED', 'IN_PROGRESS', 'COMPLETED', 'SUBMITTED', 'EXPIRED');

-- Tipos de pregunta (alineado con EQuestionType del ERD)
CREATE TYPE EQuestionType AS ENUM (
    'TEXT',
    'TEXT_LONG',
    'NUMBER',
    'SINGLE_CHOICE',
    'MULTIPLE_CHOICE',
    'DATE',
    'DATE_TIME',
    'TIMER',
    'RANGE'
);

-- Sexo biológico objetivo (alineado con EBiologicalSex del ERD)
CREATE TYPE EBiologicalSex AS ENUM ('HOMBRE', 'MUJER', 'INTERSEXUAL');  -- PENDIENTE DE REVISION: catalog/ERD.mmd lo modela como codigos enteros (HOMBRE=1, MUJER=2, INTERSEXUAL=3); aqui se usa un ENUM de texto. Revisar y alinear (entero vs texto).

-- Tipo de recurso enlazado (alineado con EUrlType del ERD)
CREATE TYPE EUrlType AS ENUM ('LINK', 'FILE', 'IMAGE');

-- Unidad de un rango numerico (age_group, estimated_duration). Vocabulario controlado.
CREATE TYPE EUnit AS ENUM ('SECOND', 'MINUTE', 'HOUR', 'DAY', 'WEEK', 'MONTH', 'YEAR');

-- Tipo/rol del formulario: instrumento evaluable, historia clinica, encuesta o formulario generico.
CREATE TYPE EFormType AS ENUM ('INSTRUMENT', 'CLINICAL_HISTORY', 'SURVEY', 'FORM');

-- Origen de una respuesta (answer.source): ingresada por un usuario o
-- autocalculada por una expresion (question.expression). Ver features/questionnaires/expressions/README.md (C7c).
CREATE TYPE EAnswerSource AS ENUM ('USER', 'CALCULATED');

-- ===================================================================
-- CONVENCIONES DE SCHEMA Y MODELO BASE
-- ===================================================================
-- Schema: form (catalogo de cuestionarios).
-- Todas las tablas heredan de BaseModel en Python:
--   id (Integer PK interno incremental), uuid (UUID externo),
--   created_at, updated_at, deleted_at, *_by_id_user.
-- Estos campos se omiten del DDL por convencion; el ORM los agrega.

-- ===================================================================
-- TABLA: form
-- Representa la plantilla inmutable de un cuestionario o formulario.
-- Define su estructura lógica, pero NO almacena respuestas ni instancias.
-- Una vez marcado como "verified", se considera inmutable y no debe modificarse.
--
-- INVARIANTE DE COMPOSICION (ver ADR 038):
--   Un formulario se compone de preguntas directas (questions_form) O de
--   secciones (section + questions_section), NUNCA de ambas. La exclusividad
--   NO se garantiza en la BD (PostgreSQL no permite un CHECK XOR entre tablas);
--   la valida la capa de aplicacion (Pydantic) antes de insertar.
-- ===================================================================
CREATE TABLE form (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) NOT NULL UNIQUE,
    type EFormType NOT NULL DEFAULT 'INSTRUMENT',  -- Rol del formulario (ver EFormType). Distinto de question."type" (tipo de respuesta)
    name VARCHAR(255) NOT NULL,
    description TEXT,              -- Descripción TÉCNICA del instrumento (qué es / qué evalúa). Ver catalog/bank/README.md
    instructions TEXT,             -- Texto de LLENADO para el paciente (cómo responder); nullable. Ver catalog/bank/README.md
    expression JSONB,              -- Envelope de recetas AST: {definitions?, scoring?, evaluation?, subscales?}. Ver expressions/README.md
    condition JSONB,               -- Condición de visibilidad del formulario (AST booleano, raíz sin wrapper). Ausente = siempre visible. Ver expressions/conditions.md (ADR 039)
    verified BOOLEAN NOT NULL DEFAULT false  -- Indica si el formulario ha sido verificado y, por tanto, debe tratarse como inmutable
);

COMMENT ON TABLE form IS 'Plantilla inmutable de un formulario. Se compone de preguntas directas (via questions_form) O de secciones (via section/questions_section), nunca de ambas (ver ADR 038). La exclusividad la valida la capa de aplicacion, no la BD. Define ademas la logica de calculo mediante expresiones en JSONB.';

COMMENT ON COLUMN form.key IS 'Identificador semántico y estable (ej. "onboarding_survey_v3"). Útil para referencias en código o integraciones. No cambia aunque se modifique el nombre.';

COMMENT ON COLUMN form.type IS 'Rol/naturaleza del formulario segun EFormType: INSTRUMENT (instrumento evaluable), CLINICAL_HISTORY (historia clinica), SURVEY (encuesta), FORM (formulario generico). Distinto de question."type" (EQuestionType = tipo de respuesta).';

COMMENT ON COLUMN form.name IS 'Nombre legible del formulario para usuarios finales (ej. "Encuesta de Bienvenida").';

COMMENT ON COLUMN form.description IS 'Descripción TÉCNICA del instrumento (qué es, qué evalúa, propósito). Distinta de instructions (llenado).';

COMMENT ON COLUMN form.instructions IS 'Texto de LLENADO para el paciente: cómo responder el formulario (p. ej. "En las últimas dos semanas…"). Nullable. El texto de presentación amigable NO se modela aquí: vive en el .md legible del banco (catalog/bank/). Distinto de description (técnica).';

COMMENT ON COLUMN form.expression IS 'Envelope de recetas de expresión (AST) del formulario. Claves opcionales: definitions (mapa de fórmulas con nombre, leídas con {ref}), scoring (operador aggregate, raíz SIN wrapper), evaluation (operador case/when condition-based: cada when es una condición booleana) y subscales (arreglo de ámbitos, cada uno con scoring/evaluation propios). Los operandos anidados SÍ llevan wrapper {expression:...} (discriminante de la unión). Gramática: features/questionnaires/expressions/README.md. Ejemplo (PHQ-9): {"scoring": {"type": "aggregate", "operator": "sum", "args": [{"subject": {"entity": "question", "property": "value", "selector": {"all": true}}}], "output": {"type": "number"}}, "evaluation": {"type": "case", "operator": "when", "cases": [{"when": {"expression": {"type": "comparison", "operator": "<", "args": [{"subject": {"entity": "form", "property": "result.scoring"}}, {"const": {"value": 5, "type": "number"}}], "output": {"type": "boolean"}}}, "then": {"const": {"value": "Depresión mínima", "type": "string"}}}], "default": {"const": {"value": "Puntuación fuera de rango", "type": "string"}}, "output": {"type": "string"}, "args": []}}. Se evalúa al enviar (SUBMITTED) y su resultado se guarda en assignment.result.';

COMMENT ON COLUMN form.condition IS 'Condición de visibilidad del formulario completo, como expresión AST booleana en JSONB (raíz SIN wrapper; ver features/questionnaires/expressions/conditions.md, ADR 039). Su ausencia significa siempre visible. Ejemplo: {"type":"comparison","operator":">=","args":[{"subject":{"entity":"person","property":"age"}},{"const":{"value":18,"type":"number"}}],"output":{"type":"boolean"}}.';

COMMENT ON COLUMN form.verified IS 'Indica si el formulario ha sido verificado y, por tanto, debe tratarse como inmutable. Una vez en true, no se deben permitir modificaciones en esta fila ni en sus preguntas asociadas (vía questions_form / questions_section), opciones ni condiciones. La aplicación debe bloquear actualizaciones cuando verified = true.';

-- ===================================================================
-- TABLA: question
-- Define cada pregunta reutilizable (atomo del catalogo).
-- Las preguntas se vinculan a un formulario mediante questions_form o a
-- una seccion mediante questions_section; ambos vinculos son EXCLUYENTES
-- por formulario (ver ADR 038 e invariante en la tabla form).
-- El ORDEN de presentacion NO vive aqui: como una pregunta puede reutilizarse
-- en varios formularios/secciones, su posicion pertenece a la RELACION
-- (questions_form.order / questions_section.order).
-- ===================================================================
CREATE TABLE question (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) NOT NULL,
    text TEXT,          -- Enunciado de la pregunta. NULLABLE: hay items sin enunciado propio (ej. CDI, "elige la frase"); las instrucciones generales van en form.instructions. Ver catalog/bank/README.md
    "type" EQuestionType NOT NULL,
    config JSONB,       -- Configuracion segun el tipo de pregunta (ver catalog/question_types/)
    condition JSONB,    -- Condicion de visibilidad de la pregunta (AST booleano). Ausente = siempre visible. Ver expressions/conditions.md
    expression JSONB    -- Receta del valor autocalculado (AST, UNA expresion, raiz SIN wrapper). Ausente = la responde el usuario. Ver expressions/README.md (C7c)
);

COMMENT ON TABLE question IS 'Pregunta individual reutilizable. Se vincula a formularios mediante questions_form y a secciones mediante questions_section. Permite validar respuestas y definir su comportamiento. El orden NO vive aqui: la pregunta es un atomo reutilizable y su posicion depende del contexto (ver questions_form.order y questions_section.order).';

COMMENT ON COLUMN question.key IS 'Identificador único de la pregunta (ej. "satisfaction_rating"). Se usa en las expresiones de scoring/evaluación y en las respuestas.';

COMMENT ON COLUMN question.text IS 'Enunciado de la pregunta. NULLABLE: hay items sin enunciado propio (ej. CDI, formato "elige la frase"). Las instrucciones generales del instrumento viven una sola vez en form.instructions; como se da contexto al item en la presentacion es decision de esa capa (ver C17). Ver catalog/bank/README.md.';

COMMENT ON COLUMN question."type" IS 'Tipo de pregunta segun el enum EQuestionType: TEXT, TEXT_LONG, NUMBER, SINGLE_CHOICE, MULTIPLE_CHOICE, DATE, DATE_TIME, TIMER, RANGE.';

COMMENT ON COLUMN question.config IS 'Configuracion en JSONB especifica del tipo de pregunta. Su forma depende de question.type (ver catalog/question_types/). Incluye el flag comun "required" y los parametros propios del tipo. Los limites se nombran min/max en todos los tipos; "default" es opcional y excluyente con "required". Ejemplos: RANGE {"required": true, "min": 0, "max": 7, "step": 1, "integer": true}; TIMER {"required": true, "min": "PT0M", "max": "PT24H", "precision": "minutes"}; NUMBER {"required": true, "min": 1, "max": 500, "decimals": 1}. La coherencia de la forma se valida en la capa de aplicacion (ej. Pydantic).';

COMMENT ON COLUMN question.condition IS 'Condición de visibilidad de la pregunta, como expresión AST booleana en JSONB (raíz SIN wrapper; ver features/questionnaires/expressions/conditions.md, ADR 039). Su ausencia significa siempre visible. Ejemplo (PHQ-9 Q10): {"type":"collection","operator":"any","args":[{"expression":{"type":"comparison","operator":">","args":[{"subject":{"entity":"question","property":"value","selector":{"range":[1,9]}}},{"const":{"value":0,"type":"number"}}],"output":{"type":"boolean"}}}],"output":{"type":"boolean"}}.';

COMMENT ON COLUMN question.expression IS 'Receta de un valor AUTOCALCULADO de la pregunta: un operador AST (raíz SIN wrapper, ver features/questionnaires/expressions/README.md). La pregunta es de SOLO LECTURA (el usuario no la responde); su valor se computa con la expresión y se persiste como una fila de answer con source=CALCULATED. Ausente = la pregunta la responde el usuario. Referencias permitidas: preguntas del mismo form (incl. otras calculadas, con validación de ciclos), person, const y {ref} a definitions del form; form.result.* está PROHIBIDO (sería circular). Ejemplos: Total (aggregate sum sobre las respuestas) e IMC (math sobre person.weight/person.height).';

-- ===================================================================
-- TABLA: section
-- Agrupacion logica de preguntas dentro de un formulario.
-- Su presencia implica que el formulario usa secciones, por lo que NO debe
-- tener preguntas directas en questions_form (exclusividad, ver ADR 038).
-- ===================================================================
CREATE TABLE section (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    key VARCHAR(100),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    "order" INTEGER NOT NULL DEFAULT 0,
    condition JSONB     -- Condicion de visibilidad de la seccion (AST booleano). Ausente = siempre visible. Ver expressions/conditions.md
);

COMMENT ON TABLE section IS 'Seccion de un formulario. Agrupa preguntas que se presentan juntas. Un formulario con secciones no debe tener preguntas directas (exclusividad, ver ADR 038).';

COMMENT ON COLUMN section.key IS 'Identificador semantico opcional de la seccion (ej. "datos_personales").';

COMMENT ON COLUMN section.condition IS 'Condición de visibilidad de la sección completa, como expresión AST booleana en JSONB (raíz SIN wrapper; ver features/questionnaires/expressions/conditions.md, ADR 039). Su ausencia significa siempre visible. Ejemplo: {"type":"comparison","operator":"==","args":[{"subject":{"entity":"person","property":"sex"}},{"const":{"value":"F","type":"string"}}],"output":{"type":"boolean"}}.';

-- ===================================================================
-- TABLA: questions_form
-- Puente N:N entre form y question. Permite reutilizar preguntas en
-- multiples formularios. El orden de la pregunta DENTRO de este formulario
-- vive aqui (no en question), porque la posicion depende del contexto.
-- EXCLUSIVO con el uso de secciones: si el formulario tiene filas aqui,
-- no debe tener filas en section (ver ADR 038).
-- ===================================================================
CREATE TABLE questions_form (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    "order" INTEGER NOT NULL DEFAULT 0,  -- Posicion de la pregunta dentro de ESTE formulario
    UNIQUE (id_form, id_question)
);

COMMENT ON TABLE questions_form IS 'Vincula preguntas con formularios (preguntas directas). La misma pregunta puede presentarse en posiciones distintas segun el formulario. Exclusivo con el uso de secciones en el mismo formulario (ver ADR 038).';

COMMENT ON COLUMN questions_form."order" IS 'Orden de presentacion de la pregunta dentro de ESTE formulario. Es la fuente de verdad del orden en el contexto de formulario (la pregunta puede reutilizarse en varios formularios con ordenes distintos).';

-- ===================================================================
-- TABLA: questions_section
-- Puente N:N entre section y question. Permite reutilizar preguntas en
-- multiples secciones. El orden de la pregunta DENTRO de esta seccion
-- vive aqui (no en question), porque la posicion depende del contexto.
-- ===================================================================
CREATE TABLE questions_section (
    id SERIAL PRIMARY KEY,
    id_section INTEGER NOT NULL REFERENCES section(id) ON DELETE CASCADE,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    "order" INTEGER NOT NULL DEFAULT 0,  -- Posicion de la pregunta dentro de ESTA seccion
    UNIQUE (id_section, id_question)
);

COMMENT ON TABLE questions_section IS 'Vincula preguntas con secciones. La misma pregunta puede presentarse en posiciones distintas segun la seccion.';

COMMENT ON COLUMN questions_section."order" IS 'Orden de presentacion de la pregunta dentro de ESTA seccion. Es la fuente de verdad del orden en el contexto de seccion (la pregunta puede reutilizarse en varias secciones con ordenes distintos).';

-- ===================================================================
-- TABLA: option
-- Opcion de respuesta para preguntas de tipo choice.
-- ===================================================================
CREATE TABLE option (
    id SERIAL PRIMARY KEY,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    text VARCHAR(255) NOT NULL,
    value INTEGER NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0,  -- Orden canonico/base de la opcion en su pregunta
    help TEXT
);

COMMENT ON TABLE option IS 'Opcion de respuesta para preguntas de tipo SINGLE_CHOICE o MULTIPLE_CHOICE.';

COMMENT ON COLUMN option."order" IS 'Orden canonico/base de la opcion dentro de su pregunta. Si la pregunta usa shuffle (presentacion aleatoria), este orden sigue siendo la referencia estable para scoring y para cuando la aleatorizacion esta apagada.';

COMMENT ON COLUMN option.help IS 'Texto de ayuda o descripcion tecnica de la opcion, visible solo para roles distintos al paciente.';

-- ===================================================================
-- TABLA: url
-- Recurso enlazado a una opcion de respuesta (redireccion, archivo, imagen).
-- ===================================================================
CREATE TABLE url (
    id SERIAL PRIMARY KEY,
    id_option INTEGER NOT NULL REFERENCES option(id) ON DELETE CASCADE,
    url VARCHAR(2048) NOT NULL,
    type EUrlType NOT NULL
);

COMMENT ON TABLE url IS 'URL asociada a una opcion de respuesta. Puede ser un enlace, archivo o imagen.';

-- NOTA (ADR 039): las tablas conditional_logic (condicion de pregunta) y
-- form_condition (condicion de formulario) se ELIMINARON. La condicion de
-- visibilidad ahora es una columna JSONB en el propio elemento:
--   form.condition, section.condition y question.condition.
-- Guarda una expresion AST (OperandExpression booleana). Su ausencia = siempre
-- visible. Ver features/questionnaires/expressions/conditions.md.

-- ===================================================================
-- TABLA: category
-- Categoria del cuestionario (industria/clinica).
-- ===================================================================
CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    key_industry VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL
);

COMMENT ON TABLE category IS 'Categoria del cuestionario (ej. bienestar emocional, nutricion). ';

-- ===================================================================
-- TABLA: form_categories
-- Puente N:N entre form y category.
-- ===================================================================
CREATE TABLE form_categories (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_category INTEGER NOT NULL REFERENCES category(id) ON DELETE CASCADE,
    UNIQUE (id_form, id_category)
);

COMMENT ON TABLE form_categories IS 'Vincula formularios con categorias.';

-- ===================================================================
-- TABLA: estimated_duration
-- Duracion estimada de completar un formulario.
-- ===================================================================
CREATE TABLE estimated_duration (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    name VARCHAR(255),             -- etiqueta legible para el usuario final (representacion de la fuente, ej. "<=10 minutos")
    min INTEGER,                   -- limite inferior del rango (en `unit`)
    max INTEGER,                   -- limite superior del rango (en `unit`)
    unit EUnit NOT NULL            -- unidad del rango (ver EUnit)
);

COMMENT ON TABLE estimated_duration IS 'Duracion estimada de completar un formulario.';

-- ===================================================================
-- TABLA: age_group
-- Grupo etario (rango de edades).
-- ===================================================================
CREATE TABLE age_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,    -- etiqueta legible para el usuario final (representacion de la fuente, ej. ">60")
    min INTEGER,                   -- edad minima (en `unit`)
    max INTEGER,                   -- edad maxima (en `unit`)
    unit EUnit NOT NULL            -- unidad del rango (ver EUnit; tipicamente YEAR o MONTH)
);

COMMENT ON TABLE age_group IS 'Grupo etario definido por rango de edades.';

-- ===================================================================
-- TABLA: target_age_groups
-- Puente N:N entre form y age_group.
-- ===================================================================
CREATE TABLE target_age_groups (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_age_group INTEGER NOT NULL REFERENCES age_group(id) ON DELETE CASCADE,
    UNIQUE (id_form, id_age_group)
);

COMMENT ON TABLE target_age_groups IS 'Vincula formularios con grupos etarios objetivo.';

-- ===================================================================
-- TABLA: target_sex
-- Sexo biologico objetivo de un formulario.
-- NOTA (abierta, TASK-016 C15): evaluar si los "target" (target_sex, age_group,
-- population) deberian modelarse como parte de `condition` (AST de visibilidad)
-- en lugar de tablas propias. Ver tasks/TASK-016-catalogo-cuestionarios/planning/pendientes.md
-- ===================================================================
CREATE TABLE target_sex (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    type_biological_sex EBiologicalSex NOT NULL
);

COMMENT ON TABLE target_sex IS 'Sexo biologico objetivo de un formulario.';

-- ===================================================================
-- TABLA: population
-- Poblacion objetivo de un formulario.
-- ===================================================================
CREATE TABLE population (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

COMMENT ON TABLE population IS 'Poblacion objetivo (ej. adultos mayores, adolescentes).';

-- ===================================================================
-- TABLA: form_population
-- Puente N:N entre form y population.
-- ===================================================================
CREATE TABLE form_population (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_population INTEGER NOT NULL REFERENCES population(id) ON DELETE CASCADE,
    UNIQUE (id_form, id_population)
);

COMMENT ON TABLE form_population IS 'Vincula formularios con poblaciones objetivo.';

-- ===================================================================
-- TABLA: cie11_code
-- Codigo CIE-11 asociado al formulario.
-- ===================================================================
CREATE TABLE cie11_code (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE
);

COMMENT ON TABLE cie11_code IS 'Codigo CIE-11 asociado al formulario.';

-- ===================================================================
-- TABLA: form_cie11_codes
-- Puente N:N entre form y cie11_code.
-- ===================================================================
CREATE TABLE form_cie11_codes (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_cie11_code INTEGER NOT NULL REFERENCES cie11_code(id) ON DELETE CASCADE,
    UNIQUE (id_form, id_cie11_code)
);

COMMENT ON TABLE form_cie11_codes IS 'Vincula formularios con codigos CIE-11.';

-- ===================================================================
-- TABLA: evaluation_topic
-- Tema de evaluacion asociado al formulario.
-- ===================================================================
CREATE TABLE evaluation_topic (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

COMMENT ON TABLE evaluation_topic IS 'Tema de evaluacion (ej. depresion, ansiedad).';

-- ===================================================================
-- TABLA: form_evaluation_topics
-- Puente N:N entre form y evaluation_topic.
-- ===================================================================
CREATE TABLE form_evaluation_topics (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_evaluation_topic INTEGER NOT NULL REFERENCES evaluation_topic(id) ON DELETE CASCADE,
    UNIQUE (id_form, id_evaluation_topic)
);

COMMENT ON TABLE form_evaluation_topics IS 'Vincula formularios con temas de evaluacion.';

-- ===================================================================
-- TABLA: reference
-- Referencia bibliografica o documental del formulario.
-- ===================================================================
CREATE TABLE reference (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    url_reference VARCHAR(2048),
    name VARCHAR(255) NOT NULL,
    notes TEXT,
    url_thumbnail VARCHAR(2048),
    type_media EUrlType  -- PENDIENTE DE REVISION: catalog/ERD.mmd lo modela como String; aqui se usa EUrlType. Revisar y alinear.
);

COMMENT ON TABLE reference IS 'Referencia externa del formulario (articulo, guia, archivo).';

-- ===================================================================
-- TABLA: assignment
-- DECISIÓN DE ARQUITECTURA: ASSIGNMENT COMO TAREA/EVENTO
-- Cada reevaluación o renovación (manual o programada) crea una NUEVA fila
-- en esta tabla. No se usa como tabla maestra fija: es un evento único por
-- intento de contestar un formulario.
--
-- La persona asignada (id_person) NO tiene por qué ser quien responde.
-- Esto permite escenarios como:
--   • Un tutor responde por un estudiante.
--   • Un gerente asigna una autoevaluación a su equipo (pero cada uno responde por sí mismo).
--   • Un sistema asigna a un grupo, y luego un representante responde.
--
-- RESULTADO: result pertenece a ESTA assignment (evento). No es cache: como cada
-- assignment es un evento único, su resultado le pertenece y no se "recalcula
-- sobre el último intento". Espeja la forma de form.expression.
-- ===================================================================
CREATE TABLE assignment (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_person INTEGER NOT NULL,
    status EAssignmentStatus NOT NULL DEFAULT 'ENABLED',
    -- Nota V2: el estado DISABLED del modelo V1 (bd_mermaid.mmd) se omite a proposito;
    -- una asignacion deshabilitada se representa con soft-delete (deleted_at de BaseModel).
    -- Trazabilidad y auditoría de la sesión completa
    started_by INTEGER,                 -- Quién inició la sesión (usuario)
    completed_by INTEGER,               -- Quién marcó la sesión como completada
    submitted_by INTEGER,               -- Quién envió el formulario
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    submitted_at TIMESTAMP,
    -- Resultado definitivo de ESTA assignment (evento): {definitions?, scoring?, evaluation?, subscales?}.
    -- Cada valor se guarda como {value, type} (mismos campos que un const del AST).
    result JSONB                        -- Ej. {"scoring": {"value": 11, "type": "number"}, "evaluation": {"value": "Depresión moderada", "type": "string"}}
    -- Nota V2: n_questions_total / n_questions_answered del modelo V1 NO se persisten;
    -- el progreso se calcula al vuelo desde answer.
);

COMMENT ON TABLE assignment IS 'Tarea/evento único de contestar un formulario por una persona o entidad (id_person). Cada reevaluación o renovación crea una nueva fila. No es una tabla maestra fija; el resultado (result) pertenece a este evento y no es un cache de "último intento".';

COMMENT ON COLUMN assignment.id_person IS 'ID de la persona, estudiante, empleado o entidad a quien se le "asigna" el formulario. Puede ser distinto del usuario que responde (ver answer.answered_by). Ej: un alumno (id_person=123) recibe una evaluación, pero su tutor la completa.';

COMMENT ON COLUMN assignment.status IS 'Estado de la asignación segun el enum EAssignmentStatus: ENABLED, IN_PROGRESS, COMPLETED, SUBMITTED, EXPIRED.';
COMMENT ON COLUMN assignment.started_by IS 'Usuario que inició la sesión (quién abrió el formulario).';
COMMENT ON COLUMN assignment.completed_by IS 'Usuario que marcó el formulario como completado (puede guardar progreso sin enviar).';
COMMENT ON COLUMN assignment.submitted_by IS 'Usuario que envió oficialmente el formulario.';
COMMENT ON COLUMN assignment.started_at IS 'Momento en que se inició la sesión (primer acceso).';
COMMENT ON COLUMN assignment.completed_at IS 'Momento en que se marcó como completado (progreso completo, sin enviar aún).';
COMMENT ON COLUMN assignment.submitted_at IS 'Momento en que se envió oficialmente la tarea.';

COMMENT ON COLUMN assignment.result IS 'Resultado de evaluar form.expression para ESTA assignment. Espeja la forma del envelope: {definitions?, scoring?, evaluation?, subscales?}. Cada valor es {value, type} (mismos campos que un const del AST). Ejemplos: simple {"scoring": {"value": 11, "type": "number"}, "evaluation": {"value": "Depresión moderada", "type": "string"}}; con subescalas {"subscales": [{"id": "A", "scoring": {"value": 8, "type": "number"}, "evaluation": {"value": "Probable ansiedad", "type": "string"}}]}; con intermedios (IPAQ) {"definitions": {"total_mets": {"value": 979, "type": "number"}}, "scoring": {"value": 979, "type": "number"}, "evaluation": {"value": "Moderado", "type": "string"}}. No es la receta: es el valor calculado. Ver features/questionnaires/expressions/README.md §6.';

-- ===================================================================
-- TABLA: scheduled
-- Ventana de disponibilidad temporal para cuestionarios PROGRAMADOS.
-- Solo existe si un profesional programó el cuestionario: en flujos
-- directos (paciente auto-contesta) NO hay 'scheduled'.
--
-- CARDINALIDAD: cada assignment tiene a lo sumo UNA programación (0..1).
-- 'o' cubre el flujo directo (sin programar).
-- ===================================================================
CREATE TABLE scheduled (
    id SERIAL PRIMARY KEY,
    id_assignment INTEGER NOT NULL REFERENCES assignment(id) ON DELETE CASCADE,
    assigned_by INTEGER NOT NULL,
    available_from TIMESTAMP NOT NULL,
    available_until TIMESTAMP NOT NULL,
    time_limit_minutes INTEGER,
    CHECK (available_from <= available_until),
    CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0)
);

COMMENT ON TABLE scheduled IS 'Ventana de disponibilidad de una asignación programada. Solo existe cuando un profesional programa el formulario; el flujo directo (auto-contestado) no tiene scheduled. Cada assignment tiene a lo sumo una programación.';

COMMENT ON COLUMN scheduled.assigned_by IS 'Referencia al usuario (medico/enfermera/admin/sistema) que programó la disponibilidad. No es un enum: es un FK a la entidad de usuarios.';

COMMENT ON COLUMN scheduled.time_limit_minutes IS 'Tiempo máximo permitido desde que se inicia la sesión (started_at) hasta que debe enviarse (submitted_at). Si es NULL, no hay límite.';

-- ===================================================================
-- TABLA: answer
-- Almacena la respuesta a una pregunta específica dentro de una assignment.
-- El valor se guarda en JSONB para soportar múltiples tipos de datos.
--
-- DECISIÓN DE ARQUITECTURA: TRAZABILIDAD POR PREGUNTA
-- 'answered_by' vive en cada answer individual para auditar si una pregunta
-- específica la respondió el médico, tutor o paciente. No es un enum: es una
-- FK a la entidad de usuarios.
--
-- ORIGEN (source): una answer puede ser ingresada por un usuario (USER) o
-- AUTOCALCULADA por una expresión (CALCULATED, ver question.expression).
-- Las calculadas se persisten como SNAPSHOT al enviar la assignment: congelan
-- el valor tal como se computó en ese momento (p. ej. edad o IMC), de modo que
-- el histórico no cambia aunque cambien luego person o la definición del form.
-- Una fila calculada no tiene usuario: source=CALCULATED <=> answered_by IS NULL.
--
-- NOTA: La validación del tipo de dato en "data" (ej. que coincida con question_type)
-- debe realizarse a nivel de API (por ejemplo, con Pydantic en Python) antes de insertar.
-- ===================================================================
CREATE TABLE answer (
    id SERIAL PRIMARY KEY,
    id_assignment INTEGER NOT NULL REFERENCES assignment(id) ON DELETE CASCADE,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    source EAnswerSource NOT NULL DEFAULT 'USER',
    answered_by INTEGER,
    data JSONB NOT NULL,
    CHECK (data ? 'value' AND data ? 'type'),
    -- Coherencia origen/usuario: USER exige usuario; CALCULATED exige NULL.
    CHECK ((source = 'USER') = (answered_by IS NOT NULL))
);

COMMENT ON TABLE answer IS 'Respuesta individual a una pregunta en una assignment específica. Cada answer pertenece a una única assignment; el valor se normaliza en JSONB para flexibilidad. Su origen (source) distingue las respuestas del usuario (USER) de los valores autocalculados (CALCULATED, ver question.expression), que se persisten como snapshot al enviar.';

COMMENT ON COLUMN answer.id_assignment IS 'Assignment (tarea/evento) a la que pertenece esta respuesta.';

COMMENT ON COLUMN answer.source IS 'Origen de la respuesta segun EAnswerSource: USER (ingresada por una persona) o CALCULATED (valor autocalculado desde question.expression). Las calculadas se computan al vuelo durante el llenado y se persisten como snapshot al enviar (SUBMITTED). Ver features/questionnaires/expressions/README.md.';

COMMENT ON COLUMN answer.answered_by IS 'Referencia al usuario que ingresó esta respuesta puntual (médico, tutor o paciente). Permite auditoría por pregunta. No es un enum: es un FK a la entidad de usuarios. Es NULL únicamente cuando source = CALCULATED (el CHECK garantiza la coherencia con source).';

COMMENT ON COLUMN answer.data IS 'Estructura normalizada {value, type}: mismos campos que un const del AST y que assignment.result, de modo que todo valor del modulo comparte vocabulario. Ejemplos:
  - Texto: {"value": "Muy satisfecho", "type": "string"}
  - Numero: {"value": 9.5, "type": "number"}
  - Opcion multiple: {"value": [1, 3], "type": "array_number"}
  - Fecha: {"value": "2026-08-26", "type": "date"}
  - Fecha-hora: {"value": "2026-08-26T14:30:00Z", "type": "datetime"}
  - Duracion: {"value": "PT1H30M", "type": "duration"}
  Las respuestas de opcion guardan el value numerico de la opcion (option.value), no la etiqueta.
  En filas con source=CALCULATED, data guarda el valor computado por question.expression (p. ej. IMC: {"value": 24.5, "type": "number"}).
  ⚠️ La coherencia entre type y question_type debe validarse en la capa de aplicacion (ej. con Pydantic).';

-- ===================================================================
-- ÍNDICES PARA RENDIMIENTO
-- ===================================================================
CREATE INDEX idx_assignment_form_person ON assignment (id_form, id_person);
CREATE INDEX idx_answer_assignment ON answer (id_assignment);
CREATE INDEX idx_question_key ON question (key);
CREATE INDEX idx_section_form ON section (id_form);
CREATE INDEX idx_section_key ON section (key);
CREATE INDEX idx_questions_form_form ON questions_form (id_form);
CREATE INDEX idx_questions_form_question ON questions_form (id_question);
CREATE INDEX idx_questions_section_section ON questions_section (id_section);
CREATE INDEX idx_questions_section_question ON questions_section (id_question);
CREATE INDEX idx_option_question ON option (id_question);
CREATE INDEX idx_url_option ON url (id_option);
CREATE INDEX idx_form_categories_form ON form_categories (id_form);
CREATE INDEX idx_form_categories_category ON form_categories (id_category);
CREATE INDEX idx_estimated_duration_form ON estimated_duration (id_form);
CREATE INDEX idx_target_age_groups_form ON target_age_groups (id_form);
CREATE INDEX idx_target_age_groups_age_group ON target_age_groups (id_age_group);
CREATE INDEX idx_target_sex_form ON target_sex (id_form);
CREATE INDEX idx_form_population_form ON form_population (id_form);
CREATE INDEX idx_form_population_population ON form_population (id_population);
CREATE INDEX idx_form_cie11_codes_form ON form_cie11_codes (id_form);
CREATE INDEX idx_form_cie11_codes_code ON form_cie11_codes (id_cie11_code);
CREATE INDEX idx_form_evaluation_topics_form ON form_evaluation_topics (id_form);
CREATE INDEX idx_form_evaluation_topics_topic ON form_evaluation_topics (id_evaluation_topic);
CREATE INDEX idx_reference_form ON reference (id_form);
CREATE INDEX idx_scheduled_assignment ON scheduled (id_assignment);

-- Índices adicionales sugeridos
CREATE INDEX idx_assignment_status_person ON assignment (status, id_person);
CREATE INDEX idx_scheduled_time_window ON scheduled (available_from, available_until);

-- ===================================================================
-- NOTA PARA FUTURAS MEJORAS
-- ===================================================================
/*
Si en el futuro se requiere que los formularios puedan evolucionar sin afectar asignaciones existentes,
se recomienda implementar un sistema de versionado:

CREATE TABLE form_version (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id),
    version_number INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    expression JSONB,
    UNIQUE (id_form, version_number)
);

-- Y modificar:
--   assignment.id_form → assignment.id_form_version
--   question.id_form → question.id_form_version

Esto garantizaría inmutabilidad por versión y trazabilidad histórica.
*/