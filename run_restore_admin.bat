@echo off
:: このスクリプトは restore.ps1 を管理者権限で実行するためのラッパー

set scriptPath=%~dp0restore.ps1

powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \"%scriptPath%\"' -Verb RunAs"