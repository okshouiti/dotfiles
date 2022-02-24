# ===================================================
# ===============  Initiation Script  ===============
# ===================================================
# Open powershell with administrator privilege
# Run 「& "$HOME\OneDrive\asset\dotfiles\windows\___init___.ps1"」
#     「Set-ExecutionPolicy RemoteSigned」



# ===================================================
# ================  Include scripts  ================
# ===================================================
Set-Location $PSScriptRoot
. ".\pwsh\sharpen.ps1"
. ".\pwsh\network.ps1"
. ".\pwsh\scoop.ps1"
. ".\pwsh\utils.ps1"



$machine_type = Input-MachineType
$mail = (Read-Host "Write mail address of this machine's admin")



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
# enable VitualMachine for WSL
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# enable WSL
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart



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



# ===================================================
# ================  Include scripts  ================
# ===================================================
# don't block executing profile.ps1
Unblock-File -Path "$Env:OneDrive\ドキュメント\PowerShell\profile.ps1"



Set-Location ~