# DSTモジュールの使い方 
## DSTとは
DST (Data Structure Text) は、データをメンバー名と値をコロン(:)で区切って構造的に記述したテキストです。DSTモジュールは、DSTで記述したテキストからPSObjectを生成するモジュールです。以下のように入力したテキストファイルを、PSObjectにコンバートします。

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
上記のようにまとめたテキストを、Import-DSTdatafile に渡すと、以下のようにPSObjectに変換される。

````Powershell
> Import-DSTdatafile Data_Text.txt | Format-Table

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
## 使い方
DSTのフォルダを任意の場所にコピーして、Import-Module を実行します。
````
Import-Module -Name <DSTモジュールのパス>
````
モジュールをインポートすると、以下のコマンドレットが使用できるようになります。

|名前    | 内容 |
|--------|--------------------|
| Import-DSTdatafile | DSTのデータファイルからPSObjectを生成します。|
| Convert-DSTString | PSObjectからDSTの文字列を生成します。 
| Convert-DSTSchema | DSTで使用するスキーマファイルをPSObjectに変換します。 |

Convert-DSTSchema は、スキーマファイルをデータとして使用するときに使用するコマンドレットです。DSTの他のコマンドと連係して使用することはありません。


# DSTの書き方
## データの記述のしかた
以下のように、メンバー名 と 値をコロンで区切って記述していきます。メンバー名と値がセットになります。

````
<Member1> : <Value>
````
複数のメンバー名と値のセットを組み合わせて、一つのPSObjectのデータが生成されます。
````
<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
<Member4> : <Value>

# 複数のメンバーを持つ一つのPSObjedtに変換される。
````

## データの区切り
以下のように、列挙したメンバー名と値をデータのグループを "----" でレコード単位に区切っていきます。

````
<Member1> : <Value>
<Member2> : <Value>
<Member3> : <Value>
<Member4> : <Value>
----
````

以下のように、同じメンバー名を記載して2件目以降のデータを記述していすると、

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

# これを変換すると、Member1～4を持つPSObjectが二つに変換される。
````

## メンバ名の書き方について
メンバー名はそのまま PSObject のメンバー名として使用されるので、メンバー名として使用できない文字列を指定することはできません。テキストで入力するときの項目名と、PSObjectのメンバーに変換したときと違う名前を使用したいときは、後述するスキーマを使用することで実現できます。

複数のデータを記述する場合、メンバ名はできるだけ揃えておく。データによってメンバーの構成が違っていると、変換したときに記載したはずのメンバーが表示されないことがあるので注意しましょう。

## データ名
データのテキストにデータ名を 「--」(ハイホン2つ) で囲っておくと、一つのファイルからデータ名を指定してデータを出力することができます。

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

データで区切ったファイルは、 -Data オプションをつけることで出力するデータを選択できます。 -Data オプションを省いた場合、データ名が指定されていないデータが変換されます。

````
> Import-DSTdatafiLE <DSTファイル> -Data <データ名>
# -> <データ名> に指定したデータが変換されて出力される。

> Import-DSTdatafiLE <DSTファイル>
# -> データ名が指定されていないデータが変換されて出力される。
````

# データの書き方
## 基本
データの書き方は三通りあります。まず、メンバ名とコロンを区切る方式です。
メンバ名の後に一つ以上の半角スペースを入れて、コロンを入力する。その後に、半角スペースを一つ入れて値を入力します。

メンバー名の長さに合わせてスペースを挿入して、コロンの位置をそろえて読みやすくすることができます。改行がデータの区切りになります。改行のあとに入力した文字列列は、データとして認識されません。

````
<Member_Name> : <Value>
<Member>      : <Value>
改行の後に入力したこの部分の文字列は、データとして認識されない。
````

## 1行に複数個を記入
メンバーと値をコロンで区切ったものを、カンマで区切って複数個並べることができます。数字や短い文字列のようなデータを、一行に複数個記載することができる。この書き方でも同様に、改行がデータの区切りになります。改行のあとに入力した文字列は、データとして認識されません。

カンマの前と後には、スペースを一つずつ入力します。スペースに挟まれたカンマの後に、スペースに挟まれたコロンがあると、複数個のデータと認識されてしまうので注意しましょう。エスケープシーケンスはありません。もし、このようなデータを記載する場合は、複数行のデータを入力する書式で記載します。


````
<Member2> : <Value> , <Member1> : <Value>
改行の後に入力したこの部分の文字列は、データとして認識されない。
````

## 複数行のデータを入力する
文字数の多いデータや改行を含むデータは、以下のように、メンバー名の後にスペースを要れずにコロンを付けて改行します。そのあとに、スペースを複数個入れて、インデントを入れてデータを入力していきます。改行の際もインデントを入れておきます。

他のメンバーを記入するときは、スペースでインデントを入れずに空白行を入れます。この書式では、スペースでインデントを入れている部分をデータとして認識されます。インデントの入っていない空行が値の区切れになる。空行のに入れた文字列はデータとして認識されません。

````
<Member1>:
  文字数の多いデータはこのように入力していきます。

<Member2>:
  複数行のデータを記載します。このように、長文を入力して
  改行を含むテキストをデータとして取り込む事もできます。

空行の後に入れた、この部分の内容はデータとして認識されません。
````

# スキーマの使用方法
## スキーマとは
スキーマとは、DSTをPSObjectに変換するときのルールを記載するテキストファイルです。DSTを拡張した書式で記載します。

````
-- Data1 --
タイトル   [Member=Title]     : <ここから備考になる>
ホスト名   [Member=Hostname]  : <ここから備考になる>
IPアドレス [Member=IPAddress] : <ここから備考になる>
````

DSTのメンバのデータにオプションを [] (カッコ)で囲んで記載すると、PSObjectへの変更時の処理を設定することができます。オプションには以下のようなものがあります。

|名前    | 内容 |
|--------|--------------------|
| Member | メンバが設定した名前でPSObjectが生成される。|
| Type   | メンバが設定したデータ型でPSObjectが生成される。|
| Format | PSObjectをDSTに変換する際に使用する。(後述) |
| Split  | データを分割する際に使用する。 (後述) |

オプションはの後に記述した文字列は、備考として扱われ、PSObjectへの変換処理に影響はしません。スキーマは Convert-DSTSchema のコマンドでスキーマのデータに変換することができます。

## スキーマを使用したPSObjecctへの変換
以下のように、スキーマファイルを指定してImport-DSTdatafileを実行すると、DSTをPObjectに変換する際に、メンバ名や形式をSchemaで設定することができます。

````
> Import-DSTdatafile <DSTファイル> -Schema <スキーマファイル>
````

変換時にスキーマを指定すると、変換時にスキーマに記載したメンバと同じメンバがPSObjectに変換されます。

# 分割変換書式について
## 分割変換書式とは
分割書式を使うと、一つのデータを二つに分割することができます。共通項目を持つデータを生成するときに使用します。スキーマで方式を指定して、方式に則って記載するとデータが分割されます。

## 配列型の記載方法
データを ,(カンマ) で区切ることで、データを分割する記載方法です。文字列が短いデータで使用する。スキーマのSplitに「Array」を指定します。

````
-- Data1 --
タイトル   [Member=Title]:
ホスト名   [Member=Hostname]:
IPアドレス [Member=IPAddress,Split=Array]:
````
Split に Array が指定してあるメンバーのデータを以下のように、複数のデータをカンマで区切って記載します。

````
-- Data1 --
タイトル   : Title
ホスト名   : Hostname
IPアドレス:
    192.168.1.1 , 192.168.1.2 , 192.168.1.3
````
IPアドレスに入れた値が三つに分割され、IPアドレス以外データが同じPSObjectが三つ生成されます。

````
Title Hostname IPAddress
----- -------- ---------
Title Hostname 192.168.1.1
Title Hostname 192.168.1.2
Title Hostname 192.168.1.3
````
一つだけ値の違うデータを複数生成したいときに利用します。

## リスト型の記載方法
データを -(ハイホン) で区切ってリスト形式にして記載する方法です。文字列が長いデータで使用する。スキーマのSplitで「list」を指定します。
````
-- Data1 --
タイトル   [Member=Title]:
ホスト名   [Member=Hostname]:
IPアドレス [Member=IPAddress,Split=List]:
````
Split に List が指定してあるメンバーのデータを以下のように、複数のデータを改行とハイホンを入れて記載します。List形式の分割変更書式は改行を含むので、複数行を含むデータの記述方式でしか使用できません。

````
-- Data1 --
タイトル   : Title
ホスト名   : Hostname
IPアドレス:
    - 192.168.1.1
    - 192.168.1.2
    - 192.168.1.3
````
Arrayを指定した時と同様に、IPアドレスに入れた値が三つに分割され、IPアドレス以外データが同じPSObjectが三つ生成されます。
````
Title Hostname IPAddress
----- -------- ---------
Title Hostname 192.168.1.1
Title Hostname 192.168.1.2
Title Hostname 192.168.1.3
````
Arrayを指定した時との違いは、書式のみです。一つだけ値の違うデータを複数生成したいときに利用します。


# PSObjectからのDSTの生成
## 生成方法

````
Convert-DSTString -PSObject <変換するPSObject> -Dataname <データ名>
````
コマンドを実行すると、DSTの内容がテキスト形式で出力されます。ファイルへの保存が必要な場合は、ファイルへリダイレクトして内容をファイルに書き込んでください。

## スキーマを使用した生成方法
DSTを生成する際に、データ名とスキーマを指定することができます。
````
Convert-DSTString -PSObject <変換するPSObject> -Dataname <データ名> -Schema <スキーマファイル>
````
データ名を指定することで、データ名がDSTに出力されます。スキーマを指定することで、スキーマのメンバ名がPSOのメンバ名と紐づけられてDSTが出力されます。Formatのオプションを使用して、複数行のデータや一行に複数のデータを記述する方式で出力することがでいます。

|Format         | 出力 |
|---------------|--------------------|
| Text          | 複数行のデータ入力形式で出力される。 |
| Join          | 次に出力されるデータが、一行で複数個のデータを記述する方式で、同じ行に出力される。|

# その他
## ファイル情報の追加
変換するときのオプションに -fileinfo のスイッチを付けると、出力されるPSObjectにファイル情報が付加される。
````
> Import-DSTdatafile <DSTファイル> -fileinfo
````
このオプションを使用すると、出力される PSObject に __Fileinfo というメンバーが追加されて、Get-ChildrenItem で取得したファイルの情報のPSOが入ります。


## エスケープシーケンスについて
一行に一つのデータを記入する際に、「 , ](スペースで挟んだカンマ)と「 : 」(スペースで挟んだコロン)を組み合わせた値を入れると、複数の値を入れるときの書式に該当して、複数の値として認識され処理されます。

もともと、DSTは手入力で効率よく入力することをコンセプトにしたデータの記述方式です。また、エスケープシーケンスの処理を入れたとしても、使用頻度は高くならないので、実装していません。

## トリムについて
DSTで入力した値は、データの先頭と最後に付いた複数のスペースを削除します。データの先頭と最後にスペースが入らないようにトリムを行います。

分割変換書式で分割されたデータも、同様にトリムが行われて、前後のスペースは削除されます。