# Estructura de Archivos

## Propuesta

Almacenamiento en GCS/disk:

```
/expedient/
└── {id_person}/
    └── {category_name}/
        └── {subtype_name}/
            └── {uuid}_{timestamp}.{extension}
```

### Ejemplo

```
/expedient/
└── 12345/
    └── Identificación/
        └── INE/
            ├── abc1234d-5678-9012-3456-7890abcdef_20260426T103000Z.pdf
            └── def5678a-9012-3456-7890-abcdef123456_20260426T103045Z.jpg
```

##justificación

| Criterio | Estructura propuesta |
|----------|-------------------|
|Búsqueda por usuario|id_person como primer nivel|
|Búsqueda por tipo|category_name como segundo nivel|
|Optimización|cada archivo tiene UUID único para evitar colisiones|
|Ordenamiento|timestamp ISO 8601 permite sorting alfabético|
|Extension|se preserva para content-type|

## Variantes evaluadas

| Estructura | Pros | Contras |
|-----------|------|--------|
|`{id_person}/{timestamp}`|Simple|No agrupa por tipo|
|`{year}/{month}/{id_person}/{type}`|Buena para archival|No funciona bien para queries por tipo|
|`{hash_first_2}/{hash_rest}/{filename}`|Anti-duplicados|No agrupa por usuario|
|**Propuesta**|Balance óptimo|Más directorios|