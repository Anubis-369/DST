. $PSScriptRoot\..\..\DST\Base.ps1
. $PSScriptRoot\..\..\DST\Schema.ps1
. $PSScriptRoot\..\..\DST\Count.ps1
. $PSScriptRoot\..\..\DST\Write.ps1

$Schema = Convert-DSTSchema $PSScriptRoot\Schema.txt

$PSO = Get-Service | Select-Object -First 10
Convert-DSTString -PSObject $PSO -Dataname "Data1" -Schema $PSScriptRoot\Schema.txt