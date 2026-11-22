$pgs = @()

# ---- Privacy policy ----
$pgs += @{
  path = '/privacy/'
  title = 'プライバシーポリシー'
  description = 'TMコーポレーション株式会社のプライバシーポリシーです。個人情報の取り扱いについて定めています。'
  crumbs = @()
  body = @"
$(Get-PageHero 'プライバシーポリシー' '' 'Privacy Policy')
<section class="section"><div class="container prose">
  <h2>1. 基本方針</h2>
  <p>TMコーポレーション株式会社(以下「当社」)は、個人情報の重要性を認識し、関係法令を守り、適切に取り扱います。</p>
  <h2>2. 取得する個人情報</h2>
  <p>当社は、お問い合わせや採用のご応募などの際に、お名前、メールアドレス、電話番号、会社名、お問い合わせの内容などをご提供いただく場合があります。</p>
  <h2>3. 利用目的</h2>
  <ul>
    <li>お問い合わせへの回答および連絡のため</li>
    <li>採用選考および採用に関する連絡のため</li>
    <li>サービスの改善および新しいサービスの検討のため</li>
  </ul>
  <h2>4. 第三者への提供</h2>
  <p>法令に基づく場合を除き、ご本人の同意なく個人情報を第三者に提供しません。</p>
  <h2>5. 安全管理</h2>
  <p>個人情報の漏えい、滅失、毀損を防ぐため、必要かつ適切な安全管理措置を講じます。</p>
  <h2>6. 開示・訂正・削除のご請求</h2>
  <p>ご本人からの個人情報の開示、訂正、利用停止などのご請求には、法令に従って対応します。<a href="/contact/">お問い合わせページ</a>からご連絡ください。</p>
  <h2>7. 外部サービスの利用</h2>
  <p>本サイトは、文字の表示のために Google Fonts(Google LLC)を利用しており、ページの表示時にお客様のブラウザから同社のサーバーへ通信が発生します。アクセス解析ツールは使用していません。</p>
  <h2>8. 改定</h2>
  <p>本ポリシーの内容は、必要に応じて見直し、改定します。改定した場合は、本ページでお知らせします。</p>
  <p style="color:var(--c-text-sub)">制定日:2026年4月1日</p>
</div></section>
"@
}

# ---- Site policy ----
$pgs += @{
  path = '/site-policy/'
  title = 'サイトポリシー'
  description = 'TMコーポレーション株式会社のサイトのご利用にあたっての注意事項(著作権、リンク、免責、推奨環境)です。'
  crumbs = @()
  body = @"
$(Get-PageHero 'サイトポリシー' '' 'Site Policy')
<section class="section"><div class="container prose">
  <h2>1. 著作権</h2>
  <p>本サイトに掲載されている文章、画像、デザインなどの著作権は、当社に帰属します。無断での転載、複製、改変は禁止します。</p>
  <h2>2. リンクについて</h2>
  <p>本サイトへのリンクは、原則として自由です。ただし、本サイトの内容を誤解させる形でのリンクはお断りします。なお、本サイトから他のサイトへのリンクがある場合、リンク先の内容については、それぞれのサイトの運営者にご確認ください。</p>
  <h2>3. 免責事項</h2>
  <p>本サイトの内容は、情報提供を目的としたものであり、投資、取引、その他の判断の根拠とすることはできません。本サイトの利用により生じた損害について、当社は責任を負いません。</p>
  <h2>4. 推奨環境</h2>
  <p>主要なブラウザ(Microsoft Edge、Google Chrome、Mozilla Firefox、Safari)の最新版を推奨します。</p>
  <h2>5. アクセシビリティ</h2>
  <p>キーボード操作やスクリーンリーダーでも利用しやすいよう、配色や見出し構造に配慮しています。</p>
  <p style="color:var(--c-text-sub)">制定日:2026年4月1日</p>
</div></section>
"@
}

# ---- Sitemap (HTML) ----
$blocks = ''
foreach ($n in $Site.nav) {
  $li = ''
  if ($n.children) { foreach ($c in $n.children) { $li += "<li><a href=`"$($c.href)`">$(Esc $c.label)</a></li>" } }
  $blocks += "<div><h2 style=`"font-size:1.1rem`"><a href=`"$($n.href)`">$(Esc $n.label)</a></h2>$(if ($li) { "<ul>$li</ul>" })</div>"
}
$other = ''
foreach ($f in $Site.footerLinks) { if ($f.href -ne '/contact/') { $other += "<li><a href=`"$($f.href)`">$(Esc $f.label)</a></li>" } }
$blocks += "<div><h2 style=`"font-size:1.1rem`">その他</h2><ul>$other</ul></div>"
$pgs += @{
  path = '/sitemap/'
  title = 'サイトマップ'
  description = 'TMコーポレーション株式会社のサイト全体のページ一覧です。'
  crumbs = @()
  body = @"
$(Get-PageHero 'サイトマップ' '' 'Site Map')
<section class="section"><div class="container"><div class="grid cols-3">$blocks</div></div></section>
"@
}

# ---- 404 ----
$pgs += @{
  path = '/404.html'
  title = 'ページが見つかりません'
  description = 'お探しのページは見つかりませんでした。'
  noindex = $true
  crumbs = $null
  body = @"
$(Get-PageHero 'ページが見つかりません' 'お探しのページは、移動または削除された可能性があります。' '404 Not Found')
<section class="section"><div class="container">
  <p><a class="btn" href="/">トップページへ戻る</a> <a class="btn outline" href="/sitemap/">サイトマップを見る</a></p>
</div></section>
"@
}
$pgs
