@echo off
title PDK Fritzing Library Installer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-PDK-Fritzing-Library.ps1"
if errorlevel 1 pause
