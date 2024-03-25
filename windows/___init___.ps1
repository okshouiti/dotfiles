# ===================================================
# ===============  Initiation Script  ===============
# ===================================================
# Open powershell with administrator privilege
# Run 「& "$HOME\OneDrive\repo\dotfiles\windows\___init___.ps1"」
#     「Set-ExecutionPolicy RemoteSigned」



# ===================================================
# ================  Include scripts  ================
# ===================================================
Set-Location $PSScriptRoot
. ".\pwsh\sharpen.ps1"
. ".\pwsh\network.ps1"
. ".\pwsh\scoop.ps1"
. ".\pwsh\utils.ps1"



$machine_type = Read-MachineType
$mail = Read-UserMailAddress



# ===================================================
# ================  KonMari system  =================
# ===================================================
Remove-UnnecessaryPackages
Remove-ContextMenu



# ===================================================
# ================  Network Setting  ================
# ===================================================
Set-PrivateConnection $machine_type
Set-CloudflareDns $machine_type
Set-FileShare $machine_type $mail



# ===================================================
# ============  Enable Windows Feature  =============
# ===================================================
# enable WSL2
& wsl --install



# ===================================================
# =============  Rename Computer Name  ==============
# ===================================================
# need to reboot
if($machine_type -eq 1){
    Rename-Computer -NewName "OKPC"
} else {
    Rename-Computer -NewName "OKBook"
}



# ===================================================
# =========  Install Scoop and its packages  ========
# ===================================================
. ".\pwsh\scoop.ps1"
Install-Scoop
Config-Scoop
Install-ScoopPackages $machine_type



# ===================================================
# ================  Include scripts  ================
# ===================================================
$SCOOP = Join-Path -Path $HOME -ChildPath "\scoop\apps"
# Add "Open Alacritty here"
Add-ContextMenu `
    "Alacritty" `
    "$SCOOP\alacritty\current\alacritty.exe --working-directory `"%V`"" `
    "ここでAlacrittyを開く"
# Add "Convert all .png to .webp here"
Add-ContextMenu `
    "webp" `
    "$SCOOP\pwsh\current\pwsh.exe -nol -nop -c Get-ChildItem -File | Where-Object {`$_.Extension -eq '.png'} | ForEach-Object {& cwebp -z 9 -m 6 -mt -noalpha -lossless -metadata none -progress `$_.FullName -o (`$_.BaseName + '.webp')}" `
    "ここでPNGをWEBPに変換"
# Add "Convert all .png to .heic here"
Add-ContextMenu `
    "heic" `
    "$SCOOP\pwsh\current\pwsh.exe -nol -nop -c Get-ChildItem -File | Where-Object {`$_.Extension -eq '.png'} | ForEach-Object {& $HOME\OneDrive\asset\encoder\heifenc.exe --quality 55 -p x265:preset=placebo -p x265:tu-intra-depth=4 --no-alpha --no-thumb-alpha `$_.FullName}" `
    "ここでPNGをHEICに変換"


# CaddyなどGo製のweb系ツールの一部はレジストリからMIMEを決定する。
# 何らかの原因でjsがtext/plainになっていた場合、serveした.jsをwebアプリが実行できない問題。
# https://github.com/golang/go/issues/32350
Set-ItemProperty `
    -LiteralPath "Registry::HKCR\.js" `
    -Name "Content Type" `
    -Value "text/javascript"
Set-ItemProperty `
    -LiteralPath "Registry::HKEY_CURRENT_USER\Software\Classes\.js" `
    -Name "Content Type" `
    -Value "text/javascript"

# ExplorerのSilentCleanupからサムネイル削除処理を外す（勝手に消されないため）
Set-ItemProperty `
    -LiteralPath "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" `
    -Name "Autorun" `
    -Value "0"







#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@   Include scripts   @@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# ホームディレクトリ整理 https://zenn.dev/tantan_tanuki/articles/90e8d996f6b12a
$new_java_dir = Join-Path -Path $HOME -ChildPath ".jvmuserhome"
$current_jvm_env = [Environment]::GetEnvironmentVariable("JAVA_TOOL_OPTIONS", "USER")
[Environment]::SetEnvironmentVariable("JAVA_TOOL_OPTIONS", "${current_jvm_env} -Duser.home=${new_java_dir}", "USER")


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@   After Init   @@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# don't block executing profile.ps1
Unblock-File -Path "$Env:OneDrive\ドキュメント\PowerShell\profile.ps1"



Set-Location ~