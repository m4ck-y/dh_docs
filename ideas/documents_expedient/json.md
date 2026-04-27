📄 DOCUMENT (actualizado)

🧱 1. DOCUMENT_TYPE (tabla faltante corregida)
CREATE TABLE document_type (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

Ejemplos de datos:

INE
PROOF_OF_ADDRESS
MEDICAL_HISTORY
CLINICAL_RECORD
CREATE TABLE document (
    id UUID PRIMARY KEY,
    person_id UUID NOT NULL,
    document_type_id UUID NOT NULL,

    status VARCHAR(20) NOT NULL CHECK (
        status IN ('PENDING', 'APPROVED', 'REJECTED')
    ),

    issued_at DATE,
    expires_at DATE,

    -- tamaño total en bytes de todos los archivos
    size_bytes_total BIGINT DEFAULT 0,

    -- archivos en formato JSONB
    files JSONB NOT NULL,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT fk_document_type
        FOREIGN KEY (document_type_id)
        REFERENCES document_type(id)
);
🗂 JSON (FILES) actualizado
{
  "files": [
    {
      "id": "uuid-file-1",
      "side": "FRONT",
      "url": "https://cdn.app.com/ine/front.jpg",
      "size_bytes": 245678
    },
    {
      "id": "uuid-file-2",
      "side": "BACK",
      "url": "https://cdn.app.com/ine/back.jpg",
      "size_bytes": 198432
    }
  ]
}
🧠 Nota de diseño (importante)

Este naming (size_bytes_total) es bueno porque:

✔ es autoexplicativo (no hay dudas de unidad)
✔ es consistente con size_bytes por archivo
✔ escala bien si luego agregas:
size_bytes_images
size_bytes_ocr
size_bytes_original
🚀 Conclusión

✔ size_bytes_total es el nombre correcto
✔ más claro que size_total
✔ evita errores en sistemas distribuidos o storage externo