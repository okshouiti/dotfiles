$env.config = {
    show_banner: false
}

const saku_exe = (
    $nu.home-dir
    | path join "repo" "saku" "_build" "native" "debug" "build" "cmd" "main" "main.exe"
)


#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@  Custom Command  @@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
def ok [] {}


# yt-dlp
def "ok ytdl" [
  url?: string
  --audioonly
  --limit_fhd
  --batchfile: string
  --cookies: string
] {
    use std

    mut $options = [
        "--js-runtimes"
            "bun"
        "--format-sort"
            "res,vcodec:vp9"
        "--embed-metadata"
        "--embed-subs"
        "--sub-langs"
            "ja,en"
        "--embed-chapters"
        "--embed-thumbnail"
        "--no-mtime"
        "--retry-sleep"
            "fragment:exp=5:20"
        "--output"
            "【%(uploader)s】　%(title)s　%(id)s.%(ext)s"
    ]

    # Youtubeではav1よりvp9を優先
    if ($url | is-empty) {
    } else if ($url | str contains "www.youtube.com") {
        std log info "Site: Youtube"
        $options = ($options | append ["--format-sort" "res,vcodec:vp9"])
    } else {
        std log info "Site: Not Youtube"
    }

    if $audioonly {
        $options = ($options | append ["--format" "bestaudio" "--extract-audio"])
    } else if $limit_fhd {
        $options = ($options | append ["--format" "bv[height<=1080]+ba"])
    }

    # ログイン状態でのみ落とせる動画用にクッキー設定
    if $cookies != null {
        $options = ($options | append ["--cookies" $cookies])
    }

    if $batchfile != null {
        $options = ($options | append ["--batch-file" $batchfile])
    } else if $url != null {
        $options = ($options | append $url)
    } else {
        return
    }

    let $cmd = $options | str join ' '
    std log info $cmd

    ^yt-dlp ...$options
}


def "ok helium" [] {
    ^helium --remote-debugging-port=9222 --remote-allow-origins=* --user-data-dir=/tmp/helium-cdp
}


def "ok winch" [
  url: string
  --limit: int = 1,
  --cdp-port: int = 9222,
  --headful,
  --debug] {
    let $cdp_url: string = $"http://localhost:($cdp_port)"
    ^node $env.WINCH_BIN $url --out ./test-download --limit $limit --cdp-url $cdp_url --headful --debug
}


def "ok rand" [] {
    ^$saku_exe rand
}


const rename_modes = ["head", "tail", "sort", "regex", "template"]
def "nu-complete ok rename mode" [] {
  $rename_modes
}

def "ok rename" [
    mode: string@"nu-complete ok rename mode",
    --pattern: string,
    --replace: string,
    --template: string,
    --name,
    --date,
    --desc,
    --execute
] {
    if $mode not-in $rename_modes {
        error make { msg: "unknown mode." }
    }

    mut args = [rename $mode]

    if $pattern != null { $args = ($args | append [--pattern $pattern]) }
    if $replace != null { $args = ($args | append [--replace $replace]) }
    if $template != null { $args = ($args | append [--template $template]) }
    if $name { $args = ($args | append [--name]) }
    if $date { $args = ($args | append [--date]) }
    if $desc { $args = ($args | append [--desc]) }
    if $execute { $args = ($args | append [--execute]) }

    ^$saku_exe ...$args
}


# ================================== Multi media ==================================

const encoder_dir = ($nu.home-dir | path join "OneDrive" "asset" "encoder")

# カレントディレクトリの PNG を可逆 WebP に変換する。
def "ok webp" [] {
    let files = ls | where type == file | where {|f| ($f.name | path parse | get extension | str lowercase) == "png" }
    for f in $files {
        let dest = ($f.name | path parse | update extension "webp" | path join)
        ^cwebp -z 9 -m 6 -mt -noalpha -lossless -metadata none -progress $f.name -o $dest
    }
}

# カレントディレクトリの PNG を HEIC に変換する。
def "ok heic" [] {
    let exe = ($encoder_dir | path join "heifenc.exe")
    let files = ls | where type == file | where {|f| ($f.name | path parse | get extension | str lowercase) == "png" }
    for f in $files {
        ^$exe --quality 55 -p x265:preset=placebo -p x265:tu-intra-depth=4 --no-alpha --no-thumb-alpha $f.name
    }
}

# カレントディレクトリの PNG / JPG を AVIF に変換する。
def "ok avif" [] {
    let files = ls | where type == file | where {|f| ($f.name | path parse | get extension | str lowercase) in [png jpg] }
    for f in $files {
        let dest = ($f.name | path parse | update extension "avif" | path join)
        ^avifenc --speed 4 --jobs 10 --min 20 --max 63 --codec aom --advanced end-usage=q --advanced cq-level=30 $f.name $dest
    }
}

# PNG / JPG / WebP を高解像度化する。同じ拡張子の入力は別名で保存する。
def "ok realsr" [out_ext: string = "webp"] {
    let extension = ($out_ext | str trim --left --char "." | str lowercase)
    if ($extension | is-empty) {
        error make {msg: "出力拡張子を指定してください。"}
    }
    let exe = ($encoder_dir | path join "realsr" "realsr-ncnn-vulkan.exe")
    let files = ls | where type == file | where {|f| ($f.name | path parse | get extension | str lowercase) in [png jpg webp] }
    for f in $files {
        let parts = ($f.name | path parse)
        let stem = if ($parts.extension | str lowercase) == $extension { $"realsr___($parts.stem)" } else { $parts.stem }
        let dest = ($parts | update stem $stem | update extension $extension | path join)
        ^$exe -i $f.name -o $dest
    }
}

# 指定秒ごとに動画のフレームを frames ディレクトリへ抽出する。
def "ok frames" [--rate: int = 10] {
    if $rate <= 0 {
        error make {msg: "抽出間隔は正の秒数を指定してください。"}
    }
    let files = ls | where type == file | where {|f| ($f.name | path parse | get extension | str lowercase) in [mp4 mkv webm] }
    if ($files | is-empty) { return }
    let dest_dir = ($env.PWD | path join "frames")
    mkdir $dest_dir
    for f in $files {
        let stem = ($f.name | path parse | get stem)
        let dest = ($dest_dir | path join $"%06d-($stem).png")
        ^ffmpeg -i $f.name -r $"1/($rate)" -vcodec png $dest
    }
}

# 元動画の先頭から数えたフレーム番号を指定区間に焼き込む。
def "ok frame-number" [
    file: path
    --begin: string = "00:00:00"
    --end: string = "00:00:10"
    --tail # 元の PowerShell 同様、映像パケット数を表示する。
] {
    let src = ($file | path expand --strict)
    if $tail {
        ^ffprobe -v error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of csv=p=0 $src
    } else {
        let parts = ($src | path parse)
        let dest = ($parts.parent | path join $"($parts.stem)---frames.mp4")
        let filter = "drawtext=text='%{frame_num}': start_number=1: x=5+0*print(tw): y=5+0*print(th): fontcolor=black: fontsize=60: box=1: boxcolor=white: boxborderw=10"
        ^ffmpeg -hide_banner -loglevel level+warning -stats -i $src -s 960x540 -vf $filter -ss $begin -to $end -vcodec h264_nvenc -cq 40 -preset fast -an $dest
    }
}

# 指定区間を再エンコードせず切り出す。開始位置はキーフレームに依存する。
def "ok video-scene" [
    file: path
    --begin: string = "00:00:10"
    --end: string = "00:00:20"
] {
    let src = ($file | path expand --strict)
    let seconds = [$begin $end] | each {|time|
        if $time !~ '^\d+:[0-5]\d:[0-5]\d$' {
            error make {msg: "時刻は HH:MM:SS 形式で指定してください。"}
        }
        let parts = ($time | split row ":" | into int)
        $parts.0 * 3600 + $parts.1 * 60 + $parts.2
    }
    let duration = $seconds.1 - $seconds.0
    if $duration <= 0 {
        error make {msg: "終了時刻は開始時刻より後にしてください。"}
    }
    let dest = ($src | path dirname | path join $"cut___($src | path basename)")
    ^ffmpeg -ss $begin -i $src -t $duration -codec copy $dest
}


def "ok video2webp" [
  --fps: int = 30
  --quality: int = 80
] {
    use std

    let $files = ls ...(glob *.{mp4,mkv,webm})

    let $range = 0..($files | length | $in - 1)
    for $it in $range {
        let $target: string = $files | get $it | get name | str replace -r '^(.+)\\' ''
        let $out_name = $target | str replace -r '(.+).(mp4|mkv|webm)' '$1.webp'
        std log info $"($target) → ($out_name)"

        ^ffmpeg -i $target -vcodec libwebp -lossless 0 -loop 0 -preset default -an -vsync 0 -filter:v fps=($fps) -compression_level 6 -quality ($quality) $out_name
    }
}


def "ok compress" [file: path] {
    let out = $"($file).7z"

    if ($file | str ends-with ".safetensors") {
        # safetensors: バランス設定 (mx=5)
        ^7z a -t7z -m0=LZMA2 -mx=5 -mmt=on $out $file
    } else {
        # それ以外: 最高圧縮 (mx=9)
        ^7z a -t7z -m0=LZMA2 -mx=9 -mmt=on $out $file
    }
}
