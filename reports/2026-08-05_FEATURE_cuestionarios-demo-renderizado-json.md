**Proyecto o Apartado:** Plataforma Libersalus — Frontend de paciente (`lsinciosesionweb`) / Modo demo offline

**Título de la actividad o tarea:** Habilitación del modo demo offline y selector de perfiles de usuario

**Descripción de la actividad o tarea:**
Se habilitó el modo demo offline en el frontend de paciente para permitir recorrer la plataforma completa sin depender del backend, con datos de ejemplo coherentes. El objetivo de negocio es ofrecer una vitrina funcional y un entorno de maquetado donde se pueda probar el panel, las vistas y los flujos principales con datos de ejemplo.

El trabajo se articuló en dos frentes principales:

**1. Configuración del modo demo.** Se implementó el flag de entorno `VITE_DEMO` que activa o desactiva el modo demo. La configuración incluye las credenciales demo (`VITE_DEMO_USER`, `VITE_DEMO_PASSWORD`) y el token demo que simula una sesión autenticada. El servicio `apiClient.js` fue extendido con `crearApiDemo()` que reemplaza la instancia axios por un adaptador con la misma interfaz `{ data }`, interceptando los endpoints conocidos (decode-token, sesion/auth/token, refresh-token, logout, paciente/home, getListNews, foto/perfil) para responder con datos locales sin tocar la red.

**2. Perfiles de usuario demo y selector.** Se crearon 4 personas demo en `src/config/demo.config.js`, cada una con variante visual (avatar y mancha) y perfil de salud que alimenta el gating por perfil de los cuestionarios: **María** (34 años, mujer, `adulto_activo`), **Juan** (50 años, hombre, `adulto_activo`), **Rosa** (68 años, mujer, `mayor_asistido`) y **Sofía** (10 años, mujer, `menor_tutor`). Estas tres columnas de perfil cubren los `profiles` que la plataforma usa para filtrar cuestionarios: con Rosa se pueden recorrer instrumentos geriátricos (p. ej. GDS >60) y con Sofía los pediátricos (p. ej. CDI/EDAH), mientras María y Juan cubren los de adultos.

El selector de perfil (`VistaSeleccionDemo`) se rediseñó con una cuadrícula fluida que depende del ancho de pantalla: los 4 perfiles en línea cuando caben (2×2 en móvil). La persona activa alimenta el saludo, el avatar, la mancha, el resumen de salud del inicio y el `perfil`/`edad` que guarda la sesión (clave `perfil_min`). Al cerrar sesión demo se regresa a la primera persona para que la siguiente sesión no arrastre la selección anterior.

**Estado de la actividad o tarea:** Completado

**Avances de la actividad (si lo requiere):**
- Flag `VITE_DEMO` implementado con credenciales demo (`VITE_DEMO_USER`, `VITE_DEMO_PASSWORD`) y token demo.
- `crearApiDemo()` en `apiClient.js` interceptando endpoints conocidos para responder con datos locales.
- 4 perfiles demo configurados en `demo.config.js` con avatares, manchas y perfiles de salud.
- Selector de perfil (`VistaSeleccionDemo`) rediseñado con cuadrícula fluida responsive.
- Sincronización de la persona activa con el saludo, avatar, mancha y resumen de salud del inicio.
- Limpieza de sesión demo al cerrar, restaurando la primera persona.
- Píldora flotante "DEMO MODE" (`IndicadorDemo`) con modal de salida desde `Layout/Principal.jsx`.

**Próximos pasos:**
- Integración de los cuestionarios psicométricos en modo demo (reporte 2026-08-07).
- Conexión de Header y TarjetaUsuario a `mi-sesion` cuando el backend entregue el servicio.
- Reemplazo de datos mock por adaptadores de respuesta en el dashboard.

**Referencias:**
- Configuración demo: `src/config/demo.config.js`
- Cliente API demo: `src/services/apiClient.js` · `crearApiDemo()`
- Selector de perfil: `src/features/autenticacion/vistas/VistaSeleccionDemo.jsx`
- Indicador demo: `src/components/IndicadorDemo/IndicadorDemo.jsx`
- Servicio de autenticación: `src/services/auth.js` · `iniciarSesion` · `cerrarSesion`
- Documento de propuesta: `docs/features/demo.md`
