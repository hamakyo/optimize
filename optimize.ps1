# ========================================
# 最適化スクリプト（管理者権限で実行前提）
# 各操作完了後にわかりやすくメッセージを表示します
# ========================================

# 1. 固定キー（Shiftキー5回連打）無効化設定
#   StickyKeys, Keyboard Response, ToggleKeys のFlags値を変更して無効化
Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\StickyKeys" -Name "Flags" -Value "506"
Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\Keyboard Response" -Name "Flags" -Value "122"
Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\ToggleKeys" -Name "Flags" -Value "58"
Write-Host "✅ 固定キー無効化が完了しました！" -ForegroundColor Green


# 2. 電源プランを「高パフォーマンス」に切り替え
#   SCHEME_MIN は高パフォーマンスのプリセットプランID
powercfg -setactive SCHEME_MIN
Write-Host "✅ 電源プランの切り替えが完了しました！" -ForegroundColor Green


# 2.5 高速スタートアップを無効化
#   高速スタートアップは、シャットダウン時にハイブリッド休止状態を使うため、トラブルの原因になることもある
#   レジストリと電源構成を両方変更する必要がある

# レジストリキーを変更して無効化
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0

# hibernate自体を無効化（不要なhiberfil.sys削除も兼ねる）
powercfg -hibernate off

Write-Host "✅ 高速スタートアップの無効化が完了しました！" -ForegroundColor Green


# 3. ゲームモードを有効化
#   ゲーム中のパフォーマンス最適化を促進する設定
Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\GameBar" -Name "AllowAutoGameMode" -Value 1
Write-Host "✅ ゲームモード有効化が完了しました！" -ForegroundColor Green


# 4. ウィンドウのアニメーションと透過効果を無効化
#   パフォーマンス向上のため視覚効果を減らす
Set-ItemProperty -Path "HKCU:\\Control Panel\\Desktop\\WindowMetrics" -Name "MinAnimate" -Value "0"
Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" -Name "EnableTransparency" -Value 0
Write-Host "✅ アニメーションと透過効果の無効化が完了しました！" -ForegroundColor Green


# 5. OneDriveの自動起動停止（サインイン時）
#   OneDriveの自動起動を停止し、スタートアップ登録を削除
$onedrive = "$env:LOCALAPPDATA\\Microsoft\\OneDrive\\OneDrive.exe"
if (Test-Path $onedrive) {
    Start-Process $onedrive "/shutdown"
    Start-Sleep -Seconds 3 # 停止完了待機
}
reg delete "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /v "OneDrive" /f
Write-Host "✅ OneDrive自動起動停止が完了しました！" -ForegroundColor Green

# ※ OneDrive完全無効化（アンインストール）を行う場合は以下を有効化
# Start-Process "C:\\Windows\\SysWOW64\\OneDriveSetup.exe" "/uninstall" -Wait


# 6. ChromeのダウンロードフォルダをDドライブに変更（WindowsのDownloadsフォルダのリダイレクト）
$downloadsPath = "D:\Downloads"

# 指定フォルダが存在しなければ作成
if (-Not (Test-Path $downloadsPath)) {
    New-Item -ItemType Directory -Path $downloadsPath -Force | Out-Null
}

# レジストリのUser Shell Foldersキーを更新してDownloadsのパスを変更
# {374DE290-123F-4565-9164-39C4925E467B} はDownloadsフォルダのGUID
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
    -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value $downloadsPath

Write-Host "✅ Downloadsフォルダを $downloadsPath に変更しました！" -ForegroundColor Cyan


# スクリプト全体の完了メッセージ
Write-Host "✅ 最適化スクリプトの実行が完了しました！" -ForegroundColor Green