<#-------------------------------------------------
文字列を処理する基本的な関数

---------------------------------------------------#>

Function Split-Data {
    <#
        .SYNOPSIS
        データ単位で文字列を区切っていく関数。
    #>
    [CmdletBinding()]
    [OutputType([psobject[]])]

    param(
        [Parameter(Mandatory=$true)]
        [string]$Contents,
        [string]$Title_Delimiter="--",
        [string]$Data_Delimiter="----"
    )

    $Reg_Pattern = "{0} (?<name>\S+) {0}" -f $Title_Delimiter
    $Split_Regex = [regex]("(?<=\n|^)(?:{0})?(?<value>(?:.|\n(?!{0}(?:\n|\r\n))|$)+)" -f $Reg_Pattern)

    $Result = $Split_Regex.Matches($Contents)
    foreach($data in $Result){
        $Name      = ($data.Groups["name"].value).Trim();
        $Data      = ($data.Groups["value"].value).Trim();
        $Delimiter = "\n{0}[\r|\n]" -f $Data_Delimiter

        $Data -split $Delimiter | %{
            New-Object PSObject -Property @{
                Name     = $Name;
                Contents = $_.Trim();
            } | Select-Object Name,Contents
        }
    } 
}

Function Split-BasicPSO {
    <#
        .SYNOPSIS
        コロンで区切られたデータをハッシュテーブルに変換する関数
    #>
    [CmdletBinding()]
    [OutputType([psobject[]])]

    param (
        [Parameter(Mandatory=$true)]
        [string]$Contents,
        [string]$Delimiter = ","
    )

    # 単行の処理
    $Single_Title   = "(?:\S+?)(?: +\[[\S\s]+?\])?(?:\s+): "
    $Single_Title_C = "(?<index>\S+?)(?: +\[(?<param>[^\]]+?)\])?(?<indent>\s+): "

    $Single_String = "(?<=(?:^|\n|(?:{0} +?{1} +?)*)){2}(?<value>.*?)(?=(?:$|\r\n|\n| +?{1} +?{0}))"
    $Single_Capture = $Single_String -f $Single_Title,$Delimiter,$Single_Title_C

    # 複数行の処理
    $Multiple_Title_C = "(?<index>\S+?)(?: +\[(?<param>[^\]]+?)\])?:(?:\n|\r\n|$)?"
    $Multiple_String  = "(?<=(?:^|\n)){0}(?:(?<indent> +)(?<value>.*(?:\n +.*)*)(?:$|\n|\r\n))?"
    $Multiple_Capture = $Multiple_String -f $Multiple_Title_C

    $Main_Regex  = [regex]"(?:$Single_Capture|$Multiple_Capture)"

    $Check_Title = [System.Collections.ArrayList]::new()
    $Result      = [System.Collections.ArrayList]::new()

    Foreach ($Hit in $Main_Regex.Matches($Contents)) {
        $Indent = ("`n{0}" -f $Hit.Groups["indent"].Value)
        $Index  = ($Hit.Groups["index"].Value).Trim()

        if ( $Check_Title -notcontains $Index ) {
            $PSO_Data = New-Object -TypeName psobject -Property @{
                Index     = $Index;
                Value     = ($Hit.Groups["value"].Value -replace $Indent,"`n").Trim();
                Parameter = ($Hit.Groups["param"].Value).Trim()
            }

            [void]$Result.Add($PSO_Data)
            [void]$Check_Title.Add($Index)
        }
    }
    Return $Result
}