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

    mut options = [
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

    if ($url | is-not-empty) {
        let site = if ($url | str contains "www.youtube.com") { "Youtube" } else { "Not Youtube" }
        std log info $"Site: ($site)"
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

    std log info ($options | str join ' ')

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
    let cdp_url = $"http://localhost:($cdp_port)"
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


# ================================== portless (Windows) ==================================

# SYSTEM で動く daemon の証明書生成には Machine スコープの OPENSSL_CONF が必要。
# User スコープでは届かず、service install が再生成する .cmd にも設定を置かない。
def "ok portless env" []: nothing -> bool {
    let result = (^powershell.exe -NoProfile -NonInteractive -Command '[Environment]::GetEnvironmentVariable("OPENSSL_CONF", "Machine")' | complete)
    if $result.exit_code != 0 { error make {msg: $result.stderr} }
    let conf = ($result.stdout | str trim)
    mut valid = true
    if ($conf | is-empty) {
        print -e '警告: OPENSSL_CONF (Machine) が未設定。SYSTEM daemon の TLS 握手が失敗します。'
        let expected = ($nu.home-dir | path join 'scoop' 'apps' 'openssl' 'current' 'bin' 'cnf' 'openssl.cnf')
        print -e $"管理者 PowerShell で設定: [Environment]::SetEnvironmentVariable\('OPENSSL_CONF','($expected)','Machine')"
        $valid = false
    } else if not ($conf | path exists) {
        print -e $"警告: OPENSSL_CONF \(Machine) = ($conf) が実在しません。"
        $valid = false
    }
    if (which openssl | is-empty) {
        print -e '警告: openssl が PATH にありません。'
        $valid = false
    }
    $valid
}

def portless-listeners []: nothing -> table {
    let result = (^powershell.exe -NoProfile -NonInteractive -Command 'ConvertTo-Json -Compress -InputObject @(Get-NetTCPConnection -LocalPort 443 -State Listen -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, OwningProcess)' | complete)
    if $result.exit_code != 0 { error make {msg: $result.stderr} }
    $result.stdout | from json
}

# 元の判定と同様、portless の所有確認ではなく 443 の待受を確認する。
def "ok portless alive" []: nothing -> bool {
    let alive = (portless-listeners | is-not-empty)
    if not $alive { print -e '警告: portless: 443 が待受状態ではありません。' }
    $alive
}

def "ok portless start" [] {
    ok portless env | ignore
    if (ok portless alive) {
        print 'portless: 起動済みです。'
        return
    }
    ^portless proxy start
    sleep 500ms
    ok portless alive | ignore
}

def "ok portless stop" [--force] {
    # 通常停止に失敗しても、明示された強制停止は実行する。
    let result = (^portless proxy stop | complete)
    print -n $result.stdout
    if ($result.stderr | is-not-empty) { print -en $result.stderr }
    if $force {
        ^powershell.exe -NoProfile -NonInteractive -Command r#'$ErrorActionPreference = "Stop"; Get-CimInstance Win32_Process -Filter "Name='node.exe'" | Where-Object { $_.CommandLine -like '*portless*proxy*start*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }'#
    } else if $result.exit_code != 0 {
        error make {msg: $"portless proxy stop が失敗しました: ($result.exit_code)"}
    }
}

def "ok portless restart" [] {
    ok portless stop --force
    sleep 1500ms
    ok portless start
}

def "ok portless status" [] {
    ^portless --version
    ^portless list
    let pid_file = ($nu.home-dir | path join '.portless' 'proxy.pid')
    if ($pid_file | path exists) {
        print $"proxy.pid: (open --raw $pid_file | str trim)"
    }
    portless-listeners
}

def "ok portless update" [] {
    ok portless stop --force
    ^bun add -g portless@latest
    ok portless start
    ^portless --version
}

const portless_aliases = {
    opencode.wsl: 44101
    makie.wsl: 44102
}

def "nu-complete ok portless alias" [] {
    $portless_aliases | columns
}

# 引数なしで組み込みを選択。名前だけなら組み込み、名前とポートなら直接指定。
# 例: ok portless alias makie.wsl → https://makie.wsl.localhost
def "ok portless alias" [
    name?: string@"nu-complete ok portless alias"
    port?: int
] {
    let name = if $name == null {
        $portless_aliases | columns | input list '登録するエイリアスを選択'
    } else { $name }
    if $name == null { return }
    let port = if $port == null {
        $portless_aliases | get -o $name
    } else { $port }
    if $port == null {
        error make {msg: '組み込み以外のエイリアスにはポートを指定してください。'}
    }
    if $port < 1 or $port > 65535 {
        error make {msg: 'ポートは 1〜65535 で指定してください。'}
    }
    ^portless alias $name $port --force
    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: 'portless のエイリアス登録に失敗しました。'}
    }
    let result = (^curl.exe -sk $"https://($name).localhost/" -o NUL -w '%{http_code}' | complete)
    if $result.exit_code != 0 {
        print -e $"警告: ($name).localhost への接続に失敗しました。TLS 証明書生成などを確認してください。curl: ($result.exit_code)"
    } else {
        print $"($name).localhost -> HTTP ($result.stdout)"
    }
}

def "ok portless unalias" [name: string] {
    ^portless alias --remove $name
}


# ================================== Multi media ==================================

const encoder_dir = ($nu.home-dir | path join "OneDrive" "asset" "encoder")

# カレントディレクトリの通常ファイルを拡張子で絞り込む。
def media-files [extensions: list<string>]: nothing -> list<string> {
    ls
    | where type == file
    | get name
    | where {|name| ($name | path parse | get extension | str lowercase) in $extensions }
}

# カレントディレクトリの PNG を可逆 WebP に変換する。
def "ok webp" [] {
    for file in (media-files [png]) {
        let dest = ($file | path parse | update extension "webp" | path join)
        ^cwebp -z 9 -m 6 -mt -noalpha -lossless -metadata none -progress $file -o $dest
    }
}

# カレントディレクトリの PNG を HEIC に変換する。
def "ok heic" [] {
    let exe = ($encoder_dir | path join "heifenc.exe")
    for file in (media-files [png]) {
        ^$exe --quality 55 -p x265:preset=placebo -p x265:tu-intra-depth=4 --no-alpha --no-thumb-alpha $file
    }
}

# カレントディレクトリの PNG / JPG を AVIF に変換する。
def "ok avif" [] {
    for file in (media-files [png jpg]) {
        let dest = ($file | path parse | update extension "avif" | path join)
        ^avifenc --speed 4 --jobs 10 --min 20 --max 63 --codec aom --advanced end-usage=q --advanced cq-level=30 $file $dest
    }
}

# PNG / JPG / WebP を高解像度化する。同じ拡張子の入力は別名で保存する。
def "ok realsr" [out_ext: string = "webp"] {
    let extension = ($out_ext | str trim --left --char "." | str lowercase)
    if ($extension | is-empty) {
        error make {msg: "出力拡張子を指定してください。"}
    }
    let exe = ($encoder_dir | path join "realsr" "realsr-ncnn-vulkan.exe")
    for file in (media-files [png jpg webp]) {
        let parts = ($file | path parse)
        let stem = if ($parts.extension | str lowercase) == $extension { $"realsr___($parts.stem)" } else { $parts.stem }
        let dest = ($parts | update stem $stem | update extension $extension | path join)
        ^$exe -i $file -o $dest
    }
}

# 指定秒ごとに動画のフレームを frames ディレクトリへ抽出する。
def "ok frames" [--rate: int = 10] {
    if $rate <= 0 {
        error make {msg: "抽出間隔は正の秒数を指定してください。"}
    }
    let files = media-files [mp4 mkv webm]
    if ($files | is-empty) { return }
    let dest_dir = ($env.PWD | path join "frames")
    mkdir $dest_dir
    for file in $files {
        let stem = ($file | path parse | get stem)
        let dest = ($dest_dir | path join $"%06d-($stem).png")
        ^ffmpeg -i $file -r $"1/($rate)" -vcodec png $dest
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

    for file in (media-files [mp4 mkv webm]) {
        let dest = ($file | path parse | update extension "webp" | path join)
        std log info $"($file) → ($dest)"

        ^ffmpeg -i $file -vcodec libwebp -lossless 0 -loop 0 -preset default -an -vsync 0 -filter:v fps=($fps) -compression_level 6 -quality $quality $dest
    }
}


def "ok compress" [file: path] {
    let out = $"($file).7z"

    # safetensors はバランス設定、それ以外は最高圧縮。
    let level = if ($file | str ends-with ".safetensors") { 5 } else { 9 }
    ^7z a -t7z -m0=LZMA2 $"-mx=($level)" -mmt=on $out $file
}
