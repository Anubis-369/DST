# DTSモジュールの使い方
# DTSとは
DST (Data Structure Text) は、データをメンバー名と値をコロン(:)で区切って構造的に記述したテキストです。DTSモジュールは、DTSで記述したテキストからPSObjectを生成するモジュールです。

# 使い方
以下のように入力したテキストファイルを、PSObjectにコンバートします。

```` TestFile Data_Text.txt

<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
----

<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
----

<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>

````
上記のようにまとめたテキストを、Import-DSTdatafiLE に渡すと、以下のようにPSObjectに変換される。

````Powershell
> Import-DSTdatafiLE Data_Text.txt | Format-Table

<Member1> <Member2> <Member3> >
--------- --------- --------- 
<Value>   <Value>   <Value>   
<Value>   <Value>   <Value>   
<Value>   <Value>   <Value>   

> Import-DSTdatafile ..\Data_Text.txt | Format-List          

<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>

<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>

<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
````

以下のように、複数のファイルをパイプで通せば、まとめて結果を出力することができる。

````Powershell
> get-CheildrenItem | %{ Import-DSTdatafile }

````
# DTSの書き方
## データの記述のしかた
以下のように、メンバー名 と 値をコロンで区切って記述していきます。メンバー名と値がセットになります。

````
<Member1> : <Value>
````
複数のメンバー名と値のセットで、一つのPSObjectのデータが生成されます。


## データの区切り
以下のように、列挙したメンバー名と値をデータを "----" でレコード単位に区切っていきます。

````
<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
<Member4> : <Value>
----
````

以下のように、同じメンバー名を記載して2件目以降のデータを記述していきます。

````
<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
<Member4> : <Value>
----

<Member1> : <Value2>
<Member2> : <Value2>
<Member3> : <Value2>
<Member4> : <Value2>
````

## メンバ名の書き方について
メンバー名はそのまま PSObject のメンバー名として使用されるので、メンバー名として使用できない文字列を指定することはできません。

テキストで入力するときの項目名と、PSObjectのメンバーに変換したときと違う名前を使用したいときは、後述するスキーマを使用することで実現できます。

## データ名
データのテキストにデータ名を 「--」(ハイホン2つ) で囲っておくと、一つのファイルからデータ名を指定してデータを出力することができる。
```` TestFile Data_Text.txt
-- Main --
<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
<Member4> : <Value>
----

<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
<Member4> : <Value>

-- Sub --
<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
<Member4> : <Value>

````

データで区切ったファイルは、 -Data オプションをつけることで出力するデータを選択できる。 -Data オプションを省いた場合、データ名が指定されていないデータが変換される。

````
> Import-DSTdatafiLE <DSTファイル> -Data <データ名>
````

# データの書き方
## 基本
データの書き方は三通りある。まず、メンバ名とコロンを区切る方式。
メンバ名の後に一つ以上の半角スペースを入れて、コロンを入力する。その後に、半角スペースを一つ入れて値を入力する。

メンバー名の長さに合わせてスペースを挿入して、コロンの位置をそろえて読みやすくすることができる。

````
<Member_Name> : <Value>
<Member>      : <Value>
````

## 1行に複数個を記入
メンバーと値をコロンで区切ったものを、カンマで区切って複数個並べることができる。数字や短い文字列のようなデータを、一行に複数個記載することができる。

カンマの前と後には、スペースを一つずつ入力する。スペースに挟まれたカンマの後に、スペースに挟まれたコロンがあると、複数個のデータと認識されてしまうので注意する。

````
<Member2> : <Value> , <Member1> : <Value>
````

## 複数行のデータを入力する
文字数の多いデータや改行を含むデータは、以下のように、メンバー名の後にスペースを要れずにコロンを付けて改行します。そのあとに、スペースを複数個入れて、インデントを入れてデータを入力していきます。改行の際もインデントを入れておく。

他のメンバーを記入するときは、スペースでインデントを要れずに、改行を二つ以上入れて行間を開けておく。

````
<Member1>:
  文字数の多いデータはこのように入力していきます。

<Member2>:
  複数行のデータを記載します。このように、長文を入力して
  改行を含むテキストをデータとして取り込む事もできます。
````

# スキーマの使用方法
## スキーマとは
DSTをPSObjectに変換するときのルールを記載するテキストファイル。DSTの形式で記述する。

````
-- Data2 --
タイトル   : [Header=Title] <ここから備考になる>
ホスト名   : [Header=Hostname] <ここから備考になる>
IPアドレス : [Header=IPAddress] <ここから備考になる>
````

DTSのメンバのデータにオプションを [] (カッコ)で囲んで記載すると、PSObjectへの変更時の処理を設定することができる。オプションには以下のようなものがある。

|名前    | 内容 |
|--------|--------------------|
| Header | メンバが設定した名前でPSObjectが生成される。|
| Type   | メンバが設定したデータ型でPSObjectが生成される。|
| Array  | ※ 後述 |

オプションはの後に記述した文字列は、備考として扱われ、PSObjectへの変換処理に影響はしない。スキーマは　のコマンドでスキーマのデータに変換することができる。

## スキーマを使用したPSObjecctへの変換
PSます。Objectに変換する際に、メンバ名や形式をSchemaで設定することができる。

````
> Import-DSTdatafiLE <DSTファイル> -Schema <スキーマファイル>
````

変換時にスキーマを指定すると、変換時にスキーマに記載したメンバと同じメンバがPSObjectに変換される。

## スキーマを使用したPSObjectからDSTへの変換
逆にPSObject
文字列として出力されれます。

# 分割変換書式について
## ぽう

# その他
## エスケープシーケンス
一行に一つのデータを記入する際に、「 , ](スペースで挟んだカンマ)と「 : 」(スペースで挟んだコロン)を組み合わせた値を入れると、複数の値を入れるときの書式に該当して、複数の値として認識され処理されます。

もともと、DSTは手入力で効率よく入力することをコンセプトにしたデータの記述方式です。また、エスケープシーケンスの処理を入れたとしても、使用頻度は高くならないので、実装していません。

## トリムについて
DTSで入力した値は、データの先頭と最後に付いた複数のスペースを削除します。データの先頭と最後にスペースが入らないようにトリムを行います。
