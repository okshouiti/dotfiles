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
	# SN850 (Main Drive)
    New-SmbShare `
        -Name "C" `
        -Path "C:\" `
        -ReadAccess $mail `
        -ConcurrentUserLimit 2 `
        -Description "C-drive"

    # On non-laptop Config
    if($machine_type -eq 1){
		# SN550
        New-SmbShare `
            -Name "Data SSD" `
            -Path "D:\" `
            -ReadAccess $mail `
            -ConcurrentUserLimit 4 `
            -Description "Data archive SSD"

		# SN700
		New-SmbShare `
            -Name "Temp Working" `
            -Path "X:\" `
            -ReadAccess $mail `
            -ConcurrentUserLimit 4 `
            -Description "Temporary working SSD"

		# A2000
        New-SmbShare `
            -Name "Temp Data" `
            -Path "Z:\" `
            -ReadAccess $mail `
            -ConcurrentUserLimit 4 `
            -Description "Temporary working SSD"
    }
}
