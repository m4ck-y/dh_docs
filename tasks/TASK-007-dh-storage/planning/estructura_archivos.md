# Estructura de Archivos en Disco

## Jerarquia

```
storage/
└── people/
    └── {uuid_person}/
        ├── photos/
        │   ├── {timestamp}_{hash_6}_raw.{ext}
        │   ├── {timestamp}_{hash_6}_800.{ext}
        │   └── {timestamp}_{hash_6}_200.{ext}
        └── documents/
            └── {document_type_slug}/
                └── {document_subtype_slug}/
                    └── {timestamp}_{hash_6}_{side}.{ext}
```

## Convenciones

| Elemento | Formato | Ejemplo |
|----------|---------|---------|
| `uuid_person` | UUID con guiones (formato estandar) | `550e8400-e29b-41d4-a716-446655440000` |
| `timestamp` | ISO 8601 compacto UTC | `20260504T221530Z` |
| `hash_6` | 6 caracteres hex del sha256 del contenido | `a3f2b1` |
| `ext` | Extension original del archivo | `jpg`, `pdf` |
| `side` | Valor lowercase del enum `EDocumentSide` | `front`, `back`, `single`, `extra` |
| `document_type_slug` | `document_type.name` lowercased + underscored | `identifier`, `medical` |
| `document_subtype_slug` | `document_subtype.name` lowercased + underscored | `national_id`, `passport` |

## Ejemplo concreto

```
storage/people/550e8400-e29b-41d4-a716-446655440000/
├── photos/                                                  ← gestionado por dh_core (people.photo)
│   ├── 20260504T221530Z_a3f2b1_raw.jpg
│   ├── 20260504T221530Z_a3f2b1_800.jpg
│   └── 20260504T221530Z_a3f2b1_200.jpg
└── documents/                                               ← gestionado por dh_storage (storage.*)
    └── identifier/
        └── national_id/
            ├── 20260504T221530Z_b4c5d6_front.jpg
            └── 20260504T221531Z_e7f8a9_back.jpg
```

- Photos comparten `{timestamp}_{hash_6}` porque los 3 tamanos derivan de la misma imagen subida.
- Documents usan `_{side}` en el nombre para ser autodescriptivos sin subcarpetas adicionales.
- `photos/` es **exclusivamente para fotografias de perfil del `person`** — gestionado por `dh_core`.
- `documents/` almacena archivos de expediente — gestionado por `dh_storage`.

## Path en BD

`document_file.url` almacena la ruta relativa desde la raiz de storage:

```
people/550e8400-e29b-41d4-a716-446655440000/documents/identifier/national_id/20260504T221530Z_b4c5d6_front.jpg
```

## Justificacion

| Criterio | Solucion |
|----------|----------|
| Busqueda por persona | `uuid_person` como raiz |
| Separacion fotos/documentos | `photos/` vs `documents/` — dominios distintos |
| Side en el nombre | `_{side}.ext` — autodescriptivo, sin subcarpetas condicionales |
| 3 tamanos de foto | Mismo `{timestamp}_{hash_6}` con sufijo `_raw|_800|_200` (pixeles) |
| Organizacion por tipo | `{type}/{subtype}` replica la jerarquia de catalogos |
| Anti-colision | `{timestamp}_{hash_6}` garantiza unicidad |
| Migracion a GCS | Ruta relativa identica en disco o bucket |
