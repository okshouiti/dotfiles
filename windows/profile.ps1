# `~\OneDrive\ドキュメント\PowerShell\profile.ps1` includes this file

# Yarnで入れたcliツールが置いてあるディレクトリにパスを通す
$ENV:Path += ";$(yarn global bin)"

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

# Terminal-Icons
# Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons

# zoxide - cdコマンド代替
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell) -join "`n"
})


# bat - ハイライト付きcat
function b($file) {
    & bat --theme=TwoDark $file
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

# youtube-dl
function Get-YtVideo() {
    param (
        [Parameter(Mandatory)]
        [string] $Url
        , [string] $Format = "251"
	)

    $opus_cd = "251"

    $opts = @(
        "youtube-dl"
        "-o"
            "${home}\Desktop\""%(title)s.%(ext)s"""
        "-f"
            $Format
    )
    if ($Format -eq $opus_cd) {
        $opts += @(
            "--extract-audio"
            "--audio-format"
                "opus"
        )
    } else {
        $opts += "--merge-output-format"
        $opts += "mkv"
    }
    
    $opts += @(
        "--no-mtime"
        "--console-title"
        "--add-metadata"
        "--external-downloader",
            "aria2c",
        #"--external-downloader-args",
        #    "-x 16 -s 16 -k 1M" #--download-result=hide
        $Url
    )
    $cmds = ($opts -join " ")
    Write-Host $cmds
    Invoke-Expression $cmds
    # & youtube-dl `
    #     -i
}
Set-Alias ytdl Get-YtVideo

# png→webp変換
function ConvertTo-Webp() {
    $files = Get-ChildItem -File -Filter *.png
    foreach ($f in $files) {
        $src = $f.FullName
        $dest = "$($f.BaseName).webp"
        & cwebp -z 9 -m 6 -mt -noalpha -lossless -metadata none -progress $src -o $dest
    }
}
Set-Alias webp ConvertTo-Webp


# png→heic変換
function ConvertTo-Heic() {
    $files = Get-ChildItem -File -Filter *.png
    foreach ($f in $files) {
        $src = $f.FullName
        & "$ENCODER_DIR\heifenc.exe" --quality 55 -p x265:preset=placebo -p x265:tu-intra-depth=4 --no-alpha --no-thumb-alpha $src
    }
}
Set-Alias heic ConvertTo-Heic


# png→avif変換
# オプション → https://github.com/link-u/cavif/blob/master/doc/ja_JP/usage.md
function ConvertTo-Avif() {
    $files = Get-ChildItem -File -Filter *.png
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
Set-Alias avif ConvertTo-Avif


function ConvertTo-HiRes($outExt = ".webp") {
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
Set-Alias realsr ConvertTo-HiRes


# 指定秒ごとにフレームを画像として抜き出し(エンコーダ主観画質評価用)
function Extract_Frames($rate = "10") {
    $targets = @(".mp4", ".mkv", ".webm")
    $files = Get-ChildItem -File | Where-Object {$_.Extension -in $targets}
    $dest_dir = Join-Path -Path $files[0].DirectoryName -ChildPath "frames"
    if (!(Test-Path $dest_dir)) {
        New-Item -Path $dest_dir -ItemType Directory
    }
    foreach ($f in $files) {
        & ffmpeg -i $f.Name -r "1/$rate" -vcodec png "$($dest_dir)\%06d-$($f.BaseName).png"
    }
}


# 時間区間を指定し頭から映像先頭から数えたフレーム数を書き込む
function Write-FrameNumber() {
	param (
        [Parameter(Mandatory
            , ValueFromPipeline
            , ValueFromPipelineByPropertyName)]
		[string] $File
		, [string] $Begin = "00:00:00"
		, [string] $End = "00:00:10"
        , [switch] $Tail
	)
 
	if (-not (Test-Path $File)) {
		Write-Output "Specified file does not exists."
		return
	}

    if ($Tail) {
        & ffprobe `
            -v error `
            -select_streams v:0 `
            -count_packets `
            -show_entries stream=nb_read_packets `
            -of csv=p=0 `
            $File
    } else {
        $file_name = (Get-ChildItem $File).BaseName
        $file_dir = (Get-ChildItem $File).DirectoryName
        & ffmpeg `
            -hide_banner `
            -loglevel "level+warning" `
            -stats `
            -i $File `
            -s "960x540" `
            -vf "drawtext=text='%{frame_num}': start_number=1: x=5+0*print(tw): y=5+0*print(th): fontcolor=black: fontsize=60: box=1: boxcolor=white: boxborderw=10" `
            -ss $Begin `
            -to $End `
            -vcodec "h264_nvenc" `
            -cq 40 `
            -preset "fast" `
            -an `
            (Join-Path $file_dir "${file_name}---frames.mp4")
    }
}