# `~\OneDrive\ドキュメント\PowerShell\profile.ps1` includes this file

$config_dir = "$HOME\OneDrive\asset\dotfiles"

# ウィンドウタイトル変更
(Get-Host).UI.RawUI.WindowTitle = "PS Core"



# ====================================================
# ===============  プロンプトスタイル  ===============
# ====================================================
# Install-Module posh-git -Scope CurrentUser
# Install-Module oh-my-posh -AllowPrerelease -Scope CurrentUser
Import-Module posh-git
Import-Module oh-my-posh
#   posh3組み込みテーマ一覧  https://ohmyposh.dev/docs/themes
Set-PoshPrompt (Join-Path -Path $config_dir -ChildPath "windows\posh3_theme_Dark.json")



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

# zoxide - cdコマンド代替
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell) -join "`n"
})

# bat - ハイライト付きcat
function Read-FileWithBat($file) {
    & bat --theme=TwoDark $file
}
Set-Alias b Read-FileWithBat

# stylus - CSSメタ言語
function Compile-Stylus($target){
    $node = "$HOME\scoop\apps\nodejs\current\node.exe"
    $styl = "$HOME\scoop\apps\nodejs\current\bin\node_modules\stylus\bin\stylus"
    & $node $styl -c $target
}
Set-Alias stylus Compile-Stylus



# ====================================================
# =================  マルチメディア  =================
# ====================================================
function Convert-PNGtoWEBP(){
    $files = Get-ChildItem -File | Where-Object {$_.Extension -eq ".png"}
    Foreach ($f in $files) {
        $src = $f.FullName
        $dest = "$($f.BaseName).webp"
        & cwebp -z 9 -m 6 -mt -noalpha -lossless -metadata none -progress $src -o $dest
    }
}
Set-Alias webp Convert-PNGtoWEBP

function Convert-PNGtoHEIF(){
    $files = Get-ChildItem -File | Where-Object {$_.Extension -eq ".png"}
    $encoder = "$HOME\OneDrive\asset\encoder\heifenc.exe"
    Foreach ($f in $files) {
        $src = $f.FullName
        & $encoder --quality 55 -p x265:preset=placebo -p x265:tu-intra-depth=4 --no-alpha --no-thumb-alpha $src
    }
}
Set-Alias heic Convert-PNGtoHEIF