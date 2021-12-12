. $PSScriptRoot\..\..\DST\Base.ps1
. $PSScriptRoot\..\..\DST\Schema.ps1
. $PSScriptRoot\..\..\DST\Convert.ps1

$Content = Get-Content -Path $PSScriptRoot\Test_Data.txt -Raw -Encoding utf8

$Schema   = Convert-DSTSchema $PSScriptRoot\Schema.txt
$NoSchema = ConvertTo-DSTPSobject -Contents $Content -Dataname "Data1"
$OnSchema = ConvertTo-DSTPSobject -Contents $Content -Dataname "Data1" -Schema $Schema
