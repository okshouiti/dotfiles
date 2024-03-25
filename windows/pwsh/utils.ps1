function Read-MachineType {
    $type = (Read-Host "Choose Number of MachineType - [1]Desktop [2]Laptop")
    if($type -eq 1 -or $type -eq 2){
        return $type
    } else {
        Write-Output "Enter number 1 or 2"
        return Read-MachineType
    }
}

function Read-UserMailAddress {
    $mail = Get-WmiObject -Class Win32_ComputerSystem `
            | Select-Object -First 1 -Property PrimaryOwnerName `
            | ForEach-Object { $_.PrimaryOwnerName } `
            | Where-Object { $_ -match "[a-z]+@[a-z].+\.[a-z]" }
    if ($mail) {
        return $mail
    }
    # システム情報からメアド形式で取得できなかった場合
    $mail = (Read-Host "Write mail address of this machine's admin")
    if($mail -match "[a-z]+@[a-z].+\.[a-z]"){
        return $mail
    } else {
        Write-Output "Enter number 1 or 2"
        return Read-UserMailAddress
    }
}

# --------------------------------------------------------------------------------
# ------------------------------  Add Context Menu  ------------------------------
# --------------------------------------------------------------------------------
# PowerShellによるレジストリの操作例
#   https://qiita.com/mima_ita/items/1e6c74c7fb641852edff
# エクスプローラーの右クリックメニューをカスタマイズする
#   https://ascii.jp/elem/000/000/953/953807/
# 右クリックメニューからいらない項目を削除(非表示)して短くしよう！
#   https://itjo.jp/windows/context-menu-shorten/
# Get-ChildItem -LiteralPath "Registry::HKCR\*\shellex\ContextMenuHandlers"
# Test-Path -LiteralPath $key (キー存在判定)
function Add-ContextMenu($name, $cmd, $msg) {
    $key = Join-Path -Path "Registry::HKCR\Directory\Background\shell" -ChildPath $name
    $subkey = Join-Path -Path $key -ChildPath "command"
    New-Item $key
    New-Item $subkey
    Set-ItemProperty -LiteralPath $key -Name "(default)" -Value $msg
    Set-ItemProperty -LiteralPath $subkey -Name "(default)" -Value $cmd
}
