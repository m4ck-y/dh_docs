**Proyecto o Apartado:** Frontend web de Libersalus — Infraestructura de despliegue y modo demo (`lsinciosesionweb`)

**Título de la actividad o tarea:** Creación de workflow de GitHub Pages, configuración de modo demo para despliegue y corrección de rutas de basename

**Descripción de la actividad o tarea:** Se implementó la infraestructura de despliegue continuo para el frontend de Libersalus utilizando GitHub Actions y GitHub Pages. El objetivo de negocio es permitir la demostración de la plataforma en un entorno público sin necesidad de servidores dedicados, facilitando accesos para stakeholders, clientes potenciales y pruebas internas.

En primer lugar, se creó un workflow de GitHub Actions (`deploy.yml`) que se ejecuta automáticamente en cada push a la rama `dev-questionnaires`. El workflow detecta el nombre del repositorio de forma dinámica (`github.event.repository.name`) para configurar la variable `VITE_BASE` correctamente, permitiendo que el mismo workflow funcione para múltiples repositorios (registro, dashboard, etc.).

En segundo lugar, se implementó el modo demo para GitHub Pages mediante la variable de entorno `VITE_DEMO`. Cuando el push se realiza a una rama diferente a `main`, `VITE_DEMO` se establece automáticamente en `true`, activando la pantalla de selección de persona demo y el flujo de autenticación offline. Esto permite que la demo pública muestre la funcionalidad completa sin depender del backend.

En tercer lugar, se corrigió el basename del router de React Router. Anteriormente estaba hardcodeado como `/panel`, lo que causaba errores 404 en GitHub Pages. Se actualizó para usar `import.meta.env.VITE_BASE` de manera dinámica, eliminando la barra diagonal final para compatibilidad con React Router.

En cuarto lugar, se mejoró la UI del modal de selección de demo con glassmorphism, iconos SVG personalizados y colores pastel por perfil (lavanda para María, aguamarina para Juan, durazno para Rosa, esmeralda para Sofía). Se corrigió la alineación de las cards del modal que quedaban desplazadas a la izquierda por conflicto de estilos CSS.

En quinto lugar, se ajustó la pantalla de selección de persona demo para que la última fila con un solo elemento aparezca centrada utilizando flexbox con `justify-content: center`.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad:**
- Workflow `deploy.yml` creado en `.github/workflows/` con trigger `push` a `dev-questionnaires`.
- `VITE_BASE` configurado dinámicamente con `github.event.repository.name`.
- `VITE_DEMO` se activa automáticamente en ramas que no son `main`.
- React Router basename actualizado para usar `VITE_BASE` desde variable de entorno.
- Modal de selección de demo mejorado con glassmorphism y colores pastel.
- Cards del modal corregidas: estilos de flex acotados a `.seleccionDemoOpciones` para no afectar el modal.
- Pantalla de selección de persona con布局 centrado para la última fila.
- **Pruebas realizadas:** Build exitoso, push a `dev-questionnaires` ejecuta el workflow, deploy a GitHub Pages funciona con `VITE_BASE=/dashboard/`.
