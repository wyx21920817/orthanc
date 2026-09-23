#!/bin/bash

# Script to run all docker-compose files in sequence for AIClinic
# macOS bash script

# Define colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Define the base directory (directory where this script is located)
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env file
if [ -f "$BASE_DIR/.env" ]; then
    echo -e "${CYAN}Loading environment variables from .env file...${NC}"
    export $(grep -v '^#' "$BASE_DIR/.env" | xargs)
    echo -e "${GREEN}Environment variables loaded successfully.${NC}"
else
    echo -e "${YELLOW}Warning: .env file not found. Using default values.${NC}"
fi

echo -e "${GREEN}Starting all AIClinic docker services...${NC}"

# Step 1: Run the main docker-compose file (orthanc and mongodb)
echo -e "${CYAN}Step 1: Starting Orthanc and MongoDB services...${NC}"
docker compose -f "$BASE_DIR/docker-compose.yml" up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Error starting Orthanc and MongoDB services. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN}Orthanc and MongoDB services started successfully.${NC}"

# Wait for Orthanc to be fully ready
echo -e "${YELLOW}Waiting for Orthanc to be ready...${NC}"
attempts=0
max_attempts=10
ready=false

while [ "$ready" = false ] && [ $attempts -lt $max_attempts ]; do
    attempts=$((attempts+1))
    if docker logs orthanc 2>&1 | grep -q "Orthanc has started"; then
        ready=true
        echo -e "${GREEN}Orthanc is ready!${NC}"
    else
        echo -e "${YELLOW}Waiting for Orthanc to be ready (attempt $attempts of $max_attempts)...${NC}"
        sleep 5
    fi
done

if [ "$ready" = false ]; then
    echo -e "${YELLOW}Orthanc did not become ready in time. Continuing anyway...${NC}"
fi

# Step 2: Run the web frontend
echo -e "${CYAN}Step 2: Starting Web Frontend...${NC}"
docker compose -f "$BASE_DIR/1 web/docker-compose.yml" up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Error starting Web Frontend. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN}Web Frontend started successfully.${NC}"

# Step 3: Run the web server
echo -e "${CYAN}Step 3: Starting Web Server...${NC}"
docker compose -f "$BASE_DIR/2 web server/docker-compose.yml" up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Error starting Web Server. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN}Web Server started successfully.${NC}"

# Step 4: Run the AI server
echo -e "${CYAN}Step 4: Starting AI Server...${NC}"
docker compose -f "$BASE_DIR/3 aiserver/docker-compose.yml" up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Error starting AI Server. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN}AI Server started successfully.${NC}"

# Step 5: Run the AI agent
echo -e "${CYAN}Step 5: Starting AI Agent...${NC}"
docker compose -f "$BASE_DIR/4 aiagent/docker-compose.yml" up -d
if [ $? -ne 0 ]; then
    echo -e "${RED}Error starting AI Agent. Exiting.${NC}"
    exit 1
fi
echo -e "${GREEN}AI Agent started successfully.${NC}"

echo ""
echo -e "${GREEN}All AIClinic services have been started successfully!${NC}"
echo -e "${CYAN}You can access the following services:${NC}"
echo -e "- Orthanc Web Interface: http://${SERVER_IP:-localhost}:${ORTHANC_PORT:-8042}"
echo -e "- AIClinic Web Frontend: http://${SERVER_IP:-localhost}:${FRONTEND_PORT:-3000}"
echo -e "- Web Server API: http://${SERVER_IP:-localhost}:${WEBSERVER_PORT:-18000}"
echo -e "- Auth Server: http://${SERVER_IP:-localhost}:18001"
echo -e "- AI Server: http://${SERVER_IP:-localhost}:${AISERVER_PORT:-10000}"
echo -e "- AI Agent: http://${SERVER_IP:-localhost}:${AIAGENT_PORT:-18888}"
echo ""

read -p "Press Enter to continue..."
