function Set-PrivateConnection($machine_type){
    Get-NetConnectionProfile | ForEach-Object { $_ | Set-NetConnectionProfile -NetworkCategory private
}

function Set-CloudflareDns($machine_type){
    if($machine_type -eq 1){
        $alias = "イーサネット"
    } else {
        $alias = "Wi-Fi"
    }
    Set-DnsClientServerAddress `
        -InterfaceAlias $alias `
        -ServerAddresses 1.1.1.1, 1.0.0.1, 2606:4700:4700::1111, 2606:4700:4700::1001
}

function Set-FileShare($machine_type, $mail){
    New-SmbShare `
        -Name "Desktop" `
        -Path (Join-Path -Path $HOME -ChildPath "Desktop") `
        -ReadAccess $mail `
        -ConcurrentUserLimit 2 `
        -Description "Desktop"
    New-SmbShare `
    -Name "OneDrive" `
    -Path (Join-Path -Path $HOME -ChildPath "OneDrive") `
    -ReadAccess $mail `
    -ConcurrentUserLimit 2 `
    -Description "OneDrive"
}
