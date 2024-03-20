# カスタムCSSを使う

[Stylus](https://github.com/openstyles/stylus)を使って任意のサイトに自分で定義したCSSを適用させる。

（CSSプリプロセッサに同名の[Stylus](https://stylus-lang.com)を使っているためややこしいぞ）

`pnpm add -g stylus`実行済を前提として、

1. VSCodeで.stylファイルを作成or編集
1. VSCodeファイルエクスプローラでこのreadmeを含むディレクトリを右クリックし、「Open in Integrated Terminal」
1. 開いたターミナルで`stylus -c <対象.styl>`でCSSを吐かせる
1. CSSをStylusに持って行く
