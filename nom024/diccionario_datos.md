# GIIS-B015-04-11 - Diccionario de Datos

Guía y Formatos para el Intercambio de Información en Salud Referente al Subsistema de Prestación de Servicios "SIS" – Consulta Externa

**Versión:** 4.11  
**Fecha:** 01 de noviembre de 2024

---

## 1. Identificación de la Unidad

**Overview:** Esta sección contiene las variables necesarias para identificar de manera única el establecimiento de salud donde se otorga la atención médica.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 1 | clues | Clave Única de Establecimientos en Salud | Texto (11) | Sí. Se debe validar que para la CLUES registrada, el valor del campo `en_operación` sea igual a "1 – OPERACIÓN". En caso contrario, no se debe permitir el registro. |

---

## 2. Datos del Prestador de Servicios

**Overview:** Sección que registra la información del personal de salud que proporciona la atención médica al paciente.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 2 | paisNacimiento | País de nacimiento del prestador de servicio de salud | Numérico | Sí. Se debe registrar el valor del catálogo que corresponda al País de Nacimiento del prestador de servicios de acuerdo al catálogo PAIS. Si el valor registrado es diferente de "142 – MÉXICO", se podrá registrar el valor genérico "XXXX999999XXXXXX99" y omitir la validación con las variables asociadas. |
| 3 | curpPrestador | Clave Única de Registro de Población del prestador de servicio de salud | Texto (18) | Sí. Se debe realizar la validación de conformidad con el Instructivo Normativo para la Asignación de la CURP emitido por RENAPO. Si el valor registrado en `curpPrestador` es diferente al valor genérico, el valor registrado debe corresponder con dicho valor. |
| 4 | nombrePrestador | Nombre del prestador de servicio de salud | Texto (50) | Sí. Se debe validar que la edad del prestador de servicios se encuentre entre los 18 y 90 años. El nombre debe tener una longitud mínima de 2 y máxima de 50 caracteres. Se deben omitir espacios en blanco al inicio y final. No se permite más de un espacio consecutivo. Los caracteres válidos son A-Z incluyendo Ñ, en mayúsculas. Caracteres especiales permitidos: guion medio, coma, punto, diagonal, apóstrofe y diéresis. |
| 5 | primerApellidoPrestador | Primer apellido del prestador de servicio de salud | Texto (50) | Sí. Mismas reglas de validación que para nombrePrestador respecto a longitud, espacios y caracteres. |
| 6 | segundoApellidoPrestador | Segundo apellido del prestador de servicio de salud | Texto (50) | No. Mismas reglas de validación que para primerApellidoPrestador. |
| 7 | profesion | Profesión del prestador de servicios de salud | Numérico | Sí. Se debe validar que el valor corresponda al catálogo PROFESION. |
| 8 | claveUsuario | Clave única del prestador de servicios de salud | Texto (10) | Sí. La clave debe existir en el sistema. |
| 9 | emailPrestador | Correo electrónico del prestador de servicios de salud | Texto (50) | No. El correo debe tener formato válido. |

---

## 3. Datos del Paciente

**Overview:** Sección que registra los datos demográficos y de identificación del paciente que recibe la atención médica.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 10 | curpPaciente | CURP del paciente | Texto (18) | Sí. Debe ser una CURP válida según el instructivo de RENAPO. Para menores de edad, la CURP debe ser validada contra la del tutor o padre. Si el paciente tiene 9 años o más y no tiene CURP, se puede registrar el valor genérico. |
| 11 | nombrePaciente | Nombre(s) del paciente | Texto (50) | Sí. Longitud mínima de 2 y máxima de 50 caracteres. Solo letras A-Z incluyendo Ñ, en mayúsculas. Caracteres especiales permitidos: guion medio, coma, punto, diagonal, apóstrofe y diéresis. |
| 12 | primerApellidoPaciente | Primer apellido del paciente | Texto (50) | Sí. Mismas reglas que nombrePaciente. |
| 13 | segundoApellidoPaciente | Segundo apellido del paciente | Texto (50) | No. Opcional. |
| 14 | fechaNacimiento | Fecha de nacimiento del paciente | Fecha (YYYYMMDD) | Sí. La fecha debe ser menor o igual a la fecha de atención. La edad calculada debe ser coherente con el tipo de atención. |
| 15 | entidadNacimiento | Entidad federativa de nacimiento del paciente | Numérico | Sí. Debe corresponder al catálogo ENTIDAD_FEDERATIVA. Si paisNacimiento es diferente de México (142), este campo puede ser nulo. |
| 16 | paisNacimientoPaciente | País de nacimiento del paciente | Numérico | Sí. Debe corresponder al catálogo PAIS. Si es diferente de México, se puede usar valor genérico. |
| 17 | entidadNacimientoPaciente | Clave de la entidad federativa de nacimiento | Numérico | Sí. Debe corresponder al catálogo ENTIDAD_FEDERATIVA. |
| 18 | municipioNacimiento | Clave del municipio de nacimiento | Numérico | Sí. Debe corresponder al catálogo MUNICIPIO. |
| 19 | localidadNacimiento | Clave de la localidad de nacimiento | Numérico | No. Opcional. |
| 20 | sexoPaciente | Sexo del paciente | Numérico | Sí. 1 = Hombre, 2 = Mujer, 3 = Intersexual. Según catálogo SEXO. |
| 21 | identidadGeneroPaciente | Identidad de género del paciente | Numérico | Sí. Según catálogo IDENTIDAD_GENERO. |
| 22 | orientacionSexualPaciente | Orientación sexual del paciente | Numérico | Sí. Según catálogo ORIENTACION_SEXUAL. |
| 23 | puebloIndigenaPaciente | Pueblo indígena del paciente | Numérico | Sí. Según catálogo PUEBLO_INDIGENA. Si no aplica, registrar 98 = No pertenece a ningún pueblo indígena. |
| 24 | lenguaIndigenaPaciente | Lengua indígena del paciente | Numérico | Sí. Según catálogo LENGUA_INDIGENA. Si no aplica, registrar 998 = No habla lengua indígena. |

---

## 4. Consulta, Somatometría y Otras Mediciones

**Overview:** Sección que registra los datos relacionados con la consulta médica, mediciones antropométricas y signos vitales del paciente.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 25 | fechaConsulta | Fecha de la consulta | Fecha (YYYYMMDD) | Sí. Debe ser menor o igual a la fecha actual. |
| 26 | horaConsulta | Hora de la consulta | Hora (HHMM) | Sí. Formato de 24 horas. |
| 27 | tipoConsulta | Tipo de consulta | Numérico | Sí. Según catálogo TIPO_CONSULTA. |
| 28 | causaAtencion | Causa de atención | Numérico | Sí. Según catálogo CAUSA_ATENCION. |
| 29 | tipoPrimerAtencion | Tipo de primera atención | Numérico | Sí. Según catálogo TIPO_PRIMER_ATENCION. |
| 30 | peso | Peso del paciente (kg) | Numérico (5,2) | Sí para mayores de 5 años. Valor entre 0.5 y 300 kg. |
| 31 | talla | Talla del paciente (cm) | Numérico (5,2) | Sí para mayores de 5 años. Valor entre 30 y 250 cm. |
| 32 | pesoTalla | Relación peso/talla | Numérico | No. Calculada automáticamente. |
| 33 | perímetroAbdominal | Perímetro abdominal (cm) | Numérico (5,2) | Sí para mayores de 9 años. Valor entre 30 y 200 cm. |
| 34 | presiónArterialSistolica | Presión arterial sistólica (mmHg) | Numérico (3) | Sí para adultos. Valor entre 50 y 300 mmHg. |
| 35 | presiónArterialDiastolica | Presión arterial diastólica (mmHg) | Numérico (3) | Sí para adultos. Valor entre 30 y 200 mmHg. |
| 36 | frecuenciaCardiaca | Frecuencia cardiaca (latidos/min) | Numérico (3) | Sí. Valor entre 20 y 250 lpm. |
| 37 | frecuenciaRespiratoria | Frecuencia respiratoria (resp/min) | Numérico (2) | Sí. Valor entre 5 y 60 rpm. |
| 38 | temperatura | Temperatura corporal (°C) | Numérico (4,1) | Sí. Valor entre 30 y 45 °C. |
| 39 | saturaciónOxigeno | Saturación de oxígeno (%) | Numérico (3) | Sí. Valor entre 50 y 100%. |
| 40 | glucometria | Glucosa en sangre (mg/dL) | Numérico (5,1) | No.Valor entre 20 y 600 mg/dL. |
| 41 | motivoConsulta | Motivo de la consulta | Texto (200) | Sí. Descripción del motivo. |
| 42 | diagnPrincipal | Diagnóstico principal (CIE) | Texto (10) | Sí. Código CIE válido de 3 a 10 caracteres. |
| 43 | tipoDiagnosticoPrincipal | Tipo de diagnóstico principal | Numérico | Sí. Según catálogo TIPO_DIAGNOSTICO. |
| 44 | confirmacionDiagnostica1 | Confirmación diagnóstica 1 | Numérico | Sí. Según catálogo CONFIRMACION_DIAGNOSTICA. |
| 45 | confirmacionDiagnostica2 | Confirmación diagnóstica 2 | Numérico | No. Opcional. |
| 46 | confirmacionDiagnostica3 | Confirmación diagnóstica 3 | Numérico | No. Opcional. |
| 47 | códigoCIEDiagnostico2 | Código CIE diagnóstico 2 | Texto (10) | No. Opcional. Código CIE válido. |
| 48 | códigoCIEDiagnostico3 | Código CIE diagnóstico 3 | Texto (10) | No. Opcional. Código CIE válido. |
| 49 | tratamiento | Tratamiento prescrito | Texto (500) | Sí. Descripción del tratamiento. |
| 50 | seguimiento | Seguimiento indicado | Numérico | Sí. Según catálogo SEGUIMIENTO. |

---

## 5. Salud Mental y Adicciones

**Overview:** Sección que registra información relacionado con la detección y atención de problemas de salud mental y adicciones.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 51 | detecciónSMultimedia | Detección de factores de riesgo para la salud mental mediante pruebas instrumentales | Numérico | Sí, depende de edad. Según catálogo RESPUESTA_DETECCION. Si la edad del paciente es mayor o igual a 10 años, es obligatorio. |
| 52 | pruebasPHQS | Aplicación de prueba PHQ-9 para detección de depresión | Numérico | Sí, depende de edad. Según catálogo RESPUESTA_DETECCION. Si la edad del paciente es mayor o igual a 18 años, es obligatorio. |
| 53 | aplicaciónGAD | Aplicación de prueba GAD para detección de ansiedad | Numérico | Sí, depende de edad. Según catálogo RESPUESTA_DETECCION. |
| 54 | resultadoDPRAS | Resultado de prueba ASSIST para detección de adicciones | Numérico | Sí, depende de edad. Según catálogo RESPUESTA_DETECCION. |
| 55 | aplicaciónAUDIT | Aplicación de prueba AUDIT para detección de consumo de alcohol | Numérico | Sí, depende de edad. Según catálogo RESPUESTA_DETECCION. |
| 56 | referenciaSMR | Referencia a segundo nivel para atención de salud mental | Numérico | Sí. Según catálogo SI_NO. |
| 57 | consumoSustancias | Consumo de sustancias psicoactivas | Numérico | Sí, depende de edad. Según catálogo RESPUESTA_DETECCION. |
| 58 | orientaciónSexualPacSM | Orientación sexual del paciente | Numérico | Sí. Según catálogo ORIENTACION_SEXUAL. |
| 59 | identidadGeneroPacSM | Identidad de género del paciente | Numérico | Sí. Según catálogo IDENTIDAD_GENERO. |

---

## 6. Salud Reproductiva

**Overview:** Sección que registra información sobre salud reproductiva, planificación familiar, embarazo y cáncer cérvico-uterino.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 60 | controlPrenatal | Control prenatal | Numérico | Sí, mujeres en edad fértil. Según catálogo SI_NO. |
| 61 | fechaUltimaMenstruacion | Fecha de última menstruación | Fecha | Sí, mujeres en control prenatal. |
| 62 | edadGestional | Edad gestacional | Numérico | Sí, en control prenatal. Semanas 1-45. |
| 63 | númeroControlPrenatal | Número de control prenatal | Numérico | Sí, en control prenatal. |
| 64 | riesgopsicoPrenatal | Riesgo psicosocial durante el embarazo | Numérico | Sí. Según catálogo RIESGO_PSICO. |
| 65 | detecciónVIHEmbarazada | Detección de VIH en embarazada | Numérico | Sí, en control prenatal. Según catálogo RESULTADO_DETECCION. |
| 66 | detecciónSifilisGestante | Detección de sífilis en gestante | Numérico | Sí, en control prenatal. Según catálogo RESULTADO_DETECCION. |
| 67 | pruebasDetecGestarPrv | Detección de profileración gestacional prv | Numérico | Sí. Según catálogo RESPUESTA. |
| 68 | atenciónParto | Atención del parto | Numérico | Sí. Según catálogo SI_NO. |
| 69 | tipoParto | Tipo de parto | Numérico | Sí. Según catálogo TIPO_PARTO. |
| 70 | reciénNacidoVivo | Recién nacido vivo | Numérico | Sí. Según catálogo SI_NO. |
| 71 | pesoRecienNacido | Peso del recién nacido (g) | Numérico | Sí, si recién nacido vivo. 500-8000 g. |
| 72 | edadGestacionalRN | Edad gestacional del RN (semanas) | Numérico | Sí, si nacido vivo. 22-45 semanas. |
| 73 | tipoAlimentacionMenor1 | Alimentación del menor de 1 año | Numérico | Sí. Según catálogo TIPO_ALIMENTACION. |
| 74 | metodoAnticonceptivo | Método anticonceptivo | Numérico | Sí, mayores de 10 años. Según catálogo METODO_ANTICONCEPTIVO. |
| 75 | fechaInicMetodoAntic | Fecha de inicio del método | Fecha | Sí, si usa método. |
| 76 | orientacion SexualPacSR | Orientación sexual | Numérico | Sí. Según catálogo ORIENTACION_SEXUAL. |
| 77 | identityGeneroPacSR | Identidad de género | Numérico | Sí. Según catálogo IDENTIDAD_GENERO. |
| 78 | cancerMamario | Detección de cáncer mamario | Numérico | Sí, mujeres 25-69 años. Según catálogo RESULTADO_CANCER_MAMARIO. |
| 79 | cancerCervicouterino | Detección de cáncer cérvico-uterino | Numérico | Sí, mujeres 25-64 años. Según catálogo RESULTADO_CANCER. |
| 80 | fechaTomaCitologia | Fecha de toma de citología | Fecha | Sí, si se realizó. |
| 81 | resultadoCitologia | Resultado de citología | Numérico | Sí. Según catálogo RESULTADO_CITOLOGIA. |
| 82 | tratamientoLesionPremalig | Tratamiento de lesión premaligna | Numérico | Sí. Según catálogo SI_NO. |
| 83 | dateTtoLesionPremalig | Fecha de tratamiento | Fecha | Sí, si hay tratamiento. |
| 84 | pruebaVPH | Prueba de Virus del Papiloma Humano | Numérico | Sí. Según catálogo RESULTADO_VPH. |
| 85 | datePruebaVPH | Fecha de prueba VPH | Fecha | Sí, si se realizó. |

---

## 7. Infancia

**Overview:** Sección que registra información específica para la atención de salud infantil.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 86 | desarrolloNeurologico | Evaluación del desarrollo neurológico | Numérico | Sí, niños 0-5 años. Según catálogo RESULTADO_DESARROLLO. |
| 87 | riesgoDesarrolloNeurol | Riesgo en desarrollo neurológico | Numérico | Sí, si hay evaluación. Según catálogo RIESGO. |
| 88 | edadDesarrolloNeurol | Edad de evaluación | Numérico | Sí, si aplica. Meses. |
| 89 | tamizNeonatal | Tamiz neonatal | Numérico | Sí, recién nacidos. Según catálogo RESULTADO_TAMIZ. |
| 90 | resultadoTamizNeonatal | Resultado del tamiz neonatal | Numérico | Sí, si tamiz positivo. Según catálogo RESULTADO_TAMIZ_NEONATAL. |
| 91 | aplicaciónPESVD | Aplicación de prueba ESCS | Numérico | Sí, niños 1 mes-5 años. Según catálogo SI_NO. |
| 92 | resultadoPESVD | Resultado de ESCS | Numérico | Sí. Según catálogo RESULTADO_PESVD. |
| 93 | referensiPediatra | Referencia al especialista | Numérico | Sí. Según catálogo SI_NO. |
| 94 | vaccineBCG | Vacuna BCG aplicada | Numérico | Sí. Según catálogo SI_NO. |
| 95 | vaccineHB | Vacuna contra hepatitis B | Numérico | Sí. Según catálogo SI_NO. |
| 96 | vaccineRotavirus | Vacuna contra rotavirus | Numérico | Sí. Según catálogo SI_NO. |
| 97 | otrasVacunas | Aplicación de otras vacunas | Numérico | Sí. Según catálogo SI_NO. |

---

## 8. Adultos Mayores

**Overview:** Sección que registra información específica para la atención de adultos de 60 años y más.

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 98 | detecciónDemencia | Detección de demencia | Numérico | Sí, mayores de 60 años. Según catálogo RESULTADO_DETECCION. |
| 99 | resultadoMMSE | Resultado de prueba MMSE | Numérico | Sí, si hay detección. Según catálogo RESULTADO_MMSE. |
| 100 | pruebaRELAGED | Aplicación de prueba RELAGED | Numérico | Sí, mayores 60 años. Según catálogo SI_NO. |
| 101 | resultPRUEBARELAGED | Resultado de RELAGED | Numérico | Sí. Según catálogo RESULTADO_RELAGED. |
| 102 | riesgoCaídas | Riesgo de caídas | Numérico | Sí. Según catálogo RIESGO_CAIDAS. |
| 103 | pruebaUpAndGo | Prueba "Up and Go" | Numérico | Sí. Según catálogo RESULTADO_UPANDGO. |
| 104 | fragilidad | Fragilidad | Numérico | Sí. Según catálogo FRAGILIDAD. |
| 105 | testFrail | Test de fragilidad | Numérico | Sí. Según catálogo TEST_FRAIL. |
| 106 | refe AdultoMayor | Referencia a geriatría | Numérico | Sí. Según catálogo SI_NO. |

---

## 9. Otras Variables

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 107 | servicio | Servicio | Numérico | Sí. Según catálogo SERVICIO. |
| 108 | area | Área | Numérico | Sí. Según catálogo AREA. |
| 109 | consultorio | Consultorio | Numérico | Sí. Según catálogo CONSULTORIO. |

---

## 10. Referencia y Contrarreferencia

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 110 | tipoReferencia | Tipo de referencia | Numérico | Sí. Según catálogo TIPO_REFERENCIA. |
| 111 | motivoReferencia | Motivo de referencia | Numérico | Sí. Según catálogo MOTIVO_REFERENCIA. |

---

## 11. Telemedicina

| ID | Variable | Descripción | Tipo | Validación |
|----|----------|------------|------|------------|
| 112 | telemedicina | Consulta por telemedicina | Numérico | Sí. Según catálogo SI_NO. |
| 113 | plataforma | Plataforma utilizada | Numérico | Sí. Según catálogo PLATAFORMA. |
| 114 | modalidad | Modalidad de atención | Numérico | Sí. Según catálogo MODALIDAD_TELEMEDICINA. |
| 115 | consentimientoTelemedicina | Consentimiento informado | Numérico | Sí. Según catálogo SI_NO. |

---

*Documento generado automáticamente a partir de GIIS-B015-04-11 - Versión 4.11*