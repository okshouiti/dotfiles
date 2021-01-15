# --------------------------------------------------------------------------------
# ----------------------------------  Packages  ----------------------------------
# --------------------------------------------------------------------------------
function Remove-UnnecessaryPackages(){
    $package_list = @(
        "Microsoft.3DBuilder",              # 3D Builder
        "Microsoft.Microsoft3DViewer",      # 3Dビューアー
        "*Booking.com*",                    # Booking.com
        "king.com.CandyCrushSaga",          # Candy Crush Saga
        "king.com.CandyCrushSodaSaga",      # Candy Crush Soda Saga
        "Microsoft.549981C3F5F10",          # Cortana
        "DolbyLaboratories.DolbyAccess",    # Dolby Access
        "*dropbox*",                        # Dropbox
        "Facebook.Facebook",                # Facebook
        "Fitbit.FitbitCoach",               # Fitbit Coach
        "Microsoft.ZuneMusic",              # Groove ミュージック
        "KeeperSecurityInc.Keeper",         # Keeper
        "828B5831.HiddenCityMysteryofShadows",  # Hidden City アイテム探しアドベンチャー
        "7EE7776C.LinkedInforWindows",      # LinkedIn
        "*mcafee*",                         # McAfee
        "*mixedreality*",                   # Mixed Realityポータル
        "*netflix*",                        # Netflix
        "Microsoft.OfficeLens",             # Office Lens
        "Microsoft.Office.OneNote",         # OneNote
        "Microsoft.People",                 # People
        "ThumbmunkeysLtd.PhototasticCollage",  # Phototastic Collage
        "Microsoft.Print3D",                # Print3D
        "flaregamesGmbH.RoyalRevolt2",      # RoyalRevolt 2
        "89006A2E.AutodeskSketchBook",      # SketchBook
        "Microsoft.SkypeApp",               # Skypeを始めよう
        "SpotifyAB.SpotifyMusic",           # Spotify
        "Microsoft.MicrosoftStickyNotes",   # Sticky Notes
        "*twitter*",                        # Twitter
        "Microsoft.Microsoft3DViewer",      # View 3D
        "Microsoft.Xbox*",                  # Xbox
        #"Microsoft.XboxGameOverlay",       # Xbox
        #"Microsoft.XboxGamingOverlay",     # Xbox
        #"Microsoft.XboxIdentityProvider",  # Xbox
        #"Microsoft.XboxSpeechToTextOverlay",  # Xbox
        "Microsoft.MicrosoftOfficeHub",     # 新しいOffice を始めよう
        "Microsoft.WindowsAlarms",          # アラーム＆クロック
        "Microsoft.ZuneVideo",              # 映画 & テレビ
        "Microsoft.WindowsCamera",          # カメラ
        "Microsoft.ScreenSketch",           # 切り取り & スケッチ
        "Microsoft.Xbox.TCUI",              # ゲーム バー
        "Microsoft.YourPhone",              # スマホ同期／モバイル コンパニオン
        "*solitaire*",                      # ソリティア
        "Microsoft.5220175982889",          # テレBing
        "Microsoft.GetHelp",                # 問い合わせ／ヘルプの表示
        "king.com.BubbleWitch3Saga",        # バブルウィッチ3
        "Microsoft.Getstarted",             # ヒント／はじめに
        "Microsoft.WindowsFeedbackHub",     # フィードバックHub
        "Microsoft.Windows.Photos",         # フォト
        "Microsoft.MSPaint",                # ペイント3D
        "Microsoft.WindowsSoundRecorder",   # ボイスレコーダー
        "*MarchofEmpires",                  # マーチ オブ エンパイア
        "Microsoft.Wallet",                 # マイクロソフトペイ
        "Microsoft.WindowsMaps",            # マップ
        "*bing*",                           # マネー、スポーツ、ニュース、天気
        "microsoft.windowscommunicationsapps",  # メール、カレンダー
        "Microsoft.Messaging",              # メッセージング
        "Microsoft.OneConnect"              # モバイル通信プラン／有料Wi-Fi & 携帯ネットワーク
    )
    Foreach ($pkg in $package_list) {
        Get-AppxPackage $pkg | Remove-AppxPackage
    }
}



# --------------------------------------------------------------------------------
# --------------------------------  Context Menu  --------------------------------
# --------------------------------------------------------------------------------
function Remove-ContextMenu(){
    $key_block = "Registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked"
    if(Test-Path -LiteralPath $key_block){
        echo "$key_block is exist!"
    } else {
        New-Item $key_block
    }
    $block_list = @(
        "{90AA3A4E-1CBA-4233-B8BB-535773D48449}", # TaskbandPin
        "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}", # Sharing - HKCR::\Directory\shellex\ContextMenuHandlers
        "{a2a9545d-a0c2-42b4-9708-a0b2badd77c8}", # StartMenuPin - HKCR::\AllFilesystemObjects\shellex\ContextMenuHandlers
        "{7BA4C740-9E81-11CF-99D3-00AA004AE837}", # SendTo - HKCR::\AllFilesystemObjects\shellex\ContextMenuHandlers
        "{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}", # PinToHome - HKCR::\Folder\shell\
        "{470C0EBD-5D73-4d58-9CED-E91E22E23282}", # Pin to Start Screen - HKCR::\Folder\shell\
        "{3dad6c5d-2167-4cae-9914-f99e41c12cfa}"  # Library Location - HKCR::\Folder\shell\
    )
    Foreach($menu in $block_list){
        New-ItemProperty -LiteralPath $key_block -Name $menu -PropertyType 'String'
    }
}
