---
type: task
id: TASK-006
title: "Microservicio MFA — OTP Challenge (dh_mfa)"
status: in-progress
priority: high
created: "2026-04-26"
started: "2026-04-26"
completed: null
tags: [mfa, otp, mongodb, beanie, security]
---

# TASK-006: Microservicio MFA — OTP Challenge

## Descripción

Servicio `dh_mfa` responsable del ciclo de vida de desafíos OTP. Almacena los challenges en MongoDB con TTL automático. Despacha los códigos vía PulseCore y los loggea a VitalTrace.

Ver diseño de colección: `docs/db/mongo/mfa/DC.mmd`

## Fase 1 — OTP Challenge (completada)

- [x] Modelo `OtpChallenge` en MongoDB (Beanie) con índices TTL y compuestos.
- [x] `EOtpChannel`, `EOtpPurpose`, `EOtpStatus` (CREATED, EXPIRED, CONSUMED, BLOCKED).
- [x] `POST /v1/otp/challenges` — crear challenge, generar código, despachar vía PulseCore.
- [x] `POST /v1/otp/challenges/{id}/verify` — `expire()` + `find_active()` + verificar hash + manejo de intentos.
- [x] `POST /v1/otp/challenges/{id}/resend` — actualiza mismo documento (nuevo código, reset verify_attempts).
- [x] Logging a VitalTrace en todos los eventos (otp_created, otp.invalid, otp.blocked, otp_consumed, otp_resent).
- [x] `ApiResponseSingle` en todos los endpoints.
- [x] Dockerfile, .env.example, .dockerignore siguiendo estándares del proyecto.

## Fase 2 — Pendiente

- [ ] TOTP (Google Authenticator) — `auth_factor` con secret TOTP, QR code.
- [ ] WebAuthn / biometría.
- [ ] Endpoints de gestión de factores MFA por persona.
- [ ] Integración con `dh_auth` para MFA en el flujo de login.
- [ ] Política de segundo factor configurable por persona.
