<div align="center">

# 🚀 3-Tier Dockerized Application

**A production-ready, containerized full-stack application built with React · Flask · PostgreSQL**

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-Published-blue?style=flat-square&logo=docker)](https://hub.docker.com/r/harshit122002)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)

> **One command to start. Opens in your browser. Everything just works.**

</div>

---

## 📖 Table of Contents

- [🏗️ Architecture](#%EF%B8%8F-architecture)
- [✨ Features](#-features)
- [📦 Prerequisites](#-prerequisites)
- [⚡ Quick Start](#-quick-start)
- [🛠️ Project Structure](#%EF%B8%8F-project-structure)
- [🌐 Service URLs & Ports](#-service-urls--ports)
- [🔧 Configuration](#-configuration)
- [📜 Available Scripts](#-available-scripts)
- [🔌 API Reference](#-api-reference)
- [🐳 Docker Commands Cheat Sheet](#-docker-commands-cheat-sheet)
- [🔨 Build & Publish Images](#-build--publish-images)
- [🚨 Troubleshooting](#-troubleshooting)
- [📚 DevOps Glossary](#-devops-glossary)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Network                          │
│                                                             │
│  ┌──────────────┐     ┌──────────────┐     ┌────────────┐  │
│  │   Frontend   │────▶│   Backend    │────▶│  Database  │  │
│  │   (React)    │     │   (Flask)    │     │ (Postgres) │  │
│  │  nginx:alpine│     │  gunicorn    │     │  16-alpine │  │
│  │  Port: 8081  │     │  Port: 5000  │     │ Port: 5433 │  │
│  └──────────────┘     └──────────────┘     └────────────┘  │
│         ▲                                        │          │
│         │                               ┌────────────────┐  │
│    Your Browser                         │   db_data Vol  │  │
│    localhost:8081                       │  (Persistent)  │  │
│                                         └────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Request flow:**

```
User (Browser) → Frontend (React/Nginx) → Backend API (Flask) → Database (PostgreSQL)
localhost:8081        :80 inside container      :5000                    :5432
```

---

## ✨ Features

| Feature | Details |
|---|---|
| 🐳 **Fully Containerized** | All 3 tiers run in isolated Docker containers |
| 💾 **Persistent Storage** | PostgreSQL data survives container restarts via named volumes |
| ❤️ **Health Checks** | Docker waits for each service to be healthy before starting the next |
| 🔄 **Reverse Proxy** | Nginx routes `/api/*` calls to the Flask backend automatically |
| 📦 **Pre-built Images** | Pull from Docker Hub — no local builds required |
| 🚀 **One-Command Start** | `./start.sh` spins everything up and confirms it's running |
| 🔒 **Env-based Config** | Secrets & settings live in `.env`, never hard-coded |
| 🏗️ **Multi-stage Builds** | Slim production images via Docker multi-stage Dockerfiles |

---

## 📦 Prerequisites

You only need **one** thing installed on your machine:

| Requirement | Version | Download |
|---|---|---|
| 🐳 Docker Desktop | Latest | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) |

> **That's it.** Node.js, Python, and PostgreSQL are all bundled inside the containers. You don't install them on your machine.

---

## ⚡ Quick Start

### Option A — Automated (Recommended)

```bash
# 1. Clone the repository
git clone https://github.com/warrier2002/3-tier_Docker_app.git
cd 3-tier_Docker_app

# 2. Set up environment variables
cp .env.example .env

# 3. Launch with the startup script (starts + verifies health automatically)
./start.sh
```

The script will:

1. Run `docker compose up -d`
2. Poll the backend health endpoint until it responds
3. Poll the frontend until it responds
4. Print the URL to open — **or** a detailed error if something fails

### Option B — Manual

```bash
# 1. Set up environment variables
cp .env.example .env

# 2. Start all containers in detached (background) mode
docker compose up -d

# 3. Check that all 3 containers are healthy
docker compose ps

# 4. Open your browser
#    👉 http://localhost:8081
```

### To stop the application

```bash
docker compose down           # stops containers, keeps database data
docker compose down -v        # stops containers AND deletes database data
```

---

## 🛠️ Project Structure

```
3-tier_Docker_app/
│
├── 📄 docker-compose.yml      # Orchestrates all 3 services together
├── 📄 .env.example            # Template for environment variables
├── 📄 .env                    # Your actual secrets (git-ignored)
├── 📄 start.sh                # Smart startup script with health checks
├── 📄 README.md               # This file
│
├── 📁 frontend/               # React SPA served by Nginx
│   ├── Dockerfile             # Multi-stage: Node (build) → Nginx (serve)
│   ├── nginx.conf             # Reverse-proxies /api/* to the backend
│   ├── src/
│   │   ├── App.jsx            # Main UI component (CRUD interface)
│   │   ├── api.js             # Fetch-based API client
│   │   └── styles.css         # Glassmorphism UI styles
│   └── package.json
│
└── 📁 backend/                # Flask REST API + Gunicorn WSGI server
    ├── Dockerfile             # Multi-stage: builder → slim runtime
    ├── app.py                 # API routes: /api/items, /health
    └── requirements.txt       # Python dependencies
```

---

## 🌐 Service URLs & Ports

| Service | URL | Internal Port | External Port |
|---|---|---|---|
| 🖥️ **Frontend** | <http://localhost:8081> | `80` | `8081` |
| ⚙️ **Backend API** | <http://localhost:5000> | `5000` | `5000` |
| 🔍 **Backend Health** | <http://localhost:5000/health> | `5000` | `5000` |
| 🗄️ **PostgreSQL DB** | `localhost:5433` | `5432` | `5433` |

---

## 🔧 Configuration

Copy `.env.example` to `.env` and edit as needed:

```dotenv
# ── Docker Hub ──────────────────────────────────────────────
DOCKERHUB_USER=youruser          # Your Docker Hub username

# ── PostgreSQL ───────────────────────────────────────────────
POSTGRES_USER=appuser            # Database username
POSTGRES_PASSWORD=apppass        # Database password (change in production!)
POSTGRES_DB=appdb                # Database name
POSTGRES_PORT=5432               # Internal DB port
POSTGRES_HOST=db                 # Service name (used inside Docker network)
```

> ⚠️ **Never commit your `.env` file to version control.** It's already in `.gitignore`.

---

## 📜 Available Scripts

### `./start.sh` — Smart Startup Script

```bash
./start.sh                       # Uses docker-compose.yml (default)
./start.sh docker-compose.yml    # Specify a custom compose file
```

What it does:

- ✅ Starts all services in detached mode
- ✅ Waits up to **120 seconds** for the backend health endpoint
- ✅ Waits up to **120 seconds** for the frontend to respond
- ✅ Prints a success banner with the URL
- ❌ On failure: dumps the last 40 lines of logs and exits with code `1`

---

## 🔌 API Reference

Base URL: `http://localhost:8081/api`

### Items Endpoints

| Method | Endpoint | Description | Body |
|---|---|---|---|
| `GET` | `/api/items` | List all items | — |
| `POST` | `/api/items` | Create a new item | `{"name": "...", "description": "..."}` |
| `PUT` | `/api/items/:id` | Update an item | `{"name": "...", "description": "..."}` |
| `DELETE` | `/api/items/:id` | Delete an item | — |
| `GET` | `/health` | Backend health check | — |

### Example cURL Requests

```bash
# ── Create an item ──────────────────────────────────────────
curl -X POST http://localhost:8081/api/items \
  -H 'Content-Type: application/json' \
  -d '{"name": "Mechanical Keyboard", "description": "Cherry MX Blue switches"}'

# ── List all items ──────────────────────────────────────────
curl http://localhost:8081/api/items

# ── Update item #1 ──────────────────────────────────────────
curl -X PUT http://localhost:8081/api/items/1 \
  -H 'Content-Type: application/json' \
  -d '{"name": "Keyboard v2", "description": "Silent switches"}'

# ── Delete item #1 ──────────────────────────────────────────
curl -X DELETE http://localhost:8081/api/items/1

# ── Health check ────────────────────────────────────────────
curl http://localhost:5000/health
```

---

## 🐳 Docker Commands Cheat Sheet

```bash
# ── Lifecycle ────────────────────────────────────────────────
docker compose up -d              # Start all services in background
docker compose down               # Stop & remove containers (keeps data)
docker compose down -v            # Stop, remove containers AND volumes (data lost)
docker compose restart backend    # Restart only the backend service

# ── Monitoring ──────────────────────────────────────────────
docker compose ps                 # Show running containers & health status
docker compose logs -f            # Stream live logs from all services
docker compose logs -f backend    # Stream live logs from backend only
docker compose logs --tail=50     # Last 50 lines from all services

# ── Debugging ────────────────────────────────────────────────
docker compose exec backend sh    # Open a shell inside the backend container
docker compose exec db psql -U appuser -d appdb  # Connect to the database
docker stats                      # Real-time CPU / memory usage
```

---

## 🔨 Build & Publish Images

Want to build and push your own images? Follow these steps:

```bash
# 1. Log in to Docker Hub
docker login

# 2. Build both images
docker build -t <your-dockerhub-user>/3tier-backend:latest  ./backend
docker build -t <your-dockerhub-user>/3tier-frontend:latest ./frontend

# 3. Push to Docker Hub
docker push <your-dockerhub-user>/3tier-backend:latest
docker push <your-dockerhub-user>/3tier-frontend:latest

# 4. Update .env to point to your images
#    DOCKERHUB_USER=<your-dockerhub-user>

# 5. Re-pull and start
docker compose pull && docker compose up -d
```

### Pre-built Images on Docker Hub

| Image | Link |
|---|---|
| 🖥️ Frontend | [harshit122002/3tier-frontend](https://hub.docker.com/r/harshit122002/3tier-frontend) |
| ⚙️ Backend | [harshit122002/3tier-backend](https://hub.docker.com/r/harshit122002/3tier-backend) |

---

## 🚨 Troubleshooting

| Problem | Cause | Solution |
|---|---|---|
| `Port already in use` | Another app is using `8081`, `5000`, or `5433` | Close the conflicting app, or change the port mapping in `docker-compose.yml` |
| Page loads but buttons don't work | Backend still starting | Wait ~15s and refresh. Run `docker compose ps` to check health status. |
| `Cannot connect to Docker daemon` | Docker Desktop isn't running | Open Docker Desktop and wait for it to fully start |
| Database connection error | DB not ready yet | Run `docker compose ps` — wait for `db` to show `healthy` |
| Want a clean slate | Stale data or config | Run `docker compose down -v && docker compose up -d` |
| `./start.sh: Permission denied` | Script not executable | Run `chmod +x start.sh` then try again |
| Images not found | Wrong `DOCKERHUB_USER` in `.env` | Check `.env` — `DOCKERHUB_USER` must match the Docker Hub account |

---

## 📚 DevOps Glossary

> New to DevOps? Here's what every term in this project means in plain English.

| Term | Plain-English Meaning |
|---|---|
| **Image** | A pre-packaged snapshot of an app with everything it needs to run (like a `.zip` of software). |
| **Container** | A running copy of an image — the actual live process. |
| **Docker Compose** | A tool that reads `docker-compose.yml` and starts multiple containers together as a group. |
| **Volume** | A named storage area that lives outside the container, so your data survives restarts. |
| **Port mapping** | A bridge: `8081:80` means "if I visit port 8081 on my machine, forward it to port 80 inside the container." |
| **`.env` file** | A file of key=value settings (like passwords) that Docker reads at startup. |
| **Health check** | A periodic test Docker runs to confirm a container is actually working, not just running. |
| **`depends_on`** | Tells Docker Compose: "don't start this container until *that* one is healthy." |
| **Reverse proxy** | Nginx acts as a traffic director: requests to `/api/*` are forwarded to the Flask backend. |
| **Multi-stage build** | A Dockerfile technique: use a large image to build, then copy only the output into a tiny image. |
| **Gunicorn** | A production-grade Python server that runs the Flask app (better than `flask run` alone). |
| **Detached mode (`-d`)** | Starts containers in the background so your terminal is freed up. |

---

<div align="center">

**Made with ❤️ as a DevOps learning project**

*From Product Support → DevOps Engineer — one container at a time.*

</div>
