-- Sugerencia: Extender tabla `document` en PostgreSQL (schema expedient)
-- Para soportar upload, download y review en dh_expedient

ALTER TABLE expedient.document
ADD COLUMN storage_provider VARCHAR(20) NOT NULL DEFAULT 'gcs',
ADD COLUMN file_path VARCHAR(500) NOT NULL,
ADD COLUMN original_filename VARCHAR(255) NOT NULL,
ADD COLUMN content_type VARCHAR(100),
ADD COLUMN size_bytes INTEGER NOT NULL DEFAULT 0,
ADD COLUMN uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),
ADD COLUMN reviewed BOOLEAN NOT NULL DEFAULT FALSE,
ADD COLUMN review_notes TEXT,
ADD COLUMN reviewer_id UUID REFERENCES auth.users(id);

-- Índices
CREATE INDEX idx_document_storage_provider ON expedient.document(storage_provider);
CREATE INDEX idx_document_uploaded_at ON expedient.document(uploaded_at);
CREATE INDEX idx_document_reviewed ON expedient.document(reviewed);