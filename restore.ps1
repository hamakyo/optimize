# ========================================
# 最適化スクリプトの設定を元に戻すスクリプト（管理者権限で実行前提）
# 各操作完了後にわかりやすくメッセージを表示します
# ========================================

Write-Host "⚠️ システム設定を元の状態に復元中です..." -ForegroundColor Yellow

# 1. 固定キー（Shiftキー5回連打）を標準設定に戻す
#   StickyKeys, Keyboard Response, ToggleKeys のFlags値を標準に変更
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "510" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value "126" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Value "62" -Force
Write-Host "✅ 固定キー設定を標準に戻しました！" -ForegroundColor Green


# 2. 電源プランを「バランス」に変更
#   SCHEME_BALANCED はバランスのプリセットプランID
powercfg -setactive SCHEME_BALANCED
Write-Host "✅ 電源プランをバランスに戻しました！" -ForegroundColor Green


# 2.5 高速スタートアップを有効化
#   高速スタートアップを再度有効にする
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 1 -Force
powercfg -hibernate on
Write-Host "✅ 高速スタートアップを有効化しました！" -ForegroundColor Green


# 3. ゲームモードを無効化（標準設定に戻す）
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0 -Force
Write-Host "✅ ゲームモードを標準設定に戻しました！" -ForegroundColor Green


# 4. ウィンドウのアニメーションと透過効果を有効化
#   視覚効果を標準に戻す
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "1" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1 -Force
Write-Host "✅ アニメーションと透過効果を有効化しました！" -ForegroundColor Green


# 5. OneDriveの自動起動を有効化
#   OneDriveの自動起動を元に戻す
$onedriveCmd = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
if (Test-Path $onedriveCmd) {
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /t REG_SZ /d "$onedriveCmd" /f
    Write-Host "✅ OneDrive自動起動を有効化しました！" -ForegroundColor Green
} else {
    Write-Host "⚠️ OneDriveが見つかりません。手動で設定してください。" -ForegroundColor Yellow
}


# 6. Downloadsフォルダをデフォルトに戻す
#   元の標準Downloadsパス（%USERPROFILE%\Downloads）に復元
$defaultDownloadsPath = "$env:USERPROFILE\Downloads"

# 標準Downloadsフォルダが存在しなければ作成
if (-Not (Test-Path $defaultDownloadsPath)) {
    New-Item -ItemType Directory -Path $defaultDownloadsPath -Force | Out-Null
}

# レジストリのUser Shell Foldersキーを更新してDownloadsのパスを標準に戻す
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
    -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value $defaultDownloadsPath -Force

Write-Host "✅ Downloadsフォルダを標準の場所に戻しました！" -ForegroundColor Cyan

# エクスプローラーの再起動を提案
Write-Host "💡 変更を反映させるため、エクスプローラーの再起動をお勧めします:" -ForegroundColor Yellow
Write-Host "   タスクマネージャーでエクスプローラーを終了→再開" -ForegroundColor Yellow
Write-Host "   または Ctrl+Shift+Esc → 詳細 → エクスプローラーを右クリック → 再開" -ForegroundColor Yellow

# スクリプト全体の完了メッセージ
Write-Host ""
Write-Host "✅ 復元スクリプトの実行が完了しました！" -ForegroundColor Green
Write-Host "🔄 再起動することをお勧めします。" -ForegroundColor Cyan