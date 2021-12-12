
Function Convert-SchemaPSO {
    <#
        .SYNOPSIS
        Split-Hash で生成されたHashを受け取って、Schema用のSchenaPSObjectを生成する。
    #>

    param(
        [Parameter(Mandatory=$true)]
        [psobject[]]$BasicPSO,
        [string]$DataName=""
    )

    foreach($element in $BasicPSO ){
        $Parameters = @{
            Member  = "";   # String
            Name    = $element.index; # String
            Split   = "";   # List or Array
            Type    = "";   # Typename as string
            Format  = "";   # Join or Text
            Indent  = 0     # [int32]
            Nest    = $null # Nested Object
        }

        $Parameter_Values = $element.Parameter -split ","

        foreach ( $parameter in $Parameter_Values ){
            $parameter_array = ($parameter.Trim()) -split "="
            $Name  = $parameter_array[0].Trim();
            $Value = $parameter_array[1].Trim();

            if ( $Parameters.ContainsKey($Name) ) {
                $Parameters[$Name] = $Value
            } else {
                Write-Warning ("{0} is not Parameter." -f $Name)
            }
        }

        $Dy_Value = $element.value

        $Parameters.Add("Data",$DataName)

        If ($Parameters.Type -eq "Nest") {
            $Header = (
                (([regex]"^(?<header>(:?\s|\S)*?)(?=`n.+(?::|\s*: ))").Match($Dy_Value)
            ).Groups["header"].Value).Trim()
        
            $Nest_PSO = Split-BasicPSO $Dy_Value
            $Parameters.Nest = Convert-SchemaPSO -BasicPSO $Nest_PSO
            $Parameters.Add("Description",$Header)
        } else {
            $Parameters.Add("Description",$Dy_Value)
        }

        New-Object PSObject -Property $Parameters | `
        Select-Object Data,Member,Name,Split,Type,Format,Indent,Description,Nest
    }
} 

Function Convert-DSTSchema {
    <#
    .SYNOPSIS
    スキーマを読み込んでPSObjectに出力する。

    .Description

    .EXAMPLE

    .EXAMPLE

    .PARAMETER Sheet

    .PARAMETER Property
    
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$FullName,
        [string]$Encoding = "UTF8"
    )

    $Contents  = Get-Content -Encoding $Encoding -Path $FullName -Raw
    $Data_List = Split-Data -Contents $Contents

    foreach($Data in $Data_List) {
        $Data_Name   = $Data | % Name
        $Data_Schema = $Data | % Contents
        $BasicPSO    = Split-BasicPSO -Contents $Data_Schema
        
        Convert-SchemaPSO -BasicPSO $BasicPSO -Dataname $Data_Name
    }
}
    