$env.config = {
    show_banner: false
}



#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@  Custom Command  @@@@@@@@@@@@@@@@@@@@@@@@@
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
def ok [] {}

# Random octal
def "ok rand" [] {
    # ランダムに0から7までの値を3桁生成
    let digits = [1 2 3] | each { random int 0..7 }

    # 生成した3桁の値を表示
    print $"--- ($digits | str join) ---"

    # # 各桁を2進数3桁に変換し
    let bits = $digits | each { format bits | into string | str reverse | str substring 0..2 | str reverse }

    # 2進数の桁を1なら●、0なら○で表示
    $bits | each { split chars | each {|b| if $b == '1' { '●' } else { '○' }} | str join } | str join " " | echo $in
}

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
        "--format-sort"
            "res,vcodec:vp9"
        "--embed-metadata"
        "--embed-subs"
        "--sub-langs"
            "ja,en"
        "--embed-chapters"
        "--embed-thumbnail"
        "--no-mtime"
        "--output"
            "【%(uploader)s】　%(title)s.%(ext)s"
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

# sort and rename
def "ok rename" [
  url?: string
  --execute
  --basename: string
] {
    let $files = ls | sort-by name --natural

    let $range = 0..($files | length | $in - 1)
    let $digits = $files | length | into string | str length
    for $it in $range {
        let $target = $files | get $it | get name

        let $count =  $it + 1 | fill --alignment right --character '0' --width $digits

        mut $result = if $basename != null {$basename + " " + $count} else {$count}
        $result += "."
        $result += ($target | split row "." | reverse | get 0)

        if $execute {
            mv $target $result
        }
        print ($target + " → " + $result)
    }
}