# TMコーポレーション株式会社 コーポレートサイト(架空・デモ用)

実在しない架空の上場企業「TMコーポレーション株式会社」のコーポレートサイトです。デモ・ポートフォリオ用に作成しています。
サイト内の企業名・人物・数値・文章・資料はすべて架空です。フッターに「本サイトは架空の企業を題材にしたデモサイトです」と表示しています(削除しないでください)。

## 特長

- 完全な静的サイト(サーバーサイド処理なし)。GitHub Pages のサブパス(`https://<user>.github.io/<repo>/`)でもリンク・画像・CSS・JS が壊れません。
- **Node.js などの追加ツールは不要**です。Windows 標準の PowerShell(5.1)だけでビルド・確認できます。
- ニュース・役員・社員・募集職種・IR などの内容は JSON に分離しており、文章の更新が簡単です。
- JavaScript は最小限です(メニュー開閉、トップへ戻るボタン、フェードイン、お問い合わせフォームの入力チェックのみ)。

## 1. ビルドと確認方法

**`build.bat` をダブルクリック**するだけです。サイトが `docs/` フォルダに生成され、ブラウザで開きます(PowerShell を自分で起動する必要はありません)。
`docs/index.html` をダブルクリックして開いても、すべてのリンクが動きます(リンクは相対パスで出力されるため)。

コマンドで実行する場合:

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

- 内容(`src/` 配下)を編集したら、もう一度 `build.bat` を実行すると `docs/` が更新されます。**`docs/` の中身は直接編集しないでください**(ビルドのたびに作り直されます)。
- ビルドの最後に、**内部リンクの存在チェック**が自動で走ります。リンク切れがあると一覧が表示されます(`STRICT_LINKS=1` を設定すると、リンク切れでビルドが失敗します)。
- `-SiteUrl`(例:`https://<user>.github.io/<repo>`)は、canonical・OGP・`sitemap.xml`・404ページのリンクに使います。公開前に指定してください(例:`build.bat -SiteUrl https://<user>.github.io/<repo>`)。省略時はダミーの値です。

### 上級者向け:base path 方式で確認する

`-BasePath` を指定すると、リンクが `/` 始まりの絶対パス(base path 付き)になります。公開時と同じ URL 構造をローカルで試すときに使います。

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1 -BasePath /tm-corporation -Out dist
powershell -ExecutionPolicy Bypass -File serve.ps1 -BasePath /tm-corporation -Dir dist
# → http://localhost:8080/tm-corporation/
```

## 2. フォルダ構成

```
tm-corporation/
├─ build.bat              ダブルクリックでビルド(docs/ を生成してブラウザで開く)
├─ build.ps1              サイト生成スクリプト本体
├─ serve.ps1              base path 方式の確認用の簡易サーバー(通常は不要)
├─ docs/                  ★生成されたサイト(公開用。git に含める)
├─ .github/workflows/deploy.yml   (任意)GitHub Actions で公開する場合のみ使用
├─ public/downloads/      IR資料のダミーPDF(docs/ のルートにそのままコピー)
└─ src/
   ├─ data/               サイトのデータ(JSON)  ← 内容の更新はここ
   ├─ pages/              ページの定義(*.ps1)
   ├─ components/         ヘッダー・フッター・カード等の部品(*.ps1)
   ├─ templates/layout.html   全ページ共通のHTMLひな形(meta/OGP含む)
   └─ assets/
      ├─ styles/main.css  デザイントークンと共通スタイル
      ├─ scripts/main.js  最小限のJS
      ├─ images/          ロゴ・OGP画像など
      └─ people/          ★役員・社員の写真(後日配置)
```

## 3. コンテンツの編集方法

すべて UTF-8 の JSON です。保存したら `build.ps1` を実行すると反映されます。

| 内容 | ファイル | 主な項目 |
|---|---|---|
| 会社情報・ナビゲーション | `src/data/site.json` | 社名、資本金、住所、メニュー構成 |
| ニュース | `src/data/news.json` | `slug`(URL用の半角英数)、`date`、`category`、`title`、`summary`、`body`(段落の配列) |
| 事業の詳細 | `src/data/businesses.json` | 概要、サービス、強み、実績、連携 |
| 役員 | `src/data/executives.json` | 氏名、役職、写真、略歴、担当領域 |
| 社員紹介 | `src/data/employees.json` | 氏名、写真、所属部署、入社年度、職種、メッセージ |
| 募集職種 | `src/data/jobs.json` | 事業、職種名、区分、勤務地、要件 |
| 財務ハイライト | `src/data/financials.json` | 5期分の売上高・営業利益・純利益、事業別売上 |
| 株式情報 | `src/data/stock.json` | 基本情報、配当、大株主 |
| IRカレンダー / IR資料 | `src/data/ir-calendar.json` / `ir-docs.json` | 日付・内容 / 資料名・PDFファイル名 |
| 沿革 | `src/data/history.json` | 年、内容 |

### ニュースを追加する

`src/data/news.json` に項目を1つ追加します。カテゴリは `お知らせ` / `IR` / `プレス` / `サステナビリティ` のいずれかです(追加する場合は `src/components/newscat.ps1` も編集)。

```json
{ "slug": "20261201-notice-example", "date": "2026-12-01", "category": "お知らせ",
  "title": "見出し", "summary": "一覧用の短い説明", "body": ["本文の1段落目", "2段落目"] }
```

一覧・詳細・カテゴリ別ページ・サイトマップが自動で生成されます。

### IR資料(PDF)を差し替える

実際のPDFを `public/downloads/` に同名で置くと、ダミーが置き換わります。新しい資料は `ir-docs.json` に追加します。

## 4. 人物写真の差し替え方法

役員・社員の写真は、現在シルエット(プレースホルダ)を表示しています。

1. 写真を `src/assets/people/` に置きます。
2. `src/data/executives.json` または `employees.json` の `"photo"` に**ファイル名**を書きます(現在の設定:役員 `exec-01.jpg`〜`exec-08.jpg`、社員 `emp-01.jpg`〜`emp-06.jpg`)。
3. `build.ps1` を実行します。ファイルが存在しない場合は自動でシルエットになります。

### 写真の推奨仕様

| 項目 | 推奨 |
|---|---|
| 縦横比 | **4:5(縦長)** |
| サイズ | **1200 × 1500 px 以上**(最小でも 800 × 1000 px) |
| 形式 | JPG または WebP(PNG は避ける) |
| ファイルサイズ | **1枚 500KB 以下**を目安 |
| 構図 | 顔を上部中央寄せに。頭の上と左右に余白を持たせる |

- 表示は 4:5 の枠に `object-fit: cover`、基準位置は上から20%です。多少トリミングされても顔が切れにくくなっています。
- **画像の自動最適化(リサイズ・WebP化)は行いません**。上記のサイズ・容量に収めてから配置してください。

## 5. GitHub Pages で公開する手順

### 方法A(推奨):`docs/` フォルダをそのまま公開する

1. 公開URLを指定してビルドします:`build.bat -SiteUrl https://<ユーザー名>.github.io/<リポジトリ名>`
2. GitHub で新しいリポジトリを作成し、このフォルダの内容(`docs/` を含む)を `main` ブランチに push します。
3. リポジトリの **Settings → Pages → Build and deployment** で、**Source を「Deploy from a branch」**、**Branch を `main`、フォルダを `/docs`** に設定して保存します。
4. 数分後、`https://<ユーザー名>.github.io/<リポジトリ名>/` で公開されます。

- リンクは相対パスなので、リポジトリ名を変えても、カスタムドメインを使っても、リンクは壊れません(canonical・OGP・404ページのリンクだけは `-SiteUrl` の値を使うため、変更時はビルドし直してください)。
- 内容を更新したら、`build.bat` で `docs/` を再生成し、変更を push します。**`docs/` の再生成と push を忘れると、公開サイトに反映されません。**

### 方法B(任意):GitHub Actions で公開する

`docs/` を push せずに、GitHub 側でビルドしたい場合の方法です(`.github/workflows/deploy.yml` を使用)。

1. **Settings → Pages → Source** を **「GitHub Actions」** に設定します。
2. `main` に push すると、自動でビルドと公開が行われます(**Actions** タブで確認できます。手動実行も可能です)。
3. 内部リンクが1つでも切れていると、ビルドが失敗して公開されません(Actions のログに該当リンクが出ます)。

方法AとBは同時に使えません(Pages の Source はどちらか一方です)。Bを使う場合は `.gitignore` に `docs/` を追加してもかまいません。

## 6. ページ・部品を編集する際の注意

- ページ(`src/pages/**/*.ps1`)は、`path` `title` `description` `crumbs` `body` を持つハッシュテーブル(複数ページの場合はその配列)を返します。
- リンク・画像のパスは、`/company/` のように **`/` から始めて書いてください**。ビルド時に、相対パス(`../company/index.html` など)へ自動で変換されます。
- ページ内の変数名に、ビルドスクリプトの変数名(`$Root` `$Data` `$Site` `$Content` `$Pages` `$Layout` `$Out` `$OutDir` `$BasePath` `$SiteUrl` `$Utf8` `$p` `$path` `$html` など)を使わないでください。PowerShell は大文字小文字を区別しないため、`$out` も衝突します。
- `build.ps1` / `serve.ps1` は ASCII のみで書きます(日本語は `src/` 配下のファイルに書く)。

## 7. 既知の制限

- **EN(英語版)**は未実装です。ヘッダーに「準備中」の枠のみあります。
- **OGP画像**(`src/assets/images/og-default.svg`)は SVG のため、SNS によっては表示されません。公開前に PNG(1200×630)に差し替え、`src/templates/layout.html` と `build.ps1` の参照を更新してください。
- 文字は **Google Fonts**(Noto Sans JP)を外部から読み込みます(プライバシーポリシーにも記載)。外部通信を避けたい場合は、フォントを `src/assets/` に配置して `layout.html` を修正します。
- IR資料のPDFは中身のないダミーです。
- お問い合わせフォームは入力チェックのみで、送信しません。
