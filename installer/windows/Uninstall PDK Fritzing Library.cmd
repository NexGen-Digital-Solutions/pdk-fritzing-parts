@echo off
title Uninstall PDK Fritzing Library
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstall-PDK-Fritzing-Library.ps1"
if errorlevel 1 pause
