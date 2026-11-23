$all = @(Get-SortedNews)
$pgs = @()
$crumbNews = @(@{ label = 'ニュース'; href = '/news/' })

$pgs += @{
  path = '/news/'
  title = 'ニュース'
  description = 'TMコーポレーション株式会社のニュース・お知らせの一覧です。カテゴリで絞り込めます。'
  crumbs = @()
  body = @"
$(Get-PageHero 'ニュース' '当社からのお知らせやプレスリリースを掲載しています。' 'News')
<section class="section"><div class="container">
  $(Get-NewsFilter '')
  $(Get-NewsList $all)
</div></section>
"@
}

foreach ($cat in Get-NewsCategories) {
  $subset = @($all | Where-Object { $_.category -eq $cat.label })
  $listHtml = Get-NewsList $subset $cat.label
  $pgs += @{
    path = "/news/category/$($cat.slug)/"
    title = "ニュース(" + $cat.label + ")"
    description = "TMコーポレーション株式会社のニュースのうち、「$($cat.label)」のカテゴリの一覧です。"
    crumbs = $crumbNews
    body = @"
$(Get-PageHero ('ニュース:' + $cat.label) '' 'News')
<section class="section"><div class="container">
  $(Get-NewsFilter $cat.slug)
  $listHtml
</div></section>
"@
  }
}

# Permalink page for date-driven articles: /news/detail/?id=YYYYMMDD-slug (rendered by dyn-render.js).
# noindex: the content depends on the viewing date. The static per-article pages below remain as the 2026 archive.
$pgs += @{
  path = '/news/detail/'
  title = 'ニュース詳細'
  description = 'TMコーポレーション株式会社のニュースの詳細です。'
  crumbs = $crumbNews
  noindex = $true
  body = @"
<article class="section"><div class="container prose" data-dyn="news-detail">
  <p>この記事を表示するには、JavaScriptを有効にしてください。</p>
  <p style="margin-top:40px"><a class="more-link" href="/news/">ニュース一覧に戻る</a></p>
</div></article>
"@
}

foreach ($item in $all) {
  $catSlug = (Get-NewsCategories | Where-Object { $_.label -eq $item.category }).slug
  $paras = ''
  foreach ($line in @($item.body)) { $paras += "<p>$(Esc $line)</p>" }
  $pgs += @{
    path = "/news/$($item.slug)/"
    title = $item.title
    description = $item.summary
    crumbs = $crumbNews
    body = @"
<article class="section"><div class="container prose">
  <p><time datetime="$($item.date)">$(Format-Date $item.date)</time> <a class="tag" href="/news/category/$catSlug/" style="text-decoration:none">$(Esc $item.category)</a></p>
  <h1 style="font-size:1.7rem">$(Esc $item.title)</h1>
  $paras
  <p style="margin-top:40px"><a class="more-link" href="/news/">ニュース一覧に戻る</a></p>
</div></article>
"@
  }
}
$pgs
