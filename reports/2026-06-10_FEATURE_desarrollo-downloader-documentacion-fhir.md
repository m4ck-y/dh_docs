**Proyecto o Apartado:** Core Domain / dh_fhir / Downloader Use Case

**Título de la actividad o tarea:** Desarrollo del Downloader de Documentación FHIR R5

**Descripción de la actividad o tarea:**
Se diseñó e implementó el caso de uso `DownloadFileUseCase` en el microservicio `dh_fhir`. Este componente tiene como objetivo automatizar la descarga y almacenamiento local de la especificación técnica de recursos HL7 FHIR R5 desde fuentes web externas (utilizando Jina AI como motor de transformación a Markdown). Con esta funcionalidad, se acelera el proceso de investigación y modelado de schemas dentro del ecosistema de Digital Hospital, permitiendo disponer de copias locales estructuradas de la documentación oficial directamente en el repositorio de desarrollo.

El caso de uso consulta un repositorio de base de datos (`DownloadRepository`) para verificar si la URL solicitada ya fue procesada previamente, evitando peticiones duplicadas. En caso de ser una nueva URL, consume el servicio externo de Jina, sanitiza el nombre del recurso a partir de la ruta URL, escribe el archivo Markdown en el sistema de archivos del servidor bajo el directorio configurado (`settings.FILES_DIR`) y registra la descarga en la base de datos para futuras referencias.

La arquitectura de este componente se estructuró bajo los principios de Clean Architecture, separando la lógica de aplicación del cliente HTTP y de la persistencia de datos. El uso del servicio de extracción de Jina AI simplifica el procesamiento, garantizando que el contenido HTML de la especificación FHIR R5 sea transformado en un Markdown limpio y legible por agentes de inteligencia artificial, facilitando la indexación automática y la consistencia en el modelado posterior.

**Estado de la actividad o tarea:** Concluido

**Avances de la actividad (si lo requiere):**
- Implementación de la clase `DownloadFileUseCase` en `dh_fhir/app/contexts/downloader/application/use_cases/download_file_use_case.py`.
- Integración con `DownloadRepository` para persistir el historial de descargas y evitar duplicidad de solicitudes de red.
- Implementación del flujo asíncrono para la creación de directorios y escritura de archivos en disco utilizando `asyncio.to_thread`.
- Integración con el cliente externo de Jina AI para la obtención de contenido web formateado directamente a Markdown.
