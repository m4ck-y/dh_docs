CREATE TABLE person_responsible (
    id SERIAL PRIMARY KEY,
    -- Identificador único de la relación

    dependent_id INT NOT NULL,
    -- Persona que depende del responsable (paciente / usuario)

    responsible_id INT NOT NULL,
    -- Persona que actúa como responsable o tutor

    type_relationship relationship_enum NOT NULL,
    -- Tipo de relación entre ambos (madre, padre, tutor, etc.)

    care_role care_role_enum NOT NULL,
    -- Rol del responsable en el cuidado

    other_relationship VARCHAR(100),
    -- Descripción adicional si la relación es 'OTHER'

    CONSTRAINT fk_dependent
        FOREIGN KEY (dependent_id) REFERENCES person(id),

    CONSTRAINT fk_responsible
        FOREIGN KEY (responsible_id) REFERENCES person(id)
);



CREATE TYPE relationship_enum AS ENUM (
    'MOTHER',
    'FATHER',
    'CAREGIVER',
    'LEGAL_GUARDIAN', #TUTOR legal, no deberia ir en     legal_info {i que sea un fk a person.id?}
    'OTHER'
);


CREATE TYPE care_role_enum AS ENUM (
    'LIVES_WITH_AND_CARES',
    'CARES_NOT_LIVING_WITH',
    'ADMINISTRATIVE_SUPPORT_ONLY'
);