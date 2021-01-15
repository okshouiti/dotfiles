function Set-PrivateConnection($machine_type){
    if($machine_type -eq 1){
        $name = "ネットワーク"
    } else {
        $name = "AKIRA"
    }
    Get-NetConnectionProfile -Name $name | Set-NetConnectionProfile -NetworkCategory private
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
        -Name "C" `
        -Path "C:\" `
        -ReadAccess $mail `
        -ConcurrentUserLimit 2 `
        -Description "C-drive"
    if($machine_type -eq 1){
        New-SmbShare `
            -Name "Data SSD" `
            -Path "E:\" `
            -ReadAccess $mail `
            -ConcurrentUserLimit 2 `
            -Description "Data archive SSD"
        New-SmbShare `
            -Name "TEMP SSD" `
            -Path "D:\" `
            -ChangeAccess $mail `
            -ConcurrentUserLimit 2 `
            -Description "Temporary working SSD"
    }
}
