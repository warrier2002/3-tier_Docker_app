# 3-Tier App with Docker Compose (Beginner-Friendly)

A small app that shows how a website, a backend program, and a database work
together — all running in Docker. You start it with **one command**, and it
opens in your browser.

This repo is written for someone moving from **Product Support** into a
**DevOps Engineer** role, so every term is explained in plain English.

---

## What does this project do?

It is a simple "to-do style" app. You can add, edit, and delete items. Behind
the scenes:

- You type in the **website (frontend)**.
- The website asks the **backend program** to save the data.
- The **backend** stores it in the **database**.
- The website shows the updated list.

```
You (browser)  --->  Website  --->  Backend  --->  Database
   localhost:8081     (React)     (Flask)      (PostgreSQL)
```

---

## What you need

- **Docker Desktop** installed (this gives you `docker` and `docker compose`).
  Download from https://www.docker.com/products/docker-desktop/
- That's it. You do **not** need to install Node.js, Python, or PostgreSQL.

---

## How to run it (3 steps)

```bash
# 1. Copy the example settings file (you usually don't need to change it)
cp .env.example .env

# 2. Start everything
docker compose up -d

# 3. Open the app in your browser
#    http://localhost:8081
```

To stop it later:

```bash
docker compose down
```

---

## What just happened?

`docker compose up` did this for you:

1. **Downloaded** the 3 ready-made "images" from Docker Hub (like downloading
   pre-installed app packages).
2. **Started** 3 "containers" (running copies of those images):
   - `db` – the database (PostgreSQL)
   - `backend` – the API that talks to the database (Flask)
   - `frontend` – the website you see (React, served by nginx)
3. **Waited** for the database to be ready before starting the others (this is
   called a *health check* + *depends_on*).

You can see them running with:

```bash
docker compose ps
```

---

## The files (what each one is for)

```
docker-compose.yml   -> The "recipe" that starts all 3 containers together.
.env                  -> Settings: passwords, ports, your Docker Hub username.
.env.example          -> A safe copy of .env you can use as a template.
README.md             -> This file.

frontend/             -> The website code (React).
  Dockerfile          -> Instructions to build the website's Docker image.
  nginx.conf          -> Tells nginx to serve the site and forward /api to backend.
  src/App.jsx         -> The page you see (buttons, list, form).
  src/api.js          -> Talks to the backend using fetch().
  src/styles.css      -> The glass-style look of the page.

backend/              -> The program that saves data (Flask, Python).
  Dockerfile          -> Instructions to build the backend's Docker image.
  requirements.txt   -> Python libraries the backend needs.
  app.py              -> The API code: /api/items (add/list/edit/delete) + /health.
```

---

## Beginner glossary (DevOps words explained)

| Word            | Simple meaning                                                        |
| --------------- | --------------------------------------------------------------------- |
| **Image**       | A ready-to-run package of software (like a `.exe` installer in the cloud). |
| **Container**   | A running copy of an image (the actual running app).                  |
| **Docker Compose** | A tool that starts multiple containers together using one file.    |
| **Volume**      | A storage box that keeps your data safe even if the container restarts. |
| **Port**        | A door number. `8081` on your computer opens the website.            |
| **Environment variable (.env)** | A setting passed into the container (e.g. password).     |
| **Health check**| A small test Docker runs to see if a container is working.           |
| **depends_on**  | "Start this container only after that one is healthy."              |
| **Reverse proxy** | nginx sends `/api` requests to the backend automatically.          |

---

## Common commands (cheat sheet)

```bash
docker compose up -d      # Start everything in the background
docker compose ps        # See running containers and their health
docker compose logs -f   # Watch live logs (press Ctrl+C to stop)
docker compose down      # Stop everything (keeps the database data)
docker compose down -v   # Stop AND delete the database data
docker compose restart backend   # Restart just the backend
```

---

## Where are the images?

The website and backend images are already built and stored on Docker Hub, so
you don't have to build them:

- Frontend: https://hub.docker.com/r/harshit122002/3tier-frontend
- Backend:  https://hub.docker.com/r/harshit122002/3tier-backend

---

## Try the API directly (optional)

You can talk to the backend without the website, using `curl` or any API tool:

```bash
# Add an item
curl -X POST http://localhost:8081/api/items \
  -H 'Content-Type: application/json' \
  -d '{"name":"Keyboard","description":"wireless"}'

# See all items
curl http://localhost:8081/api/items

# Edit item number 1
curl -X PUT http://localhost:8081/api/items/1 \
  -H 'Content-Type: application/json' \
  -d '{"name":"Keyboard v2","description":"mechanical"}'

# Delete item number 1
curl -X DELETE http://localhost:8081/api/items/1
```

---

## If something goes wrong

| Problem                          | Try this                                                      |
| -------------------------------- | ------------------------------------------------------------- |
| Port already in use error        | Another app uses 8081/5000/5433. Close it, or change the port in `docker-compose.yml`. |
| Page loads but buttons don't work| Wait a few seconds; the backend may still be starting. Check `docker compose ps`. |
| Forgot how to stop it            | Run `docker compose down`.                                   |
| Want to start from scratch       | Run `docker compose down -v` then `docker compose up -d`.    |

---

## Want to rebuild the images yourself? (DevOps practice)

```bash
docker login                       # sign in to Docker Hub
docker build -t youruser/3tier-backend:latest ./backend
docker build -t youruser/3tier-frontend:latest ./frontend
docker push youruser/3tier-backend:latest
docker push youruser/3tier-frontend:latest
```

Then change `DOCKERHUB_USER` in `.env` to `youruser` and run
`docker compose up -d` again.
