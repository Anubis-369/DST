<#-------------------------------------------------
文字列をPSオブジェクトに変換する

---------------------------------------------------#>

Function Split-BySchema {
    <#
        .SYNOPSIS
        スキーマの Split の処理を行う。Splitの内容によって、PSOを分割して出力する。
    #>

    param(
        [psobject[]]$Schema,
        [psobject]$InputObject
    )
    $Splitters = $Schema | ? {$_.Split -ne ""}
    $Result   = [System.Collections.ArrayList]::new()
    [void]$Result.add($InputObject)

    if ( $splitters.count -eq 0 ) { return $Result }
    foreach ($element in $Splitters) {
        if ( $element.Type -eq "" ) { $Type = "string"} `
        else { $Type = $element.Type}

        if ( $element.Header -eq "" ) { $Name = $element.Name} `
        else {$Name = $element.Header}

        $Value  = $InputObject | % $Name
        $Values = [System.Collections.ArrayList]::new()

        switch ($element.Split) {
            array  { $Values = $Value -split ","}
            list   { $Values = $Value -split "`n`s*- "}
            PSO    { $Values = $Value }
            default{ [void]$Values.add($Value) }
        } 
        $Result = $Values | %{
            if ($element.Split -ne "PSO") {
                $Result_Value = $_.Trim() -as $Type
            } else {
                $Result_Value = $_
            }
            $Result | % { $_.$Name = $Result_Value ; $_ | Select-Object * }
        }
    }
    Return $Result
}


Function Get-OnSchema {
    <#
        .SYNOPSIS
        スキーマとデータお併せて結果を出力する。
    #>
    param (
        [psobject[]]$Schema,
        [psobject[]]$Member
    )

    $Title = [System.Collections.ArrayList]::new()
    $Result = New-Object -TypeName psobject -Property @{}

    foreach ($element in $Schema) {
        if ( $element.Type -eq "" -or $element.split -ne "" ) { $Type = "string"} `
        else { $Type = $element.Type}

        if ( $element.Member -eq "" ) { $Name = $element.Name} `
        else {$Name = $element.Member}

        $Org_Value = $Member | ? { $_.Index -eq $element.Name } | % value

        if ($Type -eq "Nest") {
            $Value = ConvertTo-DSTPSobject -Contents $Org_Value -Schema $element.Nest
        } else {
            $Value = $Org_Value -as $Type
        }

        $Result | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        [void]$Title.Add($Name)
    }

    $Result | Select-Object $Title
}

Function Get-NoSchema {
    param (
        [psobject[]]$Member
    )
    $Titles  = [System.Collections.ArrayList]::new()
    $Result =  New-Object PSObject -Property $Property @{}

    foreach ($element in $Member ) {
        $Name = $element.Index
        [void]$Titles.Add($Name)
        $Result | Add-Member -MemberType NoteProperty -Name $Name -Value $element.Value
    }
    $Result | Select-Object $Titles
}
<#
・ $Contents には Get-Content -Raw で読み込んだ文字列を入れる。 
・ $Schema には Read-DySchema で読み込んだスキーマを入れる。

Schenaが存在しない場合、変換したHashをそのままPSObjectに変換。存在する場合は、Schemaに基づいて変換する関数に処理を渡す。
#>
Function ConvertTo-DSTPSobject {
    param(
        [string]$Contents="",
        [psobject[]]$Schema=@(),
        [string]$Dataname=""
    )

    $Data_List = Split-Data -Contents $contents
    $Result = [System.Collections.ArrayList]::new()

    if ($Schema.count -eq 0) {
        $Data_List = $Data_List | ? { $_.Name -eq $Dataname }

        foreach ($Data in $Data_List) {
            $Member = Split-BasicPSO $Data.Contents
            $NoSchema_Member = Get-NoSchema -Member $Member
            [void]$Result.add($NoSchema_Member)
        }
        return $Result
    } 

    $Schema  = $Schema | ? { $_.Data -eq $Dataname }
    $Data_List = $Data_List | ? { $_.Name -eq $Dataname }

    foreach ($Data in $Data_List) {
        $Member = Split-BasicPSO $Data.Contents
        $OnSchema_Member = Get-OnSchema -Schema $Schema -Member $Member
        Split-BySchema -InputObject $OnSchema_Member -Schema $Schema | % { [void]$Result.add($_)}
        #[void]$Result.add($OnSchema_Member)
    }
    
    return $Result
}