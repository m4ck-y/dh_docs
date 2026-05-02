---
type: decision
id: 025
title: Static Test UI — Estándar para Endpoints de Prueba en Cada Microservicio
status: accepted
date: 2026-05-02
category: ui
layer: presentation
keywords: [static, ui, test, frontend, retro-terminal]
language: es
---

# ADR 025: Static Test UI — Interfaz de Prueba en Cada Microservicio

## Contexto

Cada microservicio del ecosistema Digital Hospital expone una API REST documentada via OpenAPI/Swagger en `/docs` y `/redoc`. Sin embargo:

- Swagger es funcional pero no muestra el flujo completo de interacción entre endpoints.
- Los equipos de frontend y mobile necesitan un sandbox visual rápido para probar combinaciones de endpoints sin curl ni Postman.
- En migraciones o adaptaciones (cambio de stack, nuevo cliente), tener una UI mínima acelera la validación.

Se requiere un estándar para que **cada microservicio** tenga una interfaz de prueba servida en su raíz (`GET /`).

## Decisión

Todo microservicio del ecosistema **debe incluir** una interfaz de prueba estática servida en `GET /`, montada via `FastAPI StaticFiles`.

### Requisitos

#### 1. Montaje

Archivos estáticos en `app/static/`, montados en `main.py`:

```python
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

app.mount("/static", StaticFiles(directory="app/static"), name="static")

@app.get("/", tags=["UI"])
async def root():
    return FileResponse("app/static/index.html")
```

#### 2. Archivos requeridos

| Archivo | Obligatorio | Propósito |
|---------|-------------|-----------|
| `app/static/index.html` | Sí | Página principal. Sin framework, HTML semántico. |
| `app/static/styles.css` | Sí | Tema visual (variables CSS). Separado del HTML. |
| `app/static/app.js` | Sí | Lógica del cliente. Clases POO (orientado a objetos). |
| `app/static/README.md` | Sí | Documentación de la UI: layout, elementos, acciones. |

#### 3. Estilo visual: Retro Terminal

Todas las UI de prueba deben usar el estilo **retro terminal cyberpunk** para mantener consistencia visual entre servicios. La paleta de colores estándar se define mediante variables CSS:

```css
:root {
    --font-body: 'VT323', 'Courier New', Courier, monospace;
    --color-bg: #0a0a0a;          /* Fondo principal */
    --color-panel: #0d0d0d;       /* Fondo de paneles */
    --color-green: #00ff88;       /* Verde neón — éxito, POST, texto */
    --color-cyan: #00d4ff;        /* Cian — GET, enlaces, headers */
    --color-purple: #aa66ff;      /* Púrpura — PUT, acentos */
    --color-pink: #ff44aa;        /* Rosa — acentos secundarios */
    --color-amber: #ffaa00;       /* Ámbar — PATCH, advertencias */
    --color-red: #ff4444;         /* Rojo — DELETE, errores */
    --color-dim: #555;            /* Gris tenue — paths, labels secundarios */
    --color-border: #00ff8822;    /* Borde sutil */
    --color-border-hi: #00ff8844; /* Borde resaltado */
}
```

**Colores por verbo HTTP** (aplicados via `data-verb` en botones):

| Verbo | Color | CSS |
|-------|-------|-----|
| `GET` | Cian | `button[data-verb="GET"] { border-color: var(--color-cyan); }` |
| `POST` | Verde | `button[data-verb="POST"] { border-color: var(--color-green); }` |
| `DELETE` | Rojo | `button[data-verb="DELETE"] { border-color: var(--color-red); }` |
| `PATCH` | Ámbar | `button[data-verb="PATCH"] { border-color: var(--color-amber); }` |
| `PUT` | Púrpura | `button[data-verb="PUT"] { border-color: var(--color-purple); }` |

#### 4. JavaScript orientado a clases

El archivo `app.js` debe usar **clases POO** para facilitar lectura y mantenimiento:

- `APIClient` — capa HTTP (get, post, req)
- Clase principal con el nombre del servicio (ej. `AuthUI`, `IamAdmin`, `AdminUI`) que orquesta la UI

```javascript
class APIClient {
    constructor(base = '') { this.base = base; }
    async req(method, path, body) { /* fetch wrapper */ }
    get(path) { return this.req('GET', path); }
    post(path, body) { return this.req('POST', path, body); }
}

class MiServicioUI {
    constructor() { /* bind events, load data */ }
    // métodos por sección: _bindLogin(), _bindProfile(), etc.
}
```

#### 5. README de la UI

Cada `app/static/README.md` debe documentar como mínimo:

- Propósito de cada archivo (`index.html`, `styles.css`, `app.js`)
- Diagrama ASCII del layout
- Descripción de cada sección y sus acciones
- Las variables CSS (para cambiar de tema/skin)
- Cómo se estructura el JS (clases, objeto global)

#### 6. README de la UI

Ejemplo de diagrama ASCII en el README:

```
+--------------------------------------------------+
| TOPBAR: [SERVICE NAME]  TAB1 | TAB2 | TAB3       |
+--------------------------------------------------+
| CONTENT (tab-switched section)                    |
|                                                   |
|  Panel: NAME                                      |
|    [input] [button]                               |
|    +--------+--------+--------+                   |
|    | COL1   | COL2   | COL3   |                   |
|    +--------+--------+--------+                   |
|                                                   |
+--------------------------------------------------+
| SIDE PANEL (slides from right)                    |
|  [inputs / selects / checkboxes]                  |
|  [CANCEL] [SAVE]                                  |
+--------------------------------------------------+
```

#### 7. Consideraciones adicionales

- **Sin dependencias externas**: No usar React, Vue, jQuery, ni CDNs. Solo HTML + CSS + JS vanilla.
- **Sin framework CSS**: El estilo se define exclusivamente en `styles.css` con custom properties.
- **Responsive mínimo**: La UI debe ser funcional en desktop. No se exige mobile-first.
- **Sin emojis**: Prohibido el uso de emojis en la UI (consistente con el estándar del proyecto).
- **Estado global**: La instancia principal del controlador debe asignarse a una variable global (ej. `let admin;`) para permitir acceso desde atributos `onclick` inline sin necesidad de rebindear eventos.
- **Singleton**: Una sola instancia de la clase principal creada en `DOMContentLoaded`.
- **Migración**: El README.md permite a cualquier desarrollador copiar la estructura a otro servicio cambiando solo endpoints + README, sin leer el código fuente completo.

## Consecuencias

- **Positivas**: UI de prueba inmediata en cada servicio, curva de aprendizaje cero para frontend/mobile, migración rápida a nuevos clientes, consistencia visual.
- **Negativas**: Mantenimiento del HTML/CSS/JS junto al backend. Se mitiga con el README y la separación de archivos.
- **Carga adicional**: Cada servicio requiere ~300 líneas entre HTML+CSS+JS. Es código de desarrollo/prueba, no de producción.

## Referencias

- Implementación de referencia: `dh_auth/app/static/` (login test) y `dh_iam/app/static/` (admin panel).
- ADR 022: ENDPOINTS.md — documentación complementaria de endpoints.
- ADR 024: UUIDs en API pública.
