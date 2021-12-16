. $PSScriptRoot\..\..\DST\Base.ps1
. $PSScriptRoot\..\..\DST\Schema.ps1
. $PSScriptRoot\..\..\DST\Convert.ps1
. $PSScriptRoot\..\..\DST\Read.ps1

$OnSchema = Import-DSTdatafile -Fullname $PSScriptRoot\Test_Data.txt -Dataname "Data1" -Schema $PSScriptRoot\Schema.txt

$NoSchema = Import-DSTdatafile -Fullname $PSScriptRoot\Test_Data.txt -Dataname "Data1" -fileinfo 
