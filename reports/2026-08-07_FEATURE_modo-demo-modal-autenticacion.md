**Proyecto o Apartado:** Frontend web de Libersalus — Módulo de autenticación y modo demo (`lsinciosesionweb`)

**Título de la actividad o tarea:** Mejoras en el modo demo: hub de selección de perfil, vista de login demo y refactoring de autenticación

**Descripción de la actividad o tarea:**
Se implementaron mejoras significativas en la experiencia del modo demo de la plataforma, orientadas a reducir la fricción de entrada para usuarios que desean explorar la aplicación sin crear una cuenta. El objetivo de negocio es permitir la demostración rápida de la plataforma en ferias, presentaciones o pruebas internas, sin depender del backend ni de credenciales reales.

En primer lugar, se creó el componente `ModalDemoHub` que presenta al usuario tres opciones de entrada: perfil de prueba rápido, inicio de sesión con cuenta existente, o creación de cuenta demo. Este modal reemplaza al anterior flujo lineal, offering una experiencia más flexible y visualmente consistente con el diseño glassmorphism del resto de la plataforma.

En segundo lugar, se implementó la `VistaDemoLogin` que permite al usuario seleccionar entre cuatro perfiles de demostración (María, Juan, Rosa, Sofía), cada uno con un perfil de salud diferente que alimenta el gating por perfil de los cuestionarios. Esta vista incluye información contextual sobre cada perfil (edad, peso, sangre, estatura) para que el usuario elija el que más se asemeje a su caso de prueba.

En tercer lugar, se refactorizó el servicio de autenticación (`auth.js`) y el cliente API (`apiClient.js`) para soportar el modo demo de manera más robusta, incluyendo manejo de errores mejorado y fallback a datos locales cuando el backend no está disponible.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad:**
- Componente `ModalDemoHub` con tres opciones de entrada (perfil rápido, login, registro).
- `VistaDemoLogin` con 4 perfiles demo: María (34, adulto_activo), Juan (50, adulto_activo), Rosa (68, mayor_asistido), Sofía (10, menor_tutor).
- Refactoring de `auth.js` y `apiClient.js` para soporte robusto del modo demo.
- Actualización de `demo.config.js` con perfiles extendidos y variantes visuales.
- Documentación actualizada en `cuestionarios-demo.md` y nuevo `demo-flujo.md`.
- **Pruebas realizadas:** flujo completo verificado: login → selección de perfil → panel con datos demo correctos según el perfil elegido.
