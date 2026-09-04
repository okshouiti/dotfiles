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

# avifenc --speed 4 --jobs 10 --min 20 --max 63 --codec aom --advanced end-usage=q --advanced cq-level=20 $src $dst


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
