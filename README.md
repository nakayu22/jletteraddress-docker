# jletteraddress Docker環境

Docker上でLaTeXを実行し、[jletteraddress](https://github.com/ueokande/jletteraddress)を使用してはがきの宛名面を作成する環境です。

## 必要な環境

- Docker
- Docker Compose

## プロジェクト構成

```
プロジェクトルート/
├── data/                    # データファイル（CSVとsender.txt）
│   ├── addresses.csv        # 宛名リスト
│   └── sender.txt           # 送り主情報
├── generate_tex.sh          # LaTeXファイル生成スクリプト
├── Makefile                 # ビルドコマンド
├── Dockerfile               # Dockerイメージ定義
├── docker-compose.yml       # Docker Compose設定
├── atena.tex                # 生成されるLaTeXファイル（自動生成）
├── atena.pdf                # 生成されるPDFファイル（自動生成）
└── README.md                # このファイル
```

## セットアップ

### 方法1: CSVファイルで宛名を管理（推奨）

複数の宛名を管理しやすくするため、CSVファイルを使用する方法を推奨します。

1. **差出人情報の設定**

   `data/sender.txt`ファイルを編集してください（1行目から順に）：
   ```
   あなたの名前
   住所1
   住所2
   郵便番号
   ```

2. **受取人情報の設定**

   `data/addresses.csv`ファイルを編集してください。CSV形式で以下の列を含みます：
   - `name`: 受取人の名前
   - `honorific`: 敬称（様、御中など）
   - `postcode`: 郵便番号
   - `address1`: 住所1
   - `address2`: 住所2

   例：
   ```csv
   name,honorific,postcode,address1,address2
   佐藤 花子,様,1500001,東京都渋谷区神宮前1-1-1,佐藤アパート 201
   鈴木 一郎,様,4600001,愛知県名古屋市中区錦3-1-1,鈴木ハイツ 301
   ```

3. **LaTeXファイルの自動生成**

   `make pdf`を実行すると、自動的に`atena.tex`が生成されます。

### 方法2: 直接LaTeXファイルを編集

従来通り、`atena.tex`ファイルを直接編集することも可能です。

   ```tex
   % 差出人情報
   \sendername{あなたの名前}
   \senderaddressa{住所1}
   \senderaddressb{住所2}
   \senderpostcode{郵便番号}

   % 受取人情報
   \addaddress
       {受取人名}
       {敬称（様など）}
       {郵便番号}
       {住所1}
       {住所2}
   ```

## 使用方法

### 基本的な使用方法

```bash
# CSVからLaTeXファイルを生成（手動実行する場合）
make generate

# PDFを生成（CSVから自動的にLaTeXファイルを生成してからPDFを作成）
make pdf

# 生成されたファイルをクリーンアップ
make clean

# Dockerコンテナ内でシェルを開く
make shell
```

**注意**: `make pdf`を実行すると、自動的に`data/addresses.csv`と`data/sender.txt`から`atena.tex`が生成されます（既存の`atena.tex`は上書きされます）。

### 複数のファイルセットを管理する場合

異なる送り主や宛名リストを管理する場合は、`data/`フォルダ内に追加のCSVファイルとsender.txtファイルを作成し、入力ファイルを指定できます。出力は常に`atena.tex`に上書きされます。

**例**: 複数のファイルセットを管理する場合

```
プロジェクトルート/
├── data/
│   ├── addresses.csv      # デフォルトの宛名リスト
│   ├── sender.txt          # デフォルトの送り主情報
│   ├── addresses2.csv      # 別の宛名リスト（必要に応じて追加）
│   ├── sender2.txt         # 別の送り主情報（必要に応じて追加）
│   └── ...                 # さらに追加可能
```

```bash
# デフォルトのファイルでPDF生成（atena.texに上書き）
make pdf

# 別のファイルセットでPDF生成（atena.texに上書き）
make pdf CSV_FILE=data/addresses2.csv SENDER_FILE=data/sender2.txt

# シェルスクリプトを直接実行することも可能
bash generate_tex.sh data/addresses2.csv data/sender2.txt
```

**重要**: 出力ファイル（`atena.tex`と`atena.pdf`）は常に上書きされます。複数のPDFを同時に保持したい場合は、生成後にファイル名を変更してください。

## 出力ファイル

PDFファイル（`atena.pdf`）が生成されます。このファイルには、指定したすべての受取人の宛名が含まれています。

**注意**: `atena.tex`と`atena.pdf`は常に上書きされます。複数のPDFを保持したい場合は、生成後にファイル名を変更してください。

## カスタマイズ

### 複数の宛名を追加

**CSV方式（推奨）**: `data/addresses.csv`ファイルに行を追加するだけです。ExcelやGoogleスプレッドシートで編集することもできます。

```csv
name,honorific,postcode,address1,address2
名前1,様,郵便番号1,住所1-1,住所1-2
名前2,様,郵便番号2,住所2-1,住所2-2
名前3,様,郵便番号3,住所3-1,住所3-2
```

**直接編集方式**: `atena.tex`ファイル内で、`\addaddress`コマンドを複数回使用することで、複数の宛名を追加できます。

```tex
\begin{document}
  \addaddress{名前1}{様}{郵便番号1}{住所1-1}{住所1-2}
  \addaddress{名前2}{様}{郵便番号2}{住所2-1}{住所2-2}
  \addaddress{名前3}{様}{郵便番号3}{住所3-1}{住所3-2}
\end{document}
```

### CSVファイルの利点

- **管理が簡単**: Excelやスプレッドシートで編集可能
- **データの再利用**: 他の用途（メール送信リストなど）にも活用可能
- **バージョン管理**: CSVファイルは差分が見やすく、Gitでの管理も容易
- **大量の宛名**: 数十、数百件の宛名も効率的に管理可能
- **複数セットの管理**: 異なる送り主や宛名リストを複数管理可能

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

このプロジェクトは[jletteraddress](https://github.com/ueokande/jletteraddress)（MITライセンス）を使用しています。
