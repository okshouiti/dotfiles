
function Install-Scoop(){
    iwr -useb get.scoop.sh | iex
}



function Config-Scoop(){
    $ scoop config aria2-warning-enabled false
}



function Install-ScoopPackages($machine_type){
    # Add cli-apps
    & scoop install git
    & scoop install 7zip aria2 bat bottom broot deno duf fd ffmpeg flac gsudo imagemagick julia less libwebp macchina mediainfo neovim nodejs-lts nu opus-tools pwsh qaac rclone scoop-search tre-command ugrep x265 yarn youtube-dl zoxide

    # Add gui-apps
    & scoop bucket add extras
    & scoop install alacritty deskpins draw.io everything foxit-reader github hwinfo mediainfo-gui miniconda3 mp3tag mpc-be nomacs notepadplusplus onefetch persepolis rufus sharex sharpapp sharpkeys shutup10 taskbarx typora ueli vcredist2010 vcredist2015 vcredist2017 vcredist2019 vivaldi vscode-portable wiztree

    # Add nonportable-apps
    & scoop bucket add nonportable
    & scoop install icaros-np

    # Add fonts
    #& scoop bucket add nerd-fonts
    #& scoop install open-sans raleway

    # Add WSL
    #& scoop bucket add wsl

    # Add Spotify
    #& scoop bucket add spotify https://github.com/TheRandomLabs/Scoop-Spotify.git
    #& scoop install spotify-latest
    #& scoop install spicetify-cli spicetify-themes
    #& spicetify config current_theme Arc-Dark color_scheme Aritim-Dark
    #& spicetify apply

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