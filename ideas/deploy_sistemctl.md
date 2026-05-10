# Plan de Deploy Automático: FastAPI + GitHub Actions + systemd + uv

## Arquitectura

```
git push origin main (servicio específico)
        ↓
GitHub Actions — workflow del servicio
        ↓
SSH al VPS
        ↓
cd /home/m4ck-y/.me/dh/<servicio>
        ↓
git pull origin main
        ↓
uv sync --frozen
        ↓
systemctl restart dh_<servicio>
        ↓
API actualizada
```

---

## Microservicios y Puertos (canonical)

Fuente: `docs/architecture/service-endpoint-mapping.md`

### L1 — Gateway (Público)

| Servicio | Directorio | Puerto | ROOT_PATH | app |
|---|---|---|---|---|
| `api_middleware` | `api_middleware` | **8080** | `/api/middleware` | `app.main:app` |

### L2 — Backend (Red interna, NO expuestos)

| Servicio | Directorio | Puerto | ROOT_PATH | Gateway Mount |
|---|---|---|---|---|
| `dh_auth` | `dh_auth` | **8081** | `/api/auth` | `/api/middleware/auth` |
| `dh_iam` | `dh_iam` | **8082** | `/api/iam` | `/api/middleware/iam` |
| `dh_core` | `dh_core` | **8083** | `/api/core` | `/api/middleware/core` |
| `dh_mfa` | `dh_mfa` | **8084** | `/api/mfa` | `/api/middleware/mfa` |
| `dh_onboarding` | `dh_onboarding` | **8085** | `/api/onboarding` | `/api/middleware/onboarding` |
| `dh_health_monitoring` | `app_health_monitoring/backend` | **8086** | `/api/health_monitoring` | `/api/middleware/health_monitoring` |
| `dh_storage` | `dh_storage` | **8087** | `/api/storage` | `/api/middleware/storage` |
| `dh_admin` | `dh_admin` | **8088** | `/api/admin` | `/api/middleware/admin` |
| `dh_notify` | `dh_notify` | **8091** | `/api/notify` | `/api/middleware/notify` |
| `dh_logger` | `dh_logger` | **8092** | `/api/logger` | `/api/middleware/logger` |

**Nota**: `dh_health_monitoring` usa `app_health_monitoring/backend/` como directorio en el VPS.

---

## 1. SSH Key — VPS

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys   # pegar public key
chmod 600 ~/.ssh/authorized_keys
```

---

## 2. Archivos .service (systemd)

Cada servicio tiene su definición en: `<directorio>/docs/<nombre>.service`

```bash
# Ejemplo: api_middleware
sudo cp /home/m4ck-y/.me/dh/api_middleware/docs/api_middleware.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable api_middleware
sudo systemctl start api_middleware
sudo systemctl status api_middleware
```

### api_middleware — `docs/api_middleware.service`

```ini
[Unit]
Description=DH API Middleware — Gateway
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/api_middleware

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/middleware"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8080

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_auth — `docs/dh_auth.service`

```ini
[Unit]
Description=DH Auth Service
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_auth

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/auth"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8081

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_iam — `docs/dh_iam.service`

```ini
[Unit]
Description=DH IAM Service — RBAC
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_iam

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/iam"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8082

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_core — `docs/dh_core.service`

```ini
[Unit]
Description=DH Core — People Service
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_core

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/core"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8083

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_mfa — `docs/dh_mfa.service`

```ini
[Unit]
Description=DH MFA — OTP Service
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_mfa

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/mfa"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8084

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_onboarding — `docs/dh_onboarding.service`

```ini
[Unit]
Description=DH Onboarding Backend
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_onboarding

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/onboarding"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8085

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_health_monitoring — `docs/dh_health_monitoring.service`

```ini
[Unit]
Description=DH Health Monitoring
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/app_health_monitoring/backend

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/health_monitoring"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8086

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_storage — `docs/dh_storage.service`

```ini
[Unit]
Description=DH Storage Service
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_storage

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/storage"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8087

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_admin — `docs/dh_admin.service`

```ini
[Unit]
Description=DH Admin Panel
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_admin

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/admin"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8088

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_notify — `docs/dh_notify.service`

```ini
[Unit]
Description=DH Message Sender — PulseCore
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_notify

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/notify"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8091

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

### dh_logger — `docs/dh_logger.service`

```ini
[Unit]
Description=DH Logger Tracer — VitalTrace
After=network.target

[Service]
User=m4ck-y
WorkingDirectory=/home/m4ck-y/.me/dh/dh_logger

Environment="PYTHONUNBUFFERED=1"
Environment="ROOT_PATH=/api/logger"

ExecStart=/home/m4ck-y/.local/bin/uv run uvicorn app.main:app --host 0.0.0.0 --port 8092

Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

---

## 3. Sudoers — Restart sin password

```bash
sudo visudo
```

Agregar por cada servicio:

```
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart api_middleware
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_auth
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_iam
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_core
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_mfa
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_onboarding
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_health_monitoring
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_storage
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_admin
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_notify
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl restart dh_logger
m4ck-y ALL=(ALL) NOPASSWD:/bin/systemctl status *
```

---

## 4. GitHub Secrets

| Secret | Valor |
|---|---|
| `VPS_HOST` | IP del VPS |
| `VPS_SSH_KEY` | Private key completa |
| `VPS_USERNAME` | `m4ck-y` |

Estos secrets se usan en TODOS los workflows. Se configuran una sola vez en cada repo.

---

## 5. Workflows GitHub Actions

Cada microservicio tiene su propio workflow en `.github/workflows/deploy.yml`.

### api_middleware

```yaml
name: Deploy api_middleware

on:
  push:
    branches: [main]
    paths:
      - "api_middleware/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== api_middleware ==="
            cd /home/m4ck-y/.me/dh/api_middleware
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart api_middleware
            sudo systemctl status api_middleware --no-pager
```

### dh_auth

```yaml
name: Deploy dh_auth

on:
  push:
    branches: [main]
    paths:
      - "dh_auth/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_auth ==="
            cd /home/m4ck-y/.me/dh/dh_auth
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_auth
            sudo systemctl status dh_auth --no-pager
```

### dh_iam

```yaml
name: Deploy dh_iam

on:
  push:
    branches: [main]
    paths:
      - "dh_iam/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_iam ==="
            cd /home/m4ck-y/.me/dh/dh_iam
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_iam
            sudo systemctl status dh_iam --no-pager
```

### dh_core

```yaml
name: Deploy dh_core

on:
  push:
    branches: [main]
    paths:
      - "dh_core/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_core ==="
            cd /home/m4ck-y/.me/dh/dh_core
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_core
            sudo systemctl status dh_core --no-pager
```

### dh_mfa

```yaml
name: Deploy dh_mfa

on:
  push:
    branches: [main]
    paths:
      - "dh_mfa/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_mfa ==="
            cd /home/m4ck-y/.me/dh/dh_mfa
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_mfa
            sudo systemctl status dh_mfa --no-pager
```

### dh_onboarding

```yaml
name: Deploy dh_onboarding

on:
  push:
    branches: [main]
    paths:
      - "dh_onboarding/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_onboarding ==="
            cd /home/m4ck-y/.me/dh/dh_onboarding
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_onboarding
            sudo systemctl status dh_onboarding --no-pager
```

### dh_health_monitoring

```yaml
name: Deploy dh_health_monitoring

on:
  push:
    branches: [main]
    paths:
      - "app_health_monitoring/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_health_monitoring ==="
            cd /home/m4ck-y/.me/dh/app_health_monitoring/backend
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_health_monitoring
            sudo systemctl status dh_health_monitoring --no-pager
```

### dh_storage

```yaml
name: Deploy dh_storage

on:
  push:
    branches: [main]
    paths:
      - "dh_storage/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_storage ==="
            cd /home/m4ck-y/.me/dh/dh_storage
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_storage
            sudo systemctl status dh_storage --no-pager
```

### dh_admin

```yaml
name: Deploy dh_admin

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_admin ==="
            cd /home/m4ck-y/.me/dh/dh_admin
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_admin
            sudo systemctl status dh_admin --no-pager
```

### dh_notify

```yaml
name: Deploy dh_notify

on:
  push:
    branches: [main]
    paths:
      - "dh_notify/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_notify ==="
            cd /home/m4ck-y/.me/dh/dh_notify
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_notify
            sudo systemctl status dh_notify --no-pager
```

### dh_logger

```yaml
name: Deploy dh_logger

on:
  push:
    branches: [main]
    paths:
      - "dh_logger/**"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: SSH Deploy
        uses: appleboy/ssh-action@v1.2.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            set -e
            echo "=== dh_logger ==="
            cd /home/m4ck-y/.me/dh/dh_logger
            git pull origin main
            /home/m4ck-y/.local/bin/uv sync --frozen
            sudo systemctl restart dh_logger
            sudo systemctl status dh_logger --no-pager
```

---

## 6. Activación en VPS

```bash
# Copiar definiciones de servicio
for dir in api_middleware dh_auth dh_iam dh_core dh_mfa dh_onboarding dh_admin dh_storage dh_notify dh_logger; do
  sudo cp /home/m4ck-y/.me/dh/$dir/docs/$dir.service /etc/systemd/system/
done

# dh_health_monitoring (path especial)
sudo cp /home/m4ck-y/.me/dh/app_health_monitoring/backend/docs/dh_health_monitoring.service /etc/systemd/system/

# Recargar y habilitar
sudo systemctl daemon-reload
for s in api_middleware dh_auth dh_iam dh_core dh_mfa dh_onboarding dh_health_monitoring dh_admin dh_storage dh_notify dh_logger; do
  sudo systemctl enable $s
  sudo systemctl start $s
done
```

---

## 7. Verificación

```bash
# Todos los servicios
systemctl status api_middleware dh_auth dh_iam dh_core dh_mfa dh_onboarding dh_health_monitoring dh_admin dh_storage dh_notify dh_logger

# Logs individuales
journalctl -u api_middleware -f
journalctl -u dh_auth -f
```

---

## 8. Troubleshooting

### Permisos de SSH
```bash
ssh -i ~/.ssh/private_key m4ck-y@$VPS_HOST
```

### uv no encontrado
```bash
/home/m4ck-y/.local/bin/uv --version
# Si no existe: curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Servicio no arranca
```bash
journalctl -u dh_auth -n 50 --no-pager
```

### .env faltante
Cada servicio necesita su `.env` en el `WorkingDirectory`. Copiar desde `.env.example`:
```bash
cp /home/m4ck-y/.me/dh/dh_auth/.env.example /home/m4ck-y/.me/dh/dh_auth/.env
# Editar con valores reales
```