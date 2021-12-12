<#-------------------------------------------------
PSObjectをテキストに変換するための関数

---------------------------------------------------#>

Function Convert-WriteSchema {
    <#
        .SYNOPSIS
        スキーマのPSObjectを書き込み用のフォーマットデータへコンバートする関数。
    #>
    param(
        [psobject[]]$Schema
    )
    $Step_1 = [System.Collections.ArrayList]::new()
    $Max = 0

    foreach ( $Element in $Schema ) {
        $Count = Get-StringLength $Element.Name
        $Member = if ($Element.Header -eq "" ) { $Element.Name } else { $Element.Header }

        if ($Element.Type -in @("Text", "Join")) { $Max = 0 } else {
            if ($Count -gt $Max) { $Max = $Count }
        }

        [void]$Step_1.add([PSCustomObject]@{
                Member = $Member;
                Title  = $Element.Name;
                Count  = $Count;
                Type   = $Element.Type;
                Indent = $Element.Indent;
                End    = "`n";
                Max    = $Max;
            })
    }

    $Max = 0

    #逆順からその最大値を全データに入れていく処理
    $Step_1[($Step_1.Count - 1)..0] | % {
        if ($_.Type -in @("Text", "Join")) {
            $_.Max = 0 ; $Max = 0
        }
        else {
            if ($_.Count -gt $Max) { $Max = $_.Max; $Max = $_.Max } else { $_.Max = $Max }
        }
    }

    $Result = [System.Collections.ArrayList]::new()
    $Step_1 | % {
        $Title = $_.Title
        $Indent = $_.Max - $_.Count 
        Switch ($_.Type) {
            Text {
                $Header = "`n" + $Title + ":`n"
                $End = "`n`n"
            }
            Join {
                $Header = $Title + " : "
                $End = " , "
            }
            Default {
                $Header = $Title + (" " * $Indent) + " : "
                $End = "`n"
            }
        }

        [void]$Result.add([PSCustomObject]@{
                Member = $_.Member;
                Type   = $_.Type;
                Header = $Header;
                Indent = $_.Indent;
                End    = $End;
            })
    }

    #逆順からその最大値を全データに入れていく処理
    $Before = $False
    $Result[( $Result.Count - 1 )..0] | % {
        if ( $_.End -eq " , " ) {
            if ( $Before -eq $False ) { $_.Indent = 0 ;　$_.End = "`n" ; $Before = $True }
        }
        else { $Before = $False }
    }

    Return $Result
}

Function Convert-PSOtoString {
    <#
        .SYNOPSIS
        データ一つ分のPSObjectをフォーマットデータをもとに文字列に変換する関数。
    #>
    param(
        [psobject]$PSObject,
        [psobject[]]$WriteSchema
    )
    $Result_String = ""
    foreach ( $Member_Schema in $WriteSchema) {
        $PSO_String = (($PSObject | % $Member_Schema.Member) -as [string]).Trim()
        switch ($Member_Schema.Type) {
            Text {
                $Data_String = "  " + ($PSO_String -replace "`n", "`n  ").Trim()
            }
            Join {
                $Def_Space = $Member_Schema.Indent - (Get-StringLength $PSO_String)
                if ($Def_Space -gt 0) {
                    $Data_String = $PSO_String + (" " * $Def_Space)
                }
                else {
                    $Data_String = $PSO_String
                }
            }
            Default {
                $Data_String = $PSO_String
            }
        }
        $Result_String += $Member_Schema.Header + $Data_String + $Member_Schema.End
    }
    return $Result_String
}


function Convert-DSTString {
    <#
        .SYNOPSIS
        データ単位で文字列を区切っていく関数。
    #>
    param (
        [string]$Schema,
        [string]$Dataname,
        [psobject[]]$PSObject
    )
    $Data_Schema = Convert-DSTSchema $Schema  | ? { $_.Data -eq $Dataname }
    $Write_Schema = Convert-WriteSchema $Data_Schema

    $Result = "-- {0} --`n" -f $Dataname
    $Data_String = [System.Collections.ArrayList]::new()

    foreach ( $PSO in $PSObject ) {
        [void]$Data_String.add( (Convert-PSOtoString -PSObject $PSO -WriteSchema $Write_Schema) )
    }
    $Result += ($Data_String -join "`n----`n" )
    return $Result
}