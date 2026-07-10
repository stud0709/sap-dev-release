@echo off
cd /d "%~dp0"
echo Starting SAP-Bridge HTTP/SSE Daemon on port 58454...
..\bin\sap-bridge.exe -port 58454
pause
