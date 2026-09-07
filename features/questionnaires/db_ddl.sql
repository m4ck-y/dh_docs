-- ===================================================================
-- TIPOS DE ENUMERACIÓN
-- ===================================================================
-- Se crean tipos ENUM para los campos status
CREATE TYPE assignment_status_type AS ENUM ('DISABLED', 'ENABLED', 'IN_PROGRESS', 'COMPLETED');

-- Tipos de pregunta (alineado con EQuestionType del ERD)
CREATE TYPE question_type AS ENUM (
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
CREATE TYPE biological_sex AS ENUM ('HOMBRE', 'MUJER', 'INTERSEXUAL');

-- Tipo de recurso enlazado (alineado con EUrlType del ERD)
CREATE TYPE url_type AS ENUM ('LINK', 'FILE', 'IMAGE');

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
    question_type question_type NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE question IS 'Pregunta individual reutilizable. Se vincula a formularios mediante questions_form y a secciones mediante questions_section. Permite validar respuestas y definir su comportamiento.';

COMMENT ON COLUMN question.key IS 'Identificador único de la pregunta (ej. "satisfaction_rating"). Se usa en las expresiones de scoring/evaluación y en las respuestas.';

COMMENT ON COLUMN question.question_type IS 'Tipo de pregunta segun el enum question_type: TEXT, TEXT_LONG, NUMBER, SINGLE_CHOICE, MULTIPLE_CHOICE, DATE, DATE_TIME, TIMER.';

COMMENT ON COLUMN question."order" IS 'Orden de presentacion de la pregunta dentro de su contexto (formulario o seccion).';

-- ===================================================================
-- TABLA: section
-- Agrupacion logica de preguntas dentro de un formulario.
-- ===================================================================
CREATE TABLE section (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    "order" INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE section IS 'Seccion de un formulario. Agrupa preguntas que se presentan juntas.';

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
    type url_type NOT NULL
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
    type_biological_sex biological_sex NOT NULL
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
    type_media url_type
);

COMMENT ON TABLE reference IS 'Referencia externa del formulario (articulo, guia, archivo).';

-- ===================================================================
-- TABLA: assignment
-- Representa la asignación lógica de un formulario a una persona o entidad.
-- NOTA: La persona asignada (id_person) NO tiene por qué ser quien responde.
-- Esto permite escenarios como:
--   • Un tutor responde por un estudiante.
--   • Un gerente asigna una autoevaluación a su equipo (pero cada uno responde por sí mismo).
--   • Un sistema asigna a un grupo, y luego un representante responde.
-- 
-- GESTIÓN DE REASIGNACIONES: Un usuario puede tener múltiples asignaciones al mismo formulario
-- en diferentes momentos. Cada nueva asignación crea un registro independiente en esta tabla.
-- Ejemplo: Juan puede tener asignación 1 (enero 2024), asignación 2 (febrero 2024) para el mismo formulario.
-- 
-- RESULTADOS POR ASIGNACIÓN: Almacena los resultados definitivos de la asignación,
-- basados en el último intento completado (status = 'COMPLETED').
-- 
-- PROGRESO POR ASIGNACIÓN: También puede almacenar el progreso actual de la asignación
-- para mostrar en interfaces de usuario sin necesidad de cálculos complejos.
-- 
-- CÁLCULO DE RESULTADOS: Los campos scoring_result y evaluation_result se calculan
-- automáticamente cuando n_questions_answered = n_questions_total y el intento asociado
-- tiene status = 'COMPLETED'.
--
-- IMPORTANTE: Esta tabla actúa como REGISTRO MAESTRO de participación usuario-formulario.
-- Se crea tanto para flujos PROGRAMADOS (con scheduled) como para flujos DIRECTOS (por enlace público).
-- Esto permite consultar fácilmente: "¿qué formularios ha contestado X?" en un solo lugar.
-- ===================================================================
CREATE TABLE assignment (
    id SERIAL PRIMARY KEY,
    id_form INTEGER NOT NULL REFERENCES form(id) ON DELETE CASCADE,
    id_person INTEGER NOT NULL,
    status assignment_status_type NOT NULL DEFAULT 'ENABLED',
    -- Progreso actual de la asignación
    n_questions_total INTEGER,                    -- Total de preguntas del formulario
    n_questions_answered INTEGER DEFAULT 0,       -- Preguntas respondidas en intento activo actual
    -- Resultados definitivos de la asignación
    scoring_result JSONB,                       -- Resultado definitivo del cálculo de puntaje
    evaluation_result JSONB                     -- Resultado definitivo de la evaluación cualitativa
);

COMMENT ON TABLE assignment IS 'Asignación lógica de un formulario a una persona o entidad (id_person). NO implica que esa persona responda directamente. Sirve para control de acceso, notificaciones y trazabilidad organizacional. GESTIÓN DE REASIGNACIONES: Esta tabla permite que un usuario tenga múltiples asignaciones del mismo formulario en diferentes momentos. Cada asignación es independiente y puede tener su propio historial de respuestas. RESULTADOS POR ASIGNACIÓN: Almacena los resultados definitivos (puntaje y evaluación) asociados a esta asignación específica, permitiendo comparar rendimiento entre diferentes asignaciones del mismo formulario a la misma persona. PROGRESO: También almacena el progreso actual para optimizar consultas de interfaces de usuario.';

COMMENT ON COLUMN assignment.id_person IS 'ID de la persona, estudiante, empleado o entidad a quien se le "asigna" el formulario. Puede ser distinto del usuario que responde (ver response.id_responder_user). Ej: un alumno (id_person=123) recibe una evaluación, pero su tutor (id_responder_user=456) la completa.';

COMMENT ON COLUMN assignment.status IS 'Estado de la asignación basado en el enum EAssignmentStatus: "DISABLED", "ENABLED", "IN_PROGRESS", "COMPLETED". Útil para gestionar flujos sin eliminar registros. En caso de reasignaciones, las asignaciones anteriores pueden mantenerse con status "COMPLETED" o "DISABLED" para mantener historial.';

COMMENT ON COLUMN assignment.n_questions_total IS 'Total de preguntas del formulario asignado. Se calcula al crear la asignación y se usa para calcular progreso.';

COMMENT ON COLUMN assignment.n_questions_answered IS 'Cantidad de preguntas respondidas en el intento activo actual. Se actualiza en tiempo real a medida que el usuario responde preguntas. Permite mostrar progreso sin cálculos complejos.';

COMMENT ON COLUMN assignment.scoring_result IS 'Resultado definitivo del cálculo de puntaje para esta asignación. Se calcula automáticamente cuando n_questions_answered = n_questions_total y el intento asociado tiene status = ''COMPLETED''. Contiene el puntaje final basado en el último intento completado. Ejemplo: {"final_score": 85, "calculation_method": "last_completed", "calculation_timestamp": "2024-01-15T10:30:00Z"}';

COMMENT ON COLUMN assignment.evaluation_result IS 'Resultado definitivo de la evaluación cualitativa para esta asignación. Se calcula automáticamente cuando n_questions_answered = n_questions_total y el intento asociado tiene status = ''COMPLETED''. Contiene la clasificación final basada en scoring_result del último intento completado. Ejemplo: {"category": "aprobado", "level": "alto", "description": "Excelente desempeño", "evaluation_timestamp": "2024-01-15T10:30:00Z"}';

-- ===================================================================
-- TABLA: scheduled
-- Define cuándo y por cuánto tiempo está disponible una asignación para ser respondida.
-- Cada programación permite uno o más intentos (response).
-- 
-- RELACIÓN CON REASIGNACIONES: Cada assignment puede tener uno o más scheduled, permitiendo
-- múltiples ventanas de tiempo para responder el mismo formulario asignado.
--
-- NOTA: Solo las asignaciones de tipo "programado" tienen filas en esta tabla.
-- Las asignaciones de tipo "directo" (por enlace) NO tienen scheduled.
-- ===================================================================
CREATE TABLE scheduled (
    id SERIAL PRIMARY KEY,
    id_assignment INTEGER NOT NULL REFERENCES assignment(id) ON DELETE CASCADE,
    id_admin INTEGER NOT NULL,
    available_from TIMESTAMP NOT NULL,
    available_until TIMESTAMP NOT NULL,
    time_limit_minutes INTEGER,
    CHECK (available_from <= available_until),
    CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0)
);

COMMENT ON TABLE scheduled IS 'Programación de la disponibilidad de una asignación. Define la ventana de tiempo en la que se puede iniciar una respuesta y el límite de duración por intento. GESTIÓN DE REASIGNACIONES: Un assignment puede tener múltiples scheduled, permitiendo reprogramar la disponibilidad del formulario para la misma persona.';

COMMENT ON COLUMN scheduled.id_admin IS 'ID del administrador o sistema que programó esta disponibilidad. Útil para auditoría.';

COMMENT ON COLUMN scheduled.time_limit_minutes IS 'Tiempo máximo permitido desde que se inicia una respuesta (started_at) hasta que debe enviarse (submitted_at). Si es NULL, no hay límite.';

-- ===================================================================
-- TABLA: response
-- Representa un intento concreto de responder un formulario.
-- 
-- DISEÑO ACTUAL:
--   - Esta tabla es NEUTRA: no sabe si la respuesta es directa o programada.
--   - La vinculación con el origen (directo o programado) se gestiona mediante:
--       • form_direct_responses → para respuestas directas
--       • scheduled_responses   → para respuestas programadas
-- 
-- Esto permite:
--   - Reutilizar toda la lógica de respuesta (metadatos, estado, fechas) en ambos flujos.
--   - Evitar duplicación de estructuras.
--   - Consultar fácilmente "todas las respuestas de un usuario", sin importar el origen.
-- ===================================================================
CREATE TABLE response (
    id SERIAL PRIMARY KEY,
    id_responder_user INTEGER NOT NULL,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    submitted_at TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    attempt_number INTEGER DEFAULT 1,    -- Número de intento (por contexto: directo o programado)
    CHECK (completed_at IS NULL OR started_at <= completed_at),
    CHECK (submitted_at IS NULL OR (completed_at IS NOT NULL AND completed_at <= submitted_at))
);

COMMENT ON TABLE response IS 'Intento individual de completar un formulario, sin importar su origen (directo o programado). La vinculación con el contexto (assignment/scheduled) se gestiona mediante las tablas intermedias form_direct_responses y scheduled_responses. Esto permite un modelo unificado y extensible.';

COMMENT ON COLUMN response.id_responder_user IS 'ID del usuario que REALMENTE completó y envió el formulario. Puede ser distinto de assignment.id_person (ej. tutor, representante, delegado).';

COMMENT ON COLUMN response.started_at IS 'Momento en que el usuario abrió el formulario para responder.';

COMMENT ON COLUMN response.completed_at IS 'Momento en que el usuario marcó el formulario como "completo" (puede guardar progreso sin enviar).';

COMMENT ON COLUMN response.submitted_at IS 'Momento en que el usuario envió oficialmente el formulario. Solo entonces se considera válido para cálculo de resultados.';

COMMENT ON COLUMN response.status IS 'Estado del intento: "active" (en progreso), "completed" (completado pero no enviado), "submitted" (enviado), "abandoned" (abandonado).';

COMMENT ON COLUMN response.attempt_number IS 'Número de intento dentro de su contexto (directo o programado). En flujos directos, normalmente será 1. En flujos programados, permite reintentos.';

-- ===================================================================
-- TABLA: answer
-- Almacena la respuesta a una pregunta específica dentro de un intento (response).
-- El valor se guarda en JSONB para soportar múltiples tipos de datos.
-- 
-- RELACIÓN CON REINTENTOS: Las respuestas están asociadas a responses específicos,
-- permitiendo que cada intento tenga sus propias respuestas independientes.
-- 
-- NOTA: La validación del tipo de dato en "value" (ej. que coincida con question_type)
-- debe realizarse a nivel de API (por ejemplo, con Pydantic en Python) antes de insertar.
-- ===================================================================
CREATE TABLE answer (
    id SERIAL PRIMARY KEY,
    id_response INTEGER NOT NULL REFERENCES response(id) ON DELETE CASCADE,
    id_question INTEGER NOT NULL REFERENCES question(id) ON DELETE CASCADE,
    value JSONB NOT NULL,
    CHECK (value ? 'type' AND value ? 'value')
);

COMMENT ON TABLE answer IS 'Respuesta individual a una pregunta en un intento específico. El valor se normaliza en JSONB para flexibilidad. GESTIÓN DE REINTENTOS: Las respuestas están asociadas a responses específicos, lo que permite que cada intento tenga sus propias respuestas independientes, facilitando el historial de respuestas por intento.';

COMMENT ON COLUMN answer.value IS 'Estructura normalizada: {"type": "string|number|boolean|array", "value": ...}. Ejemplos:
  - Texto: {"type": "text", "value": "Muy satisfecho"}
  - Número: {"type": "number", "value": 9.5}
  - Opción múltiple: {"type": "array", "value": ["opc1", "opc3"]}
  Esta estructura permite procesar respuestas de forma genérica y segura.
  ⚠️ La coherencia entre el tipo de respuesta y el question_type debe validarse en la capa de aplicación (ej. con Pydantic).';

-- ===================================================================
-- TABLA: form_direct_responses
-- Vincula una ASSIGNMENT de tipo "directo" (sin programación) con su respuesta.
-- Se usa cuando un usuario accede al formulario mediante un enlace público (estilo Google Forms).
-- 
-- RESTRICCIÓN CLAVE:
--   - La assignment referenciada NO debe tener ninguna fila en "scheduled".
--   - Cada assignment directa tiene exactamente UNA respuesta (1:1).
-- 
-- CASO DE USO:
--   - Usuario entra a /form/abc123 → se crea assignment (id_person = X).
--   - Al enviar, se crea response Y, y se registra (X, Y) aquí.
-- ===================================================================
CREATE TABLE form_direct_responses (
    id_assignment INTEGER NOT NULL REFERENCES assignment(id) ON DELETE CASCADE,
    id_response INTEGER NOT NULL REFERENCES response(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_assignment, id_response)
);

COMMENT ON TABLE form_direct_responses IS 'Asociación 1:1 entre una asignación de tipo "directo" (sin programación) y su única respuesta. Permite soportar flujos estilo Google Forms manteniendo assignment como registro maestro de participación.';

COMMENT ON COLUMN form_direct_responses.id_assignment IS 'Asignación creada automáticamente al acceder al formulario por enlace público. Debe NO tener filas en la tabla "scheduled".';
COMMENT ON COLUMN form_direct_responses.id_response IS 'Respuesta concreta realizada sin programación previa.';

-- ===================================================================
-- TABLA: scheduled_responses
-- Vincula explícitamente una programación (scheduled) con una respuesta (response).
-- Permite múltiples respuestas por scheduled (reintentos).
-- 
-- CASO DE USO:
--   - Un administrador programa un formulario (scheduled S para assignment A).
--   - El usuario responde 2 veces → se crean responses R1 y R2.
--   - Se registran (S, R1) y (S, R2) en esta tabla.
-- ===================================================================
CREATE TABLE scheduled_responses (
    id_scheduled INTEGER NOT NULL REFERENCES scheduled(id) ON DELETE CASCADE,
    id_response INTEGER NOT NULL REFERENCES response(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_scheduled, id_response)
);

COMMENT ON TABLE scheduled_responses IS 'Vinculación entre una programación (scheduled) y un intento de respuesta. Soporta múltiples intentos (reintentos) por programación.';

COMMENT ON COLUMN scheduled_responses.id_scheduled IS 'Programación que habilitó esta respuesta.';
COMMENT ON COLUMN scheduled_responses.id_response IS 'Intento concreto de respuesta asociado a la programación.';

-- ===================================================================
-- ÍNDICES PARA RENDIMIENTO
-- ===================================================================
CREATE INDEX idx_assignment_form_person ON assignment (id_form, id_person);
CREATE INDEX idx_answer_response ON answer (id_response);
CREATE INDEX idx_question_key ON question (key);
CREATE INDEX idx_section_form ON section (id_form);
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

-- Índices para las tablas de relación de ejecucion
CREATE INDEX idx_form_direct_responses_assignment ON form_direct_responses (id_assignment);
CREATE INDEX idx_form_direct_responses_response ON form_direct_responses (id_response);
CREATE INDEX idx_scheduled_responses_scheduled ON scheduled_responses (id_scheduled);
CREATE INDEX idx_scheduled_responses_response ON scheduled_responses (id_response);

-- Índices adicionales sugeridos
CREATE INDEX idx_assignment_status_person ON assignment (status, id_person);
CREATE INDEX idx_scheduled_time_window ON scheduled (available_from, available_until);
CREATE INDEX idx_response_user_status ON response (id_responder_user, status);
CREATE INDEX idx_response_submitted_at ON response (submitted_at);

-- ===================================================================
-- TRIGGERS PARA GARANTIZAR EXCLUSIÓN LÓGICA ENTRE FLOWS
-- ===================================================================

-- Trigger para evitar insertar en scheduled si la assignment ya está en form_direct_responses
CREATE OR REPLACE FUNCTION check_assignment_scheduled_exclusivity_insert_scheduled()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM form_direct_responses fdr
        WHERE fdr.id_assignment = NEW.id_assignment
    ) THEN
        RAISE EXCEPTION 'Cannot schedule an assignment (id_assignment=%): it is already linked to a direct response.', NEW.id_assignment;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_check_assignment_scheduled_insert
    BEFORE INSERT ON scheduled
    FOR EACH ROW EXECUTE FUNCTION check_assignment_scheduled_exclusivity_insert_scheduled();

-- Trigger para evitar actualizar scheduled si la assignment ya está en form_direct_responses
CREATE OR REPLACE FUNCTION check_assignment_scheduled_exclusivity_update_scheduled()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo se chequea si el id_assignment cambia
    IF OLD.id_assignment IS DISTINCT FROM NEW.id_assignment THEN
        IF EXISTS (
            SELECT 1 FROM form_direct_responses fdr
            WHERE fdr.id_assignment = NEW.id_assignment
        ) THEN
            RAISE EXCEPTION 'Cannot update scheduled assignment (id_assignment=%): it is already linked to a direct response.', NEW.id_assignment;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_check_assignment_scheduled_update
    BEFORE UPDATE ON scheduled
    FOR EACH ROW EXECUTE FUNCTION check_assignment_scheduled_exclusivity_update_scheduled();

-- Trigger para evitar insertar en form_direct_responses si la assignment ya tiene scheduled
CREATE OR REPLACE FUNCTION check_assignment_direct_exclusivity_insert_fdr()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM scheduled s
        WHERE s.id_assignment = NEW.id_assignment
    ) THEN
        RAISE EXCEPTION 'Cannot link assignment (id_assignment=%) to a direct response: it already has scheduled availability.', NEW.id_assignment;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_check_assignment_direct_insert
    BEFORE INSERT ON form_direct_responses
    FOR EACH ROW EXECUTE FUNCTION check_assignment_direct_exclusivity_insert_fdr();

-- Trigger para evitar actualizar form_direct_responses si la assignment ya tiene scheduled
CREATE OR REPLACE FUNCTION check_assignment_direct_exclusivity_update_fdr()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo se chequea si el id_assignment cambia
    IF OLD.id_assignment IS DISTINCT FROM NEW.id_assignment THEN
        IF EXISTS (
            SELECT 1 FROM scheduled s
            WHERE s.id_assignment = NEW.id_assignment
        ) THEN
            RAISE EXCEPTION 'Cannot update direct response link (id_assignment=%): the assignment already has scheduled availability.', NEW.id_assignment;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_check_assignment_direct_update
    BEFORE UPDATE ON form_direct_responses
    FOR EACH ROW EXECUTE FUNCTION check_assignment_direct_exclusivity_update_fdr();

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

/*
VALIDACIÓN DE INTEGRIDAD:

Los triggers definidos anteriormente garantizan que una assignment no sea usada en ambos flujos (directo y programado):

1. Si una assignment tiene filas en "scheduled", NO puede aparecer en "form_direct_responses".
2. Si una assignment aparece en "form_direct_responses", NO puede tener filas en "scheduled".

Esto evita inconsistencias lógicas en el modelo.
*/