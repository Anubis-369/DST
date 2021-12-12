. $PSScriptRoot\..\..\Dynamis\Base.ps1
. $PSScriptRoot\..\..\Dynamis\Schema.ps1
. $PSScriptRoot\..\..\Dynamis\Convert.ps1
. $PSScriptRoot\..\..\Dynamis\Read.ps1

$OnSchema = Import-DSTdatafile -Fullname $PSScriptRoot\Test_Data.txt -Dataname "Data1" -Schema $PSScriptRoot\Schema.txt

$NoSchema = Import-DSTdatafile -Fullname $PSScriptRoot\Test_Data.txt -Dataname "Data1" -fileinfo 
