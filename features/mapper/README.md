# Mapper (feature transversal)

## Problema que resuelve

Un `form` (cuestionario o historia clínica) guarda sus respuestas en `answer`.
Pero el valor de **algunas** preguntas también corresponde a una **propiedad
física de dominio** (`people`, `health_profile`, `clinical_history`, ...). El
mapper define ese vínculo (**binding**) `pregunta → propiedad` y lo resuelve en
**dos direcciones**:

- **Prefill (`read`)**: si el dominio ya tiene el valor, **autorrelenar** la
  pregunta antes de que el usuario conteste.
- **Write-through (`write`)**: al enviar, **persistir** el valor también en la
  propiedad de dominio.

Casos de uso: [`uses_cases/`](./uses_cases/README.md).

## Alcance

- **Solo preguntas** de un `form` (`source.form_key` + `question_key`).
- **NO** es mapper:
  - Opciones que vienen de un **catálogo** → `list_options.catalog` (en el form).
  - **Activadores** (respuesta de HC → instrumento) → `form.condition`.
  - **Scoring/interpretación** → `expression`.
- **Componentes de dominio** (A/B/D de historia clínica): **no** pasan por el
  mapper; tienen su **propio endpoint** que lee/escribe el dominio.

## Estructura

```
features/mapper/
├── README.md                 # este índice: problema, alcance, estructura
├── uses_cases/
│   └── README.md             # UC1 write-through · UC2 prefill
├── store/                    # store de bindings (schema por definir)
│   ├── README.md             # colección, campos, índices (borrador)
│   └── example.jsonc         # placeholder (pendiente)
└── examples/                 # propuestas de schema
    ├── binding.example.jsonc # un documento por binding
    └── form.example.jsonc    # un documento por form
```

## Estado

En **definición**. El **schema definitivo del store** está por evaluarse
(ver [`store/README.md`](./store/README.md) y [`examples/`](./examples/)).

## Depende de

- [`../questionnaires/`](../questionnaires/)
- [`../clinical_history/`](../clinical_history/)
