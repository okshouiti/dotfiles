#Requires -Version 7.0

# `~\OneDrive\ドキュメント\PowerShell\profile.ps1` includes this file

# 定数定義
Set-Variable -Name DOTFILE_DIR `
    -Value "$HOME\OneDrive\repo\dotfiles" `
    -Option Constant `
    -Scope Global `
    -Description "設定ファイルが置いてあるディレクトリパス"

# ウィンドウタイトル変更
(Get-Host).UI.RawUI.WindowTitle = "PS Core"



function Invoke-AddiotionalProfile() {
    $profile_xxx = "$HOME\OneDrive\repo\dotfiles-xxx\powershell\profile.ps1"
    . $profile_xxx
}




# ====================================================
# ===============  プロンプトスタイル  ===============
# ====================================================

# Install-Module posh-git -Scope CurrentUser
# Install-Module oh-my-posh -AllowPrerelease -Scope CurrentUser
Import-Module posh-git
Import-Module oh-my-posh
#   posh3組み込みテーマ一覧  https://ohmyposh.dev/docs/themes
Set-PoshPrompt "$DOTFILE_DIR\windows\posh3_theme_Dark.json"





# ====================================================
# ======================  文字  ======================
# ====================================================

[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$ENV:LESSCHARSET = "utf-8"





# ====================================================
# =================  便利プラグイン  =================
# ====================================================

# Get-ChildItemColor - 色付きls
#   Install-Module -AllowClobber Get-ChildItemColor
Import-Module Get-ChildItemColor

# Terminal-Icons
# Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons

# ====================================================
# =================  開発補助  =================
# ====================================================
function Convert-GraalNative() {
    param (
        [Parameter(Mandatory)]
		[string] $JarFile
        , [string] $ExeName = "mybin.exe"
	)
    $graal_gu = "$ENV:GRAALVM_HOME\bin\gu.cmd"

    if (-not (Test-Path $graal_gu)) {
        & $graal_gu install native-image
    }

    $native_image_exe = "$ENV:GRAALVM_HOME\bin\native-image.cmd"
    $vscode_envvars_bat = "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

    $cmd_commands = "call `"$vscode_envvars_bat`" & call $native_image_exe --no-fallback -jar $JarFile $ExeName & exit"
    & cmd /k $cmd_commands
}
