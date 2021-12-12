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

    $Title_S = "(?:\S+?)(?: +\[[\S ]+?\])?(?:\s+): "
    $Title_SC = "(?<index>\S+?)(?: +\[(?<param>[\S ]+?)\])?(?<indent>\s+): "

    # 単行の見出し
    $Title_1L = "(?<=(?:^|\n)){0}" -f $Title_S
    $Capture_1L = "(?<=(?:^|\n)){0}" -f $Title_SC

    # 単行複数の見出し
    $Capture_1LMC = "(?<=(?:{0}[^\n]*? , (?:{1}[^\n]*? , )*)){2}" -f $Title_1L,$Title_S,$Title_SC

    $Title_1LA = "(?<=(?:^|\n| , )){0}" -f $Title_S

    # 複数行の見出し
    $Title_M = "(?<=(?:^|\n))(?:\S+?)(?: +\[[\S\s]+?\])?:(?:\r\n(?:\s+)|\n(?:\s+)|(?:$))"
    $Capture_M = "(?<=(?:^|\n))(?<index>\S+?)(?: +\[(?<param>[\S\s]+?)\])?:(?:\r\n(?<indent>\s+)|\n(?<indent>\s+)|(?<indent>$))"

    $capture = "(?:$Capture_1L|$Capture_1LMC|$Capture_M)"
    $Title = "(?:$Title_1LA|$Title_M)"
    $Main_Regex  = [regex]"$capture(?<value>[\S\s]*?(?=(?:$|$Title| , (?=$Title))))"

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