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
    'TIMER'
);

-- Sexo biológico objetivo (alineado con EBiologicalSex del ERD)
CREATE TYPE EBiologicalSex AS ENUM ('HOMBRE', 'MUJER', 'INTERSEXUAL');

-- Tipo de recurso enlazado (alineado con EUrlType del ERD)
CREATE TYPE EUrlType AS ENUM ('LINK', 'FILE', 'IMAGE');

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
-- ===================================================================
CREATE TABLE form (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    scoring_expression JSONB,      -- Fórmula para calcular puntaje (ej. {"op": "sum", "fields": ["q1", "q2"]})
    evaluation_expression JSONB,   -- Regla para clasificar resultado (ej. {"if": [{"gte": ["score", 70]}, "aprobado", "reprobado"]})
    verified BOOLEAN NOT NULL DEFAULT false  -- Indica si el formulario ha sido verificado y, por tanto, debe tratarse como inmutable
);

COMMENT ON TABLE form IS 'Plantilla inmutable de un formulario. Define preguntas (vía questions_form y questions_section), y lógica de cálculo mediante expresiones en JSONB.';

COMMENT ON COLUMN form.key IS 'Identificador semántico y estable (ej. "onboarding_survey_v3"). Útil para referencias en código o integraciones. No cambia aunque se modifique el nombre.';

COMMENT ON COLUMN form.name IS 'Nombre legible del formulario para usuarios finales (ej. "Encuesta de Bienvenida").';

COMMENT ON COLUMN form.description IS 'Descripción explicativa del propósito del formulario.';

COMMENT ON COLUMN form.scoring_expression IS 'Expresión en JSONB que define cómo se calcula el puntaje numérico a partir de las respuestas. Ejemplo: {"operation": "weighted_sum", "weights": {"q1": 0.3, "q2": 0.7}}. Se evalúa al procesar una respuesta.';

COMMENT ON COLUMN form.evaluation_expression IS 'Expresión en JSONB que define cómo se interpreta el puntaje para generar una clasificación cualitativa. Ejemplo: {"if": [{"gte": ["score", 80]}, "excelente", {"gte": ["score", 60]}, "suficiente", "insuficiente"]}.';

COMMENT ON COLUMN form.verified IS 'Indica si el formulario ha sido verificado y, por tanto, debe tratarse como inmutable. Una vez en true, no se deben permitir modificaciones en esta fila ni en sus preguntas asociadas (vía questions_form / questions_section), opciones ni condicionales. La aplicación debe bloquear actualizaciones cuando verified = true.';

-- ===================================================================
-- TABLA: question
-- Define cada pregunta dentro de un formulario.
-- Las preguntas se vinculan a un formulario mediante questions_form (1:N) o a
-- una seccion mediante questions_section (1:N).
-- Esencial para validar respuestas y renderizar el cuestionario.
-- ===================================================================
CREATE TABLE question (
    id SERIAL PRIMARY KEY,
    key VARCHAR(100) NOT NULL,
    text TEXT NOT NULL,
    "type" EQuestionType NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE question IS 'Pregunta individual reutilizable. Se vincula a formularios mediante questions_form y a secciones mediante questions_section. Permite validar respuestas y definir su comportamiento.';

COMMENT ON COLUMN question.key IS 'Identificador único de la pregunta (ej. "satisfaction_rating"). Se usa en las expresiones de scoring/evaluación y en las respuestas.';

COMMENT ON COLUMN question."type" IS 'Tipo de pregunta segun el enum EQuestionType: TEXT, TEXT_LONG, NUMBER, SINGLE_CHOICE, MULTIPLE_CHOICE, DATE, DATE_TIME, TIMER.';

COMMENT ON COLUMN question."order" IS 'Orden de presentacion de la pregunta dentro de su contexto (formulario o seccion).';

-- ===================================================================
-- TABLA: section
-- Agrupacion logica de preguntas dentro de un formulario.
-- ===================================================================
CREATE TABLE section (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    key VARCHAR(100),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    "order" INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE section IS 'Seccion de un formulario. Agrupa preguntas que se presentan juntas.';

COMMENT ON COLUMN section.key IS 'Identificador semantico opcional de la seccion (ej. "datos_personales").';

-- ===================================================================
-- TABLA: questions_form
-- Puente N:N entre form y question. Permite reutilizar preguntas en
-- multiples formularios y controlar el orden por formulario.
-- ===================================================================
CREATE TABLE questions_form (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    UNIQUE (id_form, id_question)
);

COMMENT ON TABLE questions_form IS 'Vincula preguntas con formularios.';

-- ===================================================================
-- TABLA: questions_section
-- Puente N:N entre section y question. Permite reutilizar preguntas en
-- multiples secciones y controlar el orden por seccion.
-- ===================================================================
CREATE TABLE questions_section (
    id SERIAL PRIMARY KEY,
    id_section INTEGER NOT NULL REFERENCES section(id) ON DELETE CASCADE,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    UNIQUE (id_section, id_question)
);

COMMENT ON TABLE questions_section IS 'Vincula preguntas con secciones.';

-- ===================================================================
-- TABLA: option
-- Opcion de respuesta para preguntas de tipo choice.
-- ===================================================================
CREATE TABLE option (
    id SERIAL PRIMARY KEY,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    text VARCHAR(255) NOT NULL,
    value INTEGER NOT NULL,
    help TEXT
);

COMMENT ON TABLE option IS 'Opcion de respuesta para preguntas de tipo SINGLE_CHOICE o MULTIPLE_CHOICE.';

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

-- ===================================================================
-- TABLA: conditional_logic
-- Condicion de visibilidad de una pregunta.
-- ===================================================================
CREATE TABLE conditional_logic (
    id SERIAL PRIMARY KEY,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    triggered_by_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    formula TEXT NOT NULL,
    description TEXT
);

COMMENT ON TABLE conditional_logic IS 'Condicion que determina si una pregunta se muestra u oculta en funcion de otra pregunta.';

-- ===================================================================
-- TABLA: form_condition
-- Condicion de visibilidad a nivel formulario.
-- ===================================================================
CREATE TABLE form_condition (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    expression TEXT NOT NULL,
    description TEXT
);

COMMENT ON TABLE form_condition IS 'Condicion que afecta la visibilidad o disponibilidad de todo el formulario.';

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
    min_minutes INTEGER,
    max_minutes INTEGER,
    description TEXT
);

COMMENT ON TABLE estimated_duration IS 'Duracion estimada de completar un formulario.';

-- ===================================================================
-- TABLA: age_group
-- Grupo etario (rango de edades).
-- ===================================================================
CREATE TABLE age_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    min_age INTEGER,
    max_age INTEGER
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
    type_media EUrlType  -- PENDIENTE DE REVISION: ERD_questionnaires.mmd lo modela como String; aqui se usa EUrlType. Revisar y alinear.
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
-- RESULTADO: scoring_result y evaluation_result pertenecen a ESTA assignment
-- (evento). No son cache: como cada assignment es un evento único, su resultado
-- le pertenece y no se "recalcula sobre el último intento".
-- ===================================================================
CREATE TABLE assignment (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_person INTEGER NOT NULL,
    status EAssignmentStatus NOT NULL DEFAULT 'ENABLED',
    -- Trazabilidad y auditoría de la sesión completa
    started_by INTEGER,                 -- Quién inició la sesión (usuario)
    completed_by INTEGER,               -- Quién marcó la sesión como completada
    submitted_by INTEGER,               -- Quién envió el formulario
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    submitted_at TIMESTAMP,
    -- Resultado definitivo de ESTA assignment (evento)
    scoring_result JSONB,               -- Puntaje calculado de esta tarea
    evaluation_result JSONB             -- Clasificación cualitativa de esta tarea
);

COMMENT ON TABLE assignment IS 'Tarea/evento único de contestar un formulario por una persona o entidad (id_person). Cada reevaluación o renovación crea una nueva fila. No es una tabla maestra fija; el resultado (scoring_result/evaluation_result) pertenece a este evento y no es un cache de "último intento".';

COMMENT ON COLUMN assignment.id_person IS 'ID de la persona, estudiante, empleado o entidad a quien se le "asigna" el formulario. Puede ser distinto del usuario que responde (ver answer.answered_by). Ej: un alumno (id_person=123) recibe una evaluación, pero su tutor la completa.';

COMMENT ON COLUMN assignment.status IS 'Estado de la asignación segun el enum EAssignmentStatus: ENABLED, IN_PROGRESS, COMPLETED, SUBMITTED, EXPIRED.';
COMMENT ON COLUMN assignment.started_by IS 'Usuario que inició la sesión (quién abrió el formulario).';
COMMENT ON COLUMN assignment.completed_by IS 'Usuario que marcó el formulario como completado (puede guardar progreso sin enviar).';
COMMENT ON COLUMN assignment.submitted_by IS 'Usuario que envió oficialmente el formulario.';
COMMENT ON COLUMN assignment.started_at IS 'Momento en que se inició la sesión (primer acceso).';
COMMENT ON COLUMN assignment.completed_at IS 'Momento en que se marcó como completado (progreso completo, sin enviar aún).';
COMMENT ON COLUMN assignment.submitted_at IS 'Momento en que se envió oficialmente la tarea.';

COMMENT ON COLUMN assignment.scoring_result IS 'Puntaje definitivo de esta tarea/evento, basado en el scoring_expression del form. Se calcula al enviar (SUBMITTED). Ejemplo: {"op": "sum", "fields": ["q1", "q2"]}.';

COMMENT ON COLUMN assignment.evaluation_result IS 'Clasificación cualitativa de esta tarea/evento, basada en el evaluation_expression del form. Se calcula al enviar (SUBMITTED). Ejemplo: {"category": "aprobado", "level": "alto", "description": "Excelente desempeño"}.';

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
-- específica la respondió el médico, tutor o paciente. No es un enum: es un
-- FK a la entidad de usuarios.
--
-- NOTA: La validación del tipo de dato en "value" (ej. que coincida con question_type)
-- debe realizarse a nivel de API (por ejemplo, con Pydantic en Python) antes de insertar.
-- ===================================================================
CREATE TABLE answer (
    id SERIAL PRIMARY KEY,
    id_assignment INTEGER NOT NULL REFERENCES assignment(id) ON DELETE CASCADE,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    answered_by INTEGER,
    value JSONB NOT NULL,
    CHECK (value ? 'type' AND value ? 'value')
);

COMMENT ON TABLE answer IS 'Respuesta individual a una pregunta en una assignment específica. Cada answer pertenece a una única assignment; el valor se normaliza en JSONB para flexibilidad.';

COMMENT ON COLUMN answer.id_assignment IS 'Assignment (tarea/evento) a la que pertenece esta respuesta.';

COMMENT ON COLUMN answer.answered_by IS 'Referencia al usuario que ingresó esta respuesta puntual (médico, tutor o paciente). Permite auditoría por pregunta. No es un enum: es un FK a la entidad de usuarios.';

COMMENT ON COLUMN answer.value IS 'Estructura normalizada: {"type": "string|number|boolean|array", "value": ...}. Ejemplos:
  - Texto: {"type": "text", "value": "Muy satisfecho"}
  - Número: {"type": "number", "value": 9.5}
  - Opción múltiple: {"type": "array", "value": ["opc1", "opc3"]}
  Esta estructura permite procesar respuestas de forma genérica y segura.
  ⚠️ La coherencia entre el tipo de respuesta y el question_type debe validarse en la capa de aplicación (ej. con Pydantic).';

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
CREATE INDEX idx_conditional_logic_question ON conditional_logic (id_question);
CREATE INDEX idx_conditional_logic_triggered ON conditional_logic (triggered_by_question);
CREATE INDEX idx_form_condition_form ON form_condition (id_form);
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
    scoring_expression JSONB,
    evaluation_expression JSONB,
    UNIQUE (id_form, version_number)
);

-- Y modificar:
--   assignment.id_form → assignment.id_form_version
--   question.id_form → question.id_form_version

Esto garantizaría inmutabilidad por versión y trazabilidad histórica.
*/