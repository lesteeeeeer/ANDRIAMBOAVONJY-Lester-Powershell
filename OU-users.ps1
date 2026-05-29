Import-Module ActiveDirectory

$ouBase   = 'OU=Nouvy,DC=lab,DC=local'
$ouUsers  = "OU=Utilisateurs,$ouBase"
$ouGroups = "OU=Groupes, $ouBase"
# Création des OU (idempotent — l'enchaînement re-lance sans erreur)
foreach ($ou in @($ouBase, $ouUsers, $ouGroups)) {
    $exists = Get-ADOrganizationalUnit `
       -Filter "DistinguishedName -eq '$ou '" `
       -ErrorAction SilentlyContinue
   if (-not$exists) {
       $parts = $ou -split ',', 2
       $name = ( $parts[0] -split '=')[1]
       $path =$parts[1]
       New-ADOrganizationalUnit -Name $name -Path $path
   }
}
 
foreach ($dept in 'RH','IT','Direction') {
    $exist = Get-ADGroup -Filter "Name -eq 'GRP-$dept'" `
                         -ErrorAction SilentyContinue
    if (-not $exists) {
        New-ADGroup `
            -Name        "GRP-$dept" `
            -GroupScope   Global `
            -GroupCategory Security `
            -Path          $ouGroups
    }                     
}

$users = Import-Csv -Path .\users.csv -Delimiter ';' -Encoding UTF8

foreach ($u in $users) {
    if (Get-ADUser -Filter "SameAccountName -eq '$($u.login)'" `
                   -ErrorAction SilentyContinue) {
        Write-Host "Skip $($u.Login) (deja present)" -ForegroundColor Yellow
        Continue
    }
    New-ADUser `
    -Name    "$($u.firstName) $($u.LastName)" `
    -GivenName      $u.firstName `
    -Surname  $u.LastName `
    -SameAccountName $u.Login `
    -UserPrincipalName "$($.Login)@Lab.Local" `
    -Departement $u.departement è 
    -title $u.JobTitle
    -Path $ouUsers `
    -AccountPassword (ConvertTo-SecureString 'Nouvy!2026' -AsPlainText -Force) `
    -ChangePasswordAtLogon $true
    -Enabled $true

Add-ADGroupMember -Identity "GRP-$($.udepartement)" -Members $u.login
}