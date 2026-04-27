tablas relacionales reales, con filas como si ya estuvieras en PostgreSQL/MySQL.

Voy a usar este modelo mínimo:

🧱 TABLAS
person
id (UUID)	name
document_type
id	name
document

| id | person_id | document_type_id | status | issued_at | expires_at |

document_file

| id | document_id | side | url |

🧾 1. PERSON
id	name
per_100	Juan Pérez
per_200	María López
📚 2. DOCUMENT_TYPE
id	name
INE	Identificación INE
PROOF_OF_ADDRESS	Comprobante de domicilio
MEDICAL_HISTORY	Historia médica
CLINICAL_RECORD	Historia clínica
🇲🇽 3. DOCUMENT (REGISTROS REALES)
INE de Juan
id	person_id	document_type_id	status	issued_at	expires_at
doc_001	per_100	INE	APPROVED	2020-05-10	2030-05-10
Comprobante de domicilio de Juan
id	person_id	document_type_id	status	issued_at	expires_at
doc_002	per_100	PROOF_OF_ADDRESS	PENDING	2026-03-01	NULL
Historia médica de Juan
id	person_id	document_type_id	status	issued_at	expires_at
doc_003	per_100	MEDICAL_HISTORY	APPROVED	2025-12-01	NULL
Historia clínica de María
id	person_id	document_type_id	status	issued_at	expires_at
doc_004	per_200	CLINICAL_RECORD	APPROVED	2026-01-10	NULL
📁 4. DOCUMENT_FILE (ARCHIVOS)
INE Juan (FRONT + BACK)
id	document_id	side	url
file_001	doc_001	FRONT	https://cdn.app.com/ine/front_per_100.jpg

file_002	doc_001	BACK	https://cdn.app.com/ine/back_per_100.jpg
Comprobante domicilio (PDF único)
id	document_id	side	url
file_003	doc_002	SINGLE	https://cdn.app.com/bills/cfe_per_100.pdf
Historia médica (varios archivos)
id	document_id	side	url
file_004	doc_003	EXTRA	https://cdn.app.com/medical/lab_results.pdf

file_005	document_id	EXTRA	https://cdn.app.com/medical/diagnosis.pdf

file_006	document_id	EXTRA	https://cdn.app.com/medical/prescription.jpg
Historia clínica María
id	document_id	side	url
file_007	doc_004	EXTRA	https://cdn.app.com/clinical/consultation.pdf

file_008	doc_004	EXTRA	https://cdn.app.com/clinical/ultrasound.jpg
🧠 Lo importante que estás viendo
1. document = “concepto”

Ej:

INE
historia médica
comprobante
2. document_file = “contenido real”

Ej:

foto frente INE
PDF luz
estudios médicos
3. side te da flexibilidad total
side	significado
FRONT	frente INE
BACK	reverso INE
SINGLE	documento único
EXTRA	anexos médicos
🔥 Query típica en SQL
Obtener INE de Juan
SELECT d.*, f.*
FROM document d
JOIN document_file f ON f.document_id = d.id
WHERE d.person_id = 'per_100'
AND d.document_type_id = 'INE';
🚀 Conclusión

✔ Esto ya es diseño real de producción
✔ Escala a KYC, salud, gobierno o fintech
✔ No necesitas Mongo para esto
✔ Los joins son simples y controlables