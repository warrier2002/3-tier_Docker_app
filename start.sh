#!/usr/bin/env bash

set -euo pipefail

# ── Colour helpers ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }

# ── Config ──────────────────────────────────────────────────────────────────
COMPOSE_FILE="${1:-docker-compose.yml}"   # pass an alternate file as $1 if needed
FRONTEND_URL="http://localhost:8081"
BACKEND_HEALTH_URL="http://localhost:5000/health"

# How long to wait for each service (seconds)
MAX_WAIT=120
POLL_INTERVAL=5

# ── Step 1 – start all services in detached mode ─────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║   3-Tier Docker App – Startup Script         ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${RESET}"
echo ""

info "Starting services with Docker Compose (detached)…"

if ! docker compose -f "$COMPOSE_FILE" up -d --remove-orphans; then
    error "docker compose up failed. Check the output above for details."
    exit 1
fi

echo ""

# ── Helper: poll a URL until it responds 200 ────────────────────────────────
wait_for_url() {
    local name="$1"
    local url="$2"
    local elapsed=0

    info "Waiting for ${BOLD}${name}${RESET} to be reachable at ${CYAN}${url}${RESET} …"

    while true; do
        http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url" 2>/dev/null || true)

        if [[ "$http_code" == "200" ]]; then
            success "${name} is UP  (HTTP ${http_code})"
            return 0
        fi

        if (( elapsed >= MAX_WAIT )); then
            error "${name} did NOT become healthy within ${MAX_WAIT}s  (last HTTP code: ${http_code:-none})"
            return 1
        fi

        echo -e "  ${YELLOW}⏳${RESET} ${name} not ready yet (HTTP ${http_code:-n/a}) – retrying in ${POLL_INTERVAL}s  [${elapsed}/${MAX_WAIT}s]"
        sleep "$POLL_INTERVAL"
        (( elapsed += POLL_INTERVAL ))
    done
}

# ── Step 2 – wait for the backend health endpoint ───────────────────────────
if ! wait_for_url "Backend API" "$BACKEND_HEALTH_URL"; then
    error "Backend health check failed. Dumping recent logs:"
    docker compose -f "$COMPOSE_FILE" logs --tail=40 backend
    exit 1
fi

echo ""

# ── Step 3 – wait for the frontend ──────────────────────────────────────────
if ! wait_for_url "Frontend" "$FRONTEND_URL"; then
    error "Frontend health check failed. Dumping recent logs:"
    docker compose -f "$COMPOSE_FILE" logs --tail=40 frontend
    exit 1
fi

# ── Step 4 – all green ───────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${GREEN}${BOLD}║  ✅  Your application is UP and running!                     ║${RESET}"
echo -e "${GREEN}${BOLD}╠══════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${GREEN}${BOLD}║                                                              ║${RESET}"
echo -e "${GREEN}${BOLD}║  🌐  Frontend   →  http://localhost:8081                     ║${RESET}"
echo -e "${GREEN}${BOLD}║  🔧  Backend    →  http://localhost:5000/health              ║${RESET}"
echo -e "${GREEN}${BOLD}║                                                              ║${RESET}"
echo -e "${GREEN}${BOLD}║  Open your browser and navigate to:                          ║${RESET}"
echo -e "${GREEN}${BOLD}║  👉  http://localhost:8081                                   ║${RESET}"
echo -e "${GREEN}${BOLD}║                                                              ║${RESET}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ── Step 5 – show running container status ───────────────────────────────────
info "Container status:"
docker compose -f "$COMPOSE_FILE" ps
echo ""
