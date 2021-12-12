. $PSScriptRoot\..\..\Dynamis\Base.ps1
. $PSScriptRoot\..\..\Dynamis\Schema.ps1
. $PSScriptRoot\..\..\Dynamis\Count.ps1
. $PSScriptRoot\..\..\Dynamis\Write.ps1

$Schema = Convert-DSTSchema $PSScriptRoot\Schema.txt

$PSO = Get-Service | Select-Object -First 10
Convert-DSTString -PSObject $PSO -Dataname "Data1" -Schema $PSScriptRoot\Schema.txt