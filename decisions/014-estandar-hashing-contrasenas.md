# ADR 014: Estándar de Hashing de Contraseñas

## Estado
Aceptado

## Contexto
El sistema requiere almacenar credenciales de usuario de forma segura. Inicialmente, se detectó que el microservicio `dh_onboarding_back` almacenaba contraseñas en texto plano. Se requiere definir un algoritmo de hashing que sea resistente a ataques de fuerza bruta y que cumpla con los estándares modernos de seguridad.

Se evaluaron dos enfoques:
1. **HS256 (HMAC-SHA256)**: Común en firmas de tokens JWT pero extremadamente rápido, lo que facilita ataques de fuerza bruta si la base de datos es comprometida.
2. **Bcrypt**: Un algoritmo de hashing de contraseñas basado en el cifrado Blowfish, diseñado para ser computacionalmente costoso y que incluye un "salt" aleatorio de forma nativa.

## Decisión
Hemos decidido adoptar **Argon2** como el estándar único para el hashing de contraseñas en todo el ecosistema de Digital Hospital, implementado a través de la librería **`pwdlib`**.

### Centralización en `dh_shared`
Para garantizar que todos los microservicios utilicen exactamente la misma configuración y algoritmo, la lógica de hashing se ha centralizado en la librería compartida:
- **Ubicación**: `dh_shared.utils.security`
- **Funciones**: `hash_password(password)` y `verify_password(plain, hashed)`

### Detalles Técnicos:
- **Algoritmo**: Argon2id (vía `pwdlib.PasswordHash.recommended()`).
- **Librería**: `pwdlib[argon2]`.
- **Salado (Salting)**: Gestionado automáticamente por el formato PHC del hash.

### Diferenciación de Uso:
- **Contraseñas**: Únicamente Argon2 a través de `dh_shared`.
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
