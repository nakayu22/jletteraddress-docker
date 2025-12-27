# jletteraddress Docker環境

Docker上でLaTeXを実行し、[jletteraddress](https://github.com/ueokande/jletteraddress)を使用してはがきの宛名面を作成する環境です。

## 必要な環境

- Docker
- Docker Compose

## セットアップ

1. はがきの宛名情報を編集します。

   `atena.tex`ファイルを開き、差出人情報と受取人情報を編集してください。

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

```bash
# PDFを生成
make pdf

# 生成されたファイルをクリーンアップ
make clean

# Dockerコンテナ内でシェルを開く
make shell
```

## 出力ファイル

PDFファイル（`atena.pdf`）が生成されます。このファイルには、指定したすべての受取人の宛名が含まれています。

## カスタマイズ

### 複数の宛名を追加

`atena.tex`ファイル内で、`\addaddress`コマンドを複数回使用することで、複数の宛名を追加できます。

```tex
\begin{document}
  \addaddress{名前1}{様}{郵便番号1}{住所1-1}{住所1-2}
  \addaddress{名前2}{様}{郵便番号2}{住所2-1}{住所2-2}
  \addaddress{名前3}{様}{郵便番号3}{住所3-1}{住所3-2}
\end{document}
```

## トラブルシューティング

### 日本語が正しく表示されない場合

Dockerfileに日本語フォント（Noto CJK）が含まれていますが、問題が発生する場合は、Dockerイメージを再ビルドしてください。

```bash
docker-compose build --no-cache
```

### PDFが生成されない場合

エラーログを確認してください：

```bash
docker-compose run --rm latex bash -c "cp /opt/jletteraddress/jletteraddress.cls . && rm -f atena.aux atena.dvi atena.log atena.out atena.pdf atena.xdv && latexmk -latex=platex -pdfdvi -interaction=nonstopmode atena.tex"
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

このプロジェクトは[jletteraddress](https://github.com/ueokande/jletteraddress)（MITライセンス）を使用しています。
