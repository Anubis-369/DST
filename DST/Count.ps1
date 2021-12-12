<#-------------------------------------------------
フォーマットを整えるための文字数計算処理

---------------------------------------------------#>

Function Get-StringLength {
    param(
        [string]$String
    )
    $Hankk_Count = ([regex]"[\uFF61-\uFF9F]").Matches($String).Count
    $int_byte_num = [System.Text.Encoding]::GetEncoding("utf-8").GetByteCount($String)
    $B2_Length = ($int_byte_num - $String.Length) / 2 - $Hankk_Count
    $All_Length = $String.Length + $B2_Length

    Return $All_Length
}

Function Get-StringLengthDef {
    pram(
        [strings]$String
    )
    $Hankk_Count = ([regex]"[\uFF61-\uFF9F]").Matches($String).Count
    $int_byte_num = [System.Text.Encoding]::GetEncoding("utf-8").GetByteCount($String)
    $B2_Length = ($int_byte_num - $String.Length) / 2 - $Hankk_Count
    $Def_Length = $B2_Length - $String.Length

    Return $Def_Length
}

Function Get-Maxlength {
    pram(
        [string[]]$Strings
    )
    $Max_Length = 0
    foreach ( $String in $Strings ) {
        $Length = Get-StringLength $String
        if ( $Length -gt $Max_Length) { $Max_Length = $Length }
    }
    Return $Max_Length
}