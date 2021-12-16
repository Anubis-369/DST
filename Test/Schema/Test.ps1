. $PSScriptRoot\..\..\DST\Base.ps1
. $PSScriptRoot\..\..\DST\Schema.ps1

$Schema1 = Convert-DSTSchema $PSScriptRoot\Schema_1.txt
$Schema2 = Convert-DSTSchema $PSScriptRoot\Schema_2.txt
$Schema3 = Convert-DSTSchema $PSScriptRoot\Schema_3.txt

