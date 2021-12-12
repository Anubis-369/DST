<#-------------------------------------------------
ファイルからの読み込み変換処理

---------------------------------------------------#>

Function Add-FileInfo {
    <#
        .SYNOPSIS
        FileInfoを付け加える関数。
    #>
    param(
        [Parameter(ValueFromPipeline = $True, Mandatory = $true)]
        [psobject]$PSObject,
        [string]$Filepath,
        [bool]$Execute = $false
    )
    begin {
        $Fileinfo = Get-ItemProperty $Filepath
    }
    process {
        if ($Execute -eq $false) {
            $PSObject
        }
        else {
            $PSObject | Add-Member -MemberType NoteProperty -Name "__Fileinfo" -Value $Fileinfo -PassThru
        }
    }
}

Function Import-DSTdatafile {
    <#
        .SYNOPSIS
        データ単位で文字列を区切っていく関数。
    #>
    param (
        [Parameter(ValueFromPipeline = $True, Mandatory = $true)]
        [string[]]$Fullname,
        [string]$DataName = "",
        [string]$Schema = "",
        [switch]$Fileinfo
    )

    begin { if ($Schema -ne "") { $PSO_Schema = Convert-DSTSchema $Schema } else { $PSO_Schema = @() } }
    process {
        $Fullname | % {
            $Contents = Get-Content -Path $_ -Raw -Encoding utf8
            ConvertTo-DSTPSobject -Contents $Contents -Schema $PSO_Schema -Dataname $DataName `
            | Add-FileInfo -Filepath $_ -Execute $Fileinfo
        }
    }
}