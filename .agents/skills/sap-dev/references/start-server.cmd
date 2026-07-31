@echo off
cd /d "%~dp0"

echo Performing Pre-Flight Prerequisite Checks...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] Node.js is not found in PATH. AST parsing and browser automation sidecar will be unavailable.
) else (
    if exist "..\..\..\package.json" (
        if not exist "..\..\..\node_modules\playwright" (
            echo [INFO] Playwright module missing. Attempting dependency installation...
            call npm install --no-audit --no-fund
            echo [INFO] Downloading Playwright browser binaries...
            call npx playwright install chromium
        )
    )
)

echo Starting SAP-Bridge HTTP/SSE Daemon on port 58454...
..\bin\sap-bridge.exe -port 58454 %*

