# AIClinic Docker Compose Scripts

This directory contains scripts to run all AIClinic docker-compose files in sequence.

## Available Scripts

### Windows Batch Script
- **File**: `run_all_docker_compose_windows.bat`
- **Usage**: Run this script in Command Prompt or PowerShell to start all AIClinic services in the correct order.
- **Command**:
  ```
  .\run_all_docker_compose_windows.bat
  ```

### Windows PowerShell Script
- **File**: `run_all_docker_compose_windows.ps1`
- **Usage**: Run this script in PowerShell to start all AIClinic services in the correct order.
- **Command**:
  ```powershell
  .\run_all_docker_compose_windows.ps1
  ```

### Linux Bash Script
- **File**: `run_all_docker_compose_linux.sh`
- **Usage**: Run this script in a Linux terminal to start all AIClinic services in the correct order.
- **Command**:
  ```bash
  # Make the script executable first (if not already)
  chmod +x run_all_docker_compose_linux.sh
  
  # Then run the script
  ./run_all_docker_compose_linux.sh
  ```

## Services Started

The scripts will start the following services in order:

1. **Orthanc and MongoDB** (base services)
2. **Web Frontend** (React application)
3. **Web Server** (API and authentication services)
4. **AI Server** (AI processing service)
5. **AI Agent** (AI agent service)

## Access Points

After running the script, you can access the following services:

- Orthanc Web Interface: http://localhost:8042
- AIClinic Web Frontend: http://localhost:3000
- Web Server API: http://localhost:18000
- Auth Server: http://localhost:18001
- AI Server: http://localhost:10000
- AI Agent: http://localhost:18888

## Troubleshooting

If any service fails to start, the script will exit with an error message. Check the Docker logs for more details:

```bash
# View logs for a specific container
docker logs <container_name>

# For example:
docker logs orthanc
docker logs ai_server
```
