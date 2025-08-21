@echo off
:: このスクリプトは PowerShell を管理者権限で実行するためのラッパー

set scriptPath=%~dp0optimize.ps1

powershell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -File \\"%scriptPath%\\"' -Verb RunAs"