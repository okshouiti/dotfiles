
function Install-Scoop(){
    iwr -useb get.scoop.sh | iex
}



function Install-ScoopPackages($machine_type){
    # install cli-apps in main bucket
    & scoop install git 7zip bat bottom ffmpeg gsudo imagemagick julia less libwebp mediainfo micro neofetch opus-tools pwsh rclone sqlite tldr youtube-dl zoxide
    # install gui-apps in extras bucket
    & scoop bucket add extras
    & scoop install alacritty ccleaner deskpins everything ferdi foxit-reader github hwinfo libreoffice-stable mediainfo-gui miniconda3 mpc-be nomacs onefetch powertoys rufus sharpapp shutup10 taskbarx typora ueli vcredist2010 vcredist2017 vscode-portable wiztree
    # install nonportable-apps
    & scoop bucket add nonportable
    & scoop install icaros-np
    # install fonts
    & scoop bucket add nerd-fonts
    & scoop install open-sans raleway
    # install WSL distro
    & scoop bucket add wsl
    & scoop bucket add spotify https://github.com/TheRandomLabs/Scoop-Spotify.git
    & scoop install spotify-latest
    & scoop install spicetify-cli spicetify-themes
    & spicetify config current_theme Arc-Dark color_scheme Aritim-Dark
    & spicetify apply
    if($machine_type -eq 1){
        & scoop install audacity cpu-z crystaldiskinfo crystaldiskmark draw.io gimp gpu-z handbrake mkvtoolnix picard qaac
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