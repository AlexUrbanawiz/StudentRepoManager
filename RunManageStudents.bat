@ECHO OFF
@REM SET ThisScriptsDirectory=%~dp0
@REM SET PowerShellScriptPath=%ThisScriptsDirectory%ManageStudentRepo.ps1
@REM PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%PowerShellScriptPath%""' -Verb RunAs}";
start powershell -command "& '.\ManageStudentRepo.ps1'
