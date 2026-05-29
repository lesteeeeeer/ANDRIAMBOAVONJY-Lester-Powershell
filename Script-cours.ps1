Add-Type -AssemblyName System.Windows.function 
Add-Type -AssemblyName System.Drawing 
# creation fenetre
$form = New-Object System.Windows.Forms.Form
$form.Text = "Configuration Serveur"
$form.StartPosition = "CenterScreen"

# creation bouton
$buttonDhcp = New-Object System.Windows.Forms.Button
$buttonDhcp.Text = "Ajout DHCP"
$buttonDhcp.Add_Click({
        [string]$scopeName = 'IsitechLocal'
        [string]$start = '192.168.31.40'
        [string]$stop = '192.168.31.90'
        [string]$mask = '255.255.255.0'
        [int]$day = 8
        [string]$dns = [Microsoft.VisualBasic.Interaction]::InputBox("Veuillez sasair le dns", "DHCP", "192.168.100.100")
        [string]$domain = 'isitech.local'
        [string]$router = '192.168.31.254'

        Install-WindowsFeature -Name DHCP -IncludeManagementTools -Restart:$false -Verbose
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12' -Name ConfigurationState -Value 2
        Add-DhcpServerv4Scope -Name $scopeName -StartRange $start -EndRange $stop -SubnetMask $mask -LeaseDuration (New-TimeSpan -Days $day) -State Active
        Set-DhcpServerv4OptionValue -DnsServer $dns -DnsDomain $domain -Router $router
})


do {
    Write-Host "========================================="
    Write-Host "================== MENU ================="
    Write-Host "========================================="
    Write-Host "1 - Ajout et configuration du role DHCP"
    Write-Host "2 - Renommer le serveur"
    Write-Host "3 - Installer et configurer AD DS"
    
    [int]$choix = Read-Host "Veuillez faire un choix"

    if ($choix -eq 1) {
        [string]$scopeName = 'IsitechLocal'
        [string]$start = '192.168.31.40'
        [string]$stop = '192.168.31.90'
        [string]$mask = '255.255.255.0'
        [int]$day = 8
        [string]$dns = Read-Host "Veuillez saisir le serveur DNS"
        [string]$domain = 'isitech.local'
        [string]$router = '192.168.31.254'

        Install-WindowsFeature -Name DHCP -IncludeManagementTools -Restart:$false -Verbose
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager\Roles\12' -Name ConfigurationState -Value 2
        Add-DhcpServerv4Scope -Name $scopeName -StartRange $start -EndRange $stop -SubnetMask $mask -LeaseDuration (New-TimeSpan -Days $day) -State Active
        Set-DhcpServerv4OptionValue -DnsServer $dns -DnsDomain $domain -Router $router
    } elseif ($choix -eq 2) {
        [string]$nomSrv = Read-Host "Veuillez saisir le nouveau nom de la machine"
        Rename-Computer -NewName $nomSrv -Restart
    } elseif ($choix -eq 3) {
        [SecureString]$password = Read-Host -AsSecureString "Veuillez entrer le mot de passe AD"
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Restart:$false -Verbose
        Install-ADDSForest `
            -DomainName 'isitech.local' `
            -DomainNetbiosName 'ISITECH' `
            -SafeModeAdministratorPassword $password `
            -InstallDns `
            -NoRebootOnCompletion:$false `
            -Force
    } else {
        Write-Host "Mauvais choix !"
    }
} while ($choix -ne 0)