**Proyecto o Apartado:** Infraestructura — Entorno de desarrollo (`libersalus.dev`, repo `docs_devops`)

**Título de la actividad o tarea:** Configuración del VPS de desarrollo con dominio público y creación de los scripts de acceso y web

**Descripción de la actividad o tarea:** Se estableció un **entorno de desarrollo** aislado sobre un VPS (AWS), con **dominio público propio** (`libersalus.dev`). El objetivo de negocio es disponer de un ambiente controlado para desplegar y probar la plataforma sin afectar producción y con **certificados TLS reales**.

Anteriormente, la demostración del frontend se desplegaba mediante **GitHub Pages**. Si bien es una opción sencilla y sin costo, presenta una **limitación de fondo**: solo sirve **contenido estático**, sin backend ni servicios. Por ello **no** permite concentrar los componentes de la plataforma (API, base de datos, servicios) en un solo lugar ni reproducir la **interconectividad** real entre ellos; en consecuencia, el comportamiento extremo a extremo **no puede probarse de forma completa**.

Para superar esa limitación se optó por **preparar un entorno de desarrollo propio**, con un **servidor dedicado** y un **dominio**, que permite disponer de una **base de datos central** al servicio de clientes y usuarios, y validar la **integración real** del sistema antes de producción.

El hecho de que el dominio de desarrollo sea **público** permite que el entorno sea **accesible desde cualquier ubicación** (no depende de una red interna ni de una red corporativa). A la vez, al residir en un **dominio propio y separado del entorno de producción** (`libersalus.com`), el trabajo en curso **no se expone** en el sitio oficial: las versiones que aún están en desarrollo se despliegan en `libersalus.dev`, de modo que la página pública de Libersalus **no muestra** lo que está en construcción.

A diferencia de una configuración con **dominio local** (resuelto por un DNS interno y firmado con una CA propia), aquí el dominio es **público y propio**, lo que permite emitir certificados válidos con **Certbot / Let's Encrypt** (validación HTTP-01). Esto evita distribuir una CA interna a los equipos y simplifica la operación.

Para automatizar el aprovisionamiento se creó una estructura de **scripts por fases** (`00_vps` → `01_web` → `02_vpn` → `03_docker` → `04_postgres`). El bloque inicial cubre dos fases:

- **`00_vps` (acceso):** creación de los usuarios del VPS — `github_dev` (solo Git) y `libersalus` (administrador con `sudo`) —, alta de la **deploy key** y clonado del repositorio. El acceso SSH se resuelve por **clave** (no por contraseña).
- **`01_web`:** instalación de **nginx** y emisión del certificado con **Certbot** para `libersalus.dev`, sirviendo el HTML del entorno por **HTTPS**.

El propósito de fondo de estos scripts es **operativo y económico**. Para ello se parte de una **cuenta de AWS creada específicamente** para el entorno de desarrollo, con el fin de **aprovechar su capa gratuita (free tier) y sus créditos** (criterio extensible a otros proveedores de nube). Al automatizar el aprovisionamiento y la **migración** entre proveedores/instancias, se evitan las **configuraciones manuales y laboriosas** que consumen tiempo, de forma que el entorno puede **recrearse rápidamente** cuando se agota el periodo de prueba o los créditos de un proveedor — con **gasto cero**.

Los **secretos** se separan por naturaleza: las **privadas** residen en `secrets/` (excluida del repositorio) y las **públicas** se versionan en `static/`. Las llaves se generan **una sola vez** y se **reutilizan** en cada reconstrucción del VPS.

**Estado de la actividad o tarea:** En desarrollo

**Avances de la actividad:**
- Estructura de scripts por fases creada (`scripts/00_vps`, `scripts/01_web`), con README por fase.
- `00_vps`: usuario `github_dev` (deploy key + clone) y usuario `libersalus` (admin); alta de clave pública en `authorized_keys`.
- `01_web`: nginx + Certbot (HTTP-01) para `libersalus.dev`.
- Generación y separación de secretos (`secrets/` privadas · `static/` públicas): 3 pares SSH (admin PC→VPS, VPS→GitHub, Actions→VPS).
- Configuración del **DNS** del dominio en Hostinger (registro `A` apuntando al VPS).
- Página del entorno publicada (`static/libersalus_dev_enviroment.html`).
- **Pruebas realizadas:** acceso SSH con la clave de admin, sitio servido por el dominio, `git pull` en el VPS mediante la deploy key.
