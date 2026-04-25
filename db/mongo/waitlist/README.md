# MongoDB Waitlist Collection

Esta colección almacena los leads interesados en el sistema antes de que inicien el proceso de onboarding formal.

## Estructura Sugerida (JSON)

```json
{
  "_id": "ObjectId",
  "client_name": "string",
  "email": "string",
  "status": "string", // PENDING, ACTIVE, INVITED, CONVERTED, BLOCKED
  "source": "string", // landing_page, referral, ads, etc.
  "metadata": {
    "ip": "string",
    "user_agent": "string",
    "referral_code": "string"
  },
  "timestamps": {
    "created_at": "ISODate",
    "updated_at": "ISODate",
    "invited_at": "ISODate",
    "converted_at": "ISODate"
  },
  "onboarding": {
    "invite_token": "string",
    "token_expires_at": "ISODate",
    "person_id_postgres": "UUID" // Se llena al convertir
  }
}
```

## Índices Recomendados

- `email`: Unique index.
- `status`: Index para filtrado rápido.
- `timestamps.created_at`: Para análisis de cohortes.
- `onboarding.invite_token`: Para validación rápida al iniciar onboarding.

## Ciclo de Vida

1.  **Captura**: El lead se registra en la landing page → status: `ACTIVE`.
2.  **Invitación**: Admin envía invitación → genera `invite_token` y status: `INVITED`.
3.  **Conversión**: El usuario usa el token → se crea `person` en Postgres (PENDING) y status en Mongo: `CONVERTED`. Se guarda el `person_id_postgres` para trazabilidad.
