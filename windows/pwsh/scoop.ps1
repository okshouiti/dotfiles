function Install-Scoop(){
    Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
}



function Config-Scoop(){
    $ scoop config aria2-warning-enabled false
    $ scoop config cache_clean_after_install true
}



function Install-ScoopPackages($machine_type){
    # Add cli-apps
    & scoop install git
    & scoop install 7zip aria2 bun duckdb fastfetch ffmpeg flac gcc gh git imagemagick innounp jq kubeconform kubectl less lessmsi libavif libjxl libwebp mediainfo minikube neovim nodejs nu opencode openssl opus-tools pnpm qaac rclone rust rustup starship ugrep uv witr x265 yt-dlp

    # Add gui-apps
    & scoop bucket add extras
    & scoop install cpu-z darktable everything everythingtoolbar git-credential-manager github gpu-z handbrake helium hwinfo hyper mediainfo-gui mkvtoolnix nomacs obsidian persepolis picocrypt sharpapp shutup10 textadept windowsdesktop-runtime-lts wiztree zed

    # Add nonportable-apps
    & scoop bucket add nonportable
    & scoop install icaros-np

    # Add fonts
    #& scoop bucket add nerd-fonts
    #& scoop install open-sans raleway

    # Add apps for non-laptop PC
    if($machine_type -eq 1){
        & scoop install cpu-z crystaldiskinfo crystaldiskmark flac gimp gpu-z handbrake mkvtoolnix
    }
}



# install Spotify and config tool
# follow this guide ↓
#   https://github.com/TheRandomLabs/Scoop-Spotify#installing-and-customizing-spotify

# cd "$(spicetify -c | Split-Path)\Themes\Dribbblish"
# Copy-Item dribbblish.js ..\..\Extensions
# spicetify config extensions dribbblish.js
# spicetify config current_theme Dribbblish color_scheme dracula
# spicetify config inject_css 1 replace_colors 1 overwrite_assets 1
# spicetify apply
#   set opacity on windows control ↓
#       add `--transparent-window-controls` after .exe in shortcuts target
#       or use `SpotifyNoControl.exe`
