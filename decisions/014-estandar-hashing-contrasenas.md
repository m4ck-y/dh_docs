# ADR 014: Estándar de Hashing de Contraseñas

## Estado
Aceptado

## Contexto
El sistema requiere almacenar credenciales de usuario de forma segura. Inicialmente, se detectó que el microservicio `dh_onboarding_back` almacenaba contraseñas en texto plano. Se requiere definir un algoritmo de hashing que sea resistente a ataques de fuerza bruta y que cumpla con los estándares modernos de seguridad.

Se evaluaron dos enfoques:
1. **HS256 (HMAC-SHA256)**: Común en firmas de tokens JWT pero extremadamente rápido, lo que facilita ataques de fuerza bruta si la base de datos es comprometida.
2. **Bcrypt**: Un algoritmo de hashing de contraseñas basado en el cifrado Blowfish, diseñado para ser computacionalmente costoso y que incluye un "salt" aleatorio de forma nativa.

## Decisión
Hemos decidido adoptar **Bcrypt** como el estándar único para el hashing de contraseñas en todo el ecosistema de Digital Hospital.

### Detalles Técnicos:
- **Algoritmo**: Bcrypt.
- **Factor de trabajo (Cost)**: 12 (valor predeterminado de la librería `bcrypt` en Python).
- **Salado (Salting)**: Automático y único por cada hash generado.
- **Librería**: Se utilizará la librería nativa `bcrypt` para Python en lugar de `passlib` para reducir dependencias legadas.

### Diferenciación de Uso:
- **Contraseñas**: Únicamente Bcrypt.
- **Tokens (JWT)**: Se reserva HS256 exclusivamente para la firma de tokens de sesión, nunca para el almacenamiento de credenciales.

## Consecuencias

### Positivas:
- **Alta Seguridad**: Protección robusta contra ataques de diccionario y Rainbow Tables.
- **Estandarización**: Todos los servicios (Onboarding, Auth) utilizarán la misma lógica de verificación.
- **Cumplimiento**: Alineación con las mejores prácticas de la industria (OWASP).

### Negativas:
- **Costo Computacional**: El hashing es deliberadamente lento, lo que consume más CPU por cada intento de login/registro (diseño intencional).

## Referencias
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [Bcrypt Python Library](https://pypi.org/project/bcrypt/)
