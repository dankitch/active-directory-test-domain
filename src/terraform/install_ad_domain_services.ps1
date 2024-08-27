[CmdletBinding()]

param 
( 
    [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$Domain_DNSName,
    [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [string]$Domain_NETBIOSName ,
    [Parameter(ValuefromPipeline = $true, Mandatory = $true)] [String]$SafemodeAdministratorPassword
)

$SMAP = ConvertTo-SecureString -AsPlainText $SafemodeAdministratorPassword -Force

Install-Windowsfeature -name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName $Domain_DNSname -DomainNetbiosName $Domain_NETBIOSName  -ForestMode "WinThreshold" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SkipPreChecks -SafeModeAdministratorPassword $SMAP