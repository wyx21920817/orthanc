@echo off
setlocal enabledelayedexpansion

:: Script to run all docker-compose files in sequence for AIClinic
:: Windows batch script

echo Starting all AIClinic docker services...

:: Step 1: Run the main docker-compose file (orthanc and mongodb)
echo Step 1: Starting Orthanc and MongoDB services...
docker-compose -f "%~dp0docker-compose.yml" up -d
if %ERRORLEVEL% neq 0 (
    echo Error starting Orthanc and MongoDB services. Exiting.
    exit /b 1
)
echo Orthanc and MongoDB services started successfully.

:: Wait for Orthanc to be fully ready
echo Waiting for Orthanc to be ready...
set attempts=0
set max_attempts=10
set ready=false

:ORTHANC_WAIT_LOOP
if "%ready%"=="false" (
    if %attempts% lss %max_attempts% (
        set /a attempts+=1
        curl -s -f "http://localhost:8042/system" > nul 2>&1
        if %ERRORLEVEL% equ 0 (
            set ready=true
            echo Orthanc is ready!
        ) else (
            echo Waiting for Orthanc to be ready ^(attempt !attempts! of !max_attempts!^)...
            timeout /t 5 /nobreak > nul
            goto ORTHANC_WAIT_LOOP
        )
    )
)

if "%ready%"=="false" (
    echo Orthanc did not become ready in time. Continuing anyway...
)

:: Step 2: Run the web frontend
echo Step 2: Starting Web Frontend...
docker-compose -f "%~dp01 web\docker-compose.yml" up -d
if %ERRORLEVEL% neq 0 (
    echo Error starting Web Frontend. Exiting.
    exit /b 1
)
echo Web Frontend started successfully.

:: Step 3: Run the web server
echo Step 3: Starting Web Server...
docker-compose -f "%~dp02 web server\docker-compose.yml" up -d
if %ERRORLEVEL% neq 0 (
    echo Error starting Web Server. Exiting.
    exit /b 1
)
echo Web Server started successfully.

:: Step 4: Run the AI server
echo Step 4: Starting AI Server...
docker-compose -f "%~dp03 aiserver\docker-compose.yml" up -d
if %ERRORLEVEL% neq 0 (
    echo Error starting AI Server. Exiting.
    exit /b 1
)
echo AI Server started successfully.

:: Step 5: Run the AI agent
echo Step 5: Starting AI Agent...
docker-compose -f "%~dp04 aiagent\docker-compose.yml" up -d
if %ERRORLEVEL% neq 0 (
    echo Error starting AI Agent. Exiting.
    exit /b 1
)
echo AI Agent started successfully.

echo All AIClinic services have been started successfully!
echo You can access the following services:
echo - Orthanc Web Interface: http://server_ip:8042
echo - AIClinic Web Frontend: http://server_ip:3000
echo - Web Server API: http://server_ip:18000
echo - Auth Server: http://server_ip:18001
echo - AI Server: http://server_ip:10000
echo - AI Agent: http://server_ip:18888

pause
