# ========================================
# 最適化スクリプト（管理者権限で実行前提）
# 各操作完了後にわかりやすくメッセージを表示します
# ========================================

# 1. 固定キー（Shiftキー5回連打）無効化設定
#   StickyKeys, Keyboard Response, ToggleKeys のFlags値を変更して無効化
try {
    Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\StickyKeys" -Name "Flags" -Value "506" -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\Keyboard Response" -Name "Flags" -Value "122" -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\\Control Panel\\Accessibility\\ToggleKeys" -Name "Flags" -Value "58" -Force -ErrorAction Stop
    Write-Host "✅ 固定キー無効化が完了しました！" -ForegroundColor Green
} catch {
    Write-Host "❌ 固定キーの無効化に失敗しました: $_" -ForegroundColor Red
}


# 2. 電源プランを「高パフォーマンス」に切り替え
#   SCHEME_MIN は高パフォーマンスのプリセットプランID
try {
    $result = powercfg -setactive SCHEME_MIN 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 電源プランの切り替えが完了しました！" -ForegroundColor Green
    } else {
        Write-Host "❌ 電源プランの切り替えに失敗しました: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ 電源プランの切り替えに失敗しました: $_" -ForegroundColor Red
}


# 2.5 高速スタートアップを無効化
#   高速スタートアップは、シャットダウン時にハイブリッド休止状態を使うため、トラブルの原因になることもある
#   レジストリと電源構成を両方変更する必要がある

try {
    # レジストリキーを変更して無効化
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Force -ErrorAction Stop
    
    # hibernate自体を無効化（不要なhiberfil.sys削除も兼ねる）
    $hibernateResult = powercfg -hibernate off 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ hibernateの無効化で警告: $hibernateResult" -ForegroundColor Yellow
    }
    
    Write-Host "✅ 高速スタートアップの無効化が完了しました！" -ForegroundColor Green
} catch {
    Write-Host "❌ 高速スタートアップの無効化に失敗しました: $_" -ForegroundColor Red
}


# 3. ゲームモードを有効化
#   ゲーム中のパフォーマンス最適化を促進する設定
try {
    # GameBarキーが存在しない場合は作成する
    if (-not (Test-Path "HKCU:\\Software\\Microsoft\\GameBar")) {
        New-Item -Path "HKCU:\\Software\\Microsoft\\GameBar" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\GameBar" -Name "AllowAutoGameMode" -Value 1 -Force -ErrorAction Stop
    Write-Host "✅ ゲームモード有効化が完了しました！" -ForegroundColor Green
} catch {
    Write-Host "❌ ゲームモードの有効化に失敗しました: $_" -ForegroundColor Red
}


# 4. ウィンドウのアニメーションと透過効果を無効化
#   パフォーマンス向上のため視覚効果を減らす
try {
    Set-ItemProperty -Path "HKCU:\\Control Panel\\Desktop\\WindowMetrics" -Name "MinAnimate" -Value "0" -Force -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" -Name "EnableTransparency" -Value 0 -Force -ErrorAction Stop
    Write-Host "✅ アニメーションと透過効果の無効化が完了しました！" -ForegroundColor Green
} catch {
    Write-Host "❌ アニメーションと透過効果の無効化に失敗しました: $_" -ForegroundColor Red
}


# 5. OneDriveの自動起動停止（サインイン時）
#   OneDriveの自動起動を停止し、スタートアップ登録を削除
try {
    $onedrive = "$env:LOCALAPPDATA\\Microsoft\\OneDrive\\OneDrive.exe"
    if (Test-Path $onedrive) {
        Start-Process $onedrive "/shutdown" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3 # 停止完了待機
        Write-Host "📴 OneDriveプロセスを終了しました" -ForegroundColor Yellow
    }
    
    # レジストリキーの存在チェックと削除
    $regPath = "HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Run"
    $oneDriveValue = Get-ItemProperty -Path $regPath -Name "OneDrive" -ErrorAction SilentlyContinue
    
    if ($oneDriveValue) {
        Remove-ItemProperty -Path $regPath -Name "OneDrive" -Force -ErrorAction Stop
        Write-Host "✅ OneDrive自動起動停止が完了しました！" -ForegroundColor Green
    } else {
        Write-Host "✅ OneDriveはすでに自動起動が無効化されています" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ OneDrive自動起動停止に失敗しました: $_" -ForegroundColor Red
}

# ※ OneDrive完全無効化（アンインストール）を行う場合は以下を有効化
# Start-Process "C:\\Windows\\SysWOW64\\OneDriveSetup.exe" "/uninstall" -Wait


# 6. ChromeのダウンロードフォルダをDドライブに変更（WindowsのDownloadsフォルダのリダイレクト）
$downloadsPath = "D:\Downloads"

# Dドライブの存在確認
if (-Not (Test-Path "D:\")) {
    Write-Host "⚠️ Dドライブが存在しません。標準のDownloadsフォルダを使用します。" -ForegroundColor Yellow
    $downloadsPath = "$env:USERPROFILE\Downloads"
} else {
    Write-Host "✅ Dドライブが確認できました。" -ForegroundColor Green
}

# 指定フォルダが存在しなければ作成
if (-Not (Test-Path $downloadsPath)) {
    try {
        New-Item -ItemType Directory -Path $downloadsPath -Force | Out-Null
        Write-Host "📁 ディレクトリを作成しました: $downloadsPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ ディレクトリの作成に失敗しました: $downloadsPath" -ForegroundColor Red
        Write-Host "   標準のDownloadsフォルダを使用します。" -ForegroundColor Yellow
        $downloadsPath = "$env:USERPROFILE\Downloads"
    }
}

# レジストリのUser Shell Foldersキーを更新してDownloadsのパスを変更
# {374DE290-123F-4565-9164-39C4925E467B} はDownloadsフォルダのGUID
try {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
        -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value $downloadsPath -Force
    Write-Host "✅ Downloadsフォルダを $downloadsPath に変更しました！" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Downloadsフォルダの変更に失敗しました: $_" -ForegroundColor Red
}


# スクリプト全体の完了メッセージ
Write-Host "✅ 最適化スクリプトの実行が完了しました！" -ForegroundColor Green