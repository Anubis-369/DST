. $PSScriptRoot\..\..\DST\Base.ps1

$Plain       = Get-Content -Path $PSScriptRoot\Plain_Data.txt -Raw -Encoding utf8
$Split_Plain = Split-Data $Plain
$Hash_Plain  = $Split_Plain | %{ Split-BasicPSO $_.Contents ; echo "------"}

$Schema= Get-Content -Path $PSScriptRoot\Schema_Data.txt -Raw -Encoding utf8
$Split_Schema = Split-Data $Schema
$Hash_Schema  = $Split_Schema | %{ Split-BasicPSO $_.Contents ; echo "------"}