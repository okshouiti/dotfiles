# `~\OneDrive\ドキュメント\PowerShell\profile.ps1` includes this file

# 定数定義
Set-Variable -Name DOTFILE_DIR `
    -Value "$HOME\OneDrive\asset\dotfiles" `
    -Option Constant `
    -Scope Global `
    -Description "設定ファイルが置いてあるディレクトリパス"
Set-Variable -Name ENCODER_DIR `
    -Value "$HOME\OneDrive\asset\encoder" `
    -Option Constant `
    -Scope Global `
    -Description "エンコーダのバイナリが置いてあるディレクトリパス"

#$config_dir = "$HOME\OneDrive\asset\dotfiles"
#$encoder_dir = "$HOME\OneDrive\asset\encoder"

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

# zoxide - cdコマンド代替
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell) -join "`n"
})

# bat - ハイライト付きcat
function b($file) {
    & bat --theme=TwoDark $file
}

# julialts - LTS版juliaを起動するコマンド
function julialts() {
    & "$HOME\AppData\Local\Julia-1.0.5\bin\julia.exe"
}

function Rename-Sort {
    $items = Get-ChildItem -File | Sort-Object {<#[int]#>$_.Basename}
    $digits = ($items.Length -split '').Count - 2
    Write-Host "Renamed"
    for ($i=0; $i -lt $items.Length; $i++) {
        $src = $items[$i].Name
        $dst = ([string]($i+1)).PadLeft($digits, '0') + $items[$i].Extension
        Rename-Item -Path $src -NewName $dst
        Write-Host (" "*4 + $dst + "  from  " + $src)
    }
}





# ====================================================
# =================  マルチメディア  =================
# ====================================================

function webp() {
    $files = Get-ChildItem -File | Where-Object {$_.Extension -eq ".png"}
    foreach ($f in $files) {
        $src = $f.FullName
        $dest = "$($f.BaseName).webp"
        & cwebp -z 9 -m 6 -mt -noalpha -lossless -metadata none -progress $src -o $dest
    }
}


function heic() {
    $files = Get-ChildItem -File | Where-Object {$_.Extension -eq ".png"}
    foreach ($f in $files) {
        $src = $f.FullName
        & "$ENCODER_DIR\heifenc.exe" --quality 55 -p x265:preset=placebo -p x265:tu-intra-depth=4 --no-alpha --no-thumb-alpha $src
    }
}


# png→avif変換
# オプション → https://github.com/link-u/cavif/blob/master/doc/ja_JP/usage.md
function avif() {
    $files = Get-ChildItem -File | Where-Object {$_.Extension -eq ".png"}
    foreach ($f in $files) {
        $src = $f.Name
        $dst = $f.BaseName + ".avif"
        & "$ENCODER_DIR\cavif.exe" -i $src -o $dst `
            --profile 1 `
            --pix-fmt "yuv444" `
            --bit-depth 8 `
            --encoder-usage "good" `
            --rate-control "q" `
            --crf 20 `
            --threads 12
    }
}


function realsr($outExt = ".webp") {
    $targets = @(".png", ".jpg", ".webp")
    $files = Get-ChildItem -File | Where-Object {$_.Extension -in $targets}
    foreach ($f in $files) {
        if ($f.Extension -eq $outExt) {
            $dest = "realsr___$($f.BaseName).$outExt"
        } else {
            $dest = "$($f.BaseName).$outExt"
        }
        & "$ENCODER_DIR\realsr\realsr-ncnn-vulkan.exe" -i $f.FullName -o $dest
    }
}


function extract_frames($rate = "10") {
    $targets = @(".mp4", ".mkv", ".webm")
    $files = Get-ChildItem -File | Where-Object {$_.Extension -in $targets}
    foreach ($f in $files) {
        & ffmpeg -i $f.Name -r "1/$rate" -vcodec png "$($f.DirectoryName)\frames\%06d-$($f.BaseName).png"
    }
}