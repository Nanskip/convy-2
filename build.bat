@echo off
title Building Project...

echo Running Python build script...
python build_project.py

if errorlevel 1 (
    echo.
    echo [ERROR] The build script exited with an error.
) else (
    echo.
    echo [SUCCESS] Build completed successfully.
)

echo.
pause >nul
