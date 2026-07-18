> **Estado: BORRADOR**. Notas preliminares sobre el modelado de mediciones clinicas. Aun no formalizado en una ADR o task.

Tu flujo sería:

El endpoint recibe un code (ej: "heart_rate")
Buscas en MeasureType
Si no existe:
lo creas automáticamente
Luego guardas en Measurement usando ese id

Esto se llama “auto-registro de catálogo” (dynamic dictionary / self-healing schema)



Antes de permitir registros libres en Measurement, primero:

1. Cargas un catálogo estándar en MeasureType

Ejemplo:

code	name	system
8867-4	Heart rate	LOINC
8310-5	Body temperature	LOINC
8480-6	Systolic blood pressure	LOINC
8462-4	Diastolic blood pressure	LOINC




CREATE TABLE measure_type (
    id              SERIAL PRIMARY KEY,

    -- Código clínico o interno del concepto
    -- Ej: "8867-4" (LOINC Heart rate) o "heart_rate"
    code            VARCHAR(50) NOT NULL UNIQUE,

    -- Nombre base (idioma principal del sistema, normalmente EN)
    name            VARCHAR(100) NOT NULL,

    -- Traducciones UI (NO usado para lógica clínica)
    -- Ej:
    -- {
    --   "es": "Presión arterial",
    --   "fr": "Tension artérielle"
    -- }
    translations    JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Origen del concepto
    -- LOINC   → estándar clínico externo
    -- SNOMED  → estándar clínico externo
    -- INTERNAL→ validado por tu sistema (curado)
    -- CUSTOM  → creado por usuario o integración no validada
    system          VARCHAR(20) NOT NULL,

    -- Unidad por defecto (opcional)
    id_unit         INTEGER REFERENCES unit(id),

    -- Control de uso
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,

    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at      TIMESTAMP NULL,

    CONSTRAINT chk_measure_type_system
    CHECK (system IN ('LOINC', 'SNOMED', 'INTERNAL', 'CUSTOM'))
);

-- Índice para búsquedas rápidas por código
CREATE INDEX idx_measure_type_code ON measure_type(code);

-- Índice para filtros por tipo de sistema
CREATE INDEX idx_measure_type_system ON measure_type(system);

-- Índice GIN para traducciones (si en algún momento haces búsquedas UI)
CREATE INDEX idx_measure_type_translations
ON measure_type
USING GIN (translations);
## Flujo correcto

### Caso 1: LOINC / SNOMED

code = "8867-4"

### Caso 2: INTERNAL sin code

code = "heart_rate"

o si no lo mandan:

code = "internal_<uuid>"