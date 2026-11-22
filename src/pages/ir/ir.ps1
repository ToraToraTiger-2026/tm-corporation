$fin = $Data['financials']
$yrs = @($fin.years)
$cur = $yrs[-1]; $prev = $yrs[-2]
$stock = $Data['stock']
$biz = @($Data['businesses'])
$irNews = @(Get-SortedNews | Where-Object { $_.category -eq 'IR' })
$crumbIr = @(@{ label = 'IR情報'; href = '/ir/' })
$pgs = @()

# ---- IR top ----
$pgs += @{
  path = '/ir/'
  title = 'IR情報'
  description = 'TMコーポレーション株式会社のIR情報(財務ハイライト、株式情報、IRカレンダー、IR資料室)をご案内します。'
  crumbs = @()
  body = @"
$(Get-PageHero 'IR情報' '株主・投資家の皆様へ、経営成績や財務状況などの情報をお届けします。' 'Investor Relations')
<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Highlights</p><h2>$(Esc $cur.fy) 連結業績</h2></div>
  <div class="grid cols-3">
    <div class="kpi"><p class="kpi-label">売上高</p><p class="kpi-value">$(Format-Num $cur.sales)<span>億円</span></p><p class="kpi-diff">前期比 $(Format-Pct $cur.sales $prev.sales)</p></div>
    <div class="kpi"><p class="kpi-label">営業利益</p><p class="kpi-value">$(Format-Num $cur.op)<span>億円</span></p><p class="kpi-diff">前期比 $(Format-Pct $cur.op $prev.op)</p></div>
    <div class="kpi"><p class="kpi-label">親会社株主に帰属する当期純利益</p><p class="kpi-value">$(Format-Num $cur.net)<span>億円</span></p><p class="kpi-diff">前期比 $(Format-Pct $cur.net $prev.net)</p></div>
  </div>
</div></section>
<section class="section soft"><div class="container">
  <div class="grid cols-2">
    <div class="card"><h3>IRニュース</h3><p>決算や株主総会などの最新のお知らせです。</p><a class="more-link" href="/ir/news/">詳しく見る</a></div>
    <div class="card"><h3>財務ハイライト</h3><p>5期分の業績の推移と、事業別の売上高です。</p><a class="more-link" href="/ir/financials/">詳しく見る</a></div>
    <div class="card"><h3>株式情報</h3><p>株式の基本情報、配当、大株主の状況です。</p><a class="more-link" href="/ir/stock/">詳しく見る</a></div>
    <div class="card"><h3>IRカレンダー</h3><p>決算発表や株主総会の予定です。</p><a class="more-link" href="/ir/calendar/">詳しく見る</a></div>
    <div class="card"><h3>IR資料室</h3><p>決算短信、有価証券報告書などの資料を掲載しています。</p><a class="more-link" href="/ir/library/">詳しく見る</a></div>
  </div>
</div></section>
<section class="section"><div class="container">
  <div class="section-head" style="display:flex;justify-content:space-between;align-items:end;flex-wrap:wrap;gap:12px"><div><p class="eyebrow">IR News</p><h2 style="margin:0">最新のIRニュース</h2></div><a class="more-link" href="/ir/news/">一覧を見る</a></div>
  $(Get-NewsList ($irNews | Select-Object -First 3))
</div></section>
"@
}

# ---- IR news ----
$pgs += @{
  path = '/ir/news/'
  title = 'IRニュース'
  description = 'TMコーポレーション株式会社のIRニュース一覧です。決算発表、株主総会などをお知らせします。'
  crumbs = $crumbIr
  body = @"
$(Get-PageHero 'IRニュース' '' 'IR News')
<section class="section"><div class="container">$(Get-NewsList $irNews)</div></section>
"@
}

# ---- Financials ----
$labels = @($yrs | ForEach-Object { $_.fy -replace '^20(\d\d)年3月期$', '$1/3' })
$descSales = '売上高の推移(億円)。' + ((@($yrs | ForEach-Object { $_.fy + (Format-Num $_.sales) })) -join '、') + '。'
$descOp = '営業利益の推移(億円)。' + ((@($yrs | ForEach-Object { $_.fy + (Format-Num $_.op) })) -join '、') + '。'
$tbody = ''
foreach ($y in $yrs) { $tbody += "<tr><th scope=`"row`">$(Esc $y.fy)</th><td class=`"num`">$(Format-Num $y.sales)</td><td class=`"num`">$(Format-Num $y.op)</td><td class=`"num`">$(Format-Num $y.net)</td></tr>" }
$segItems = @()
for ($k = 0; $k -lt $biz.Count; $k++) { $segItems += [pscustomobject]@{ name = $biz[$k].name; sales = @($fin.segments)[$k].sales; class = $biz[$k].class } }
$pgs += @{
  path = '/ir/financials/'
  title = '財務ハイライト'
  description = 'TMコーポレーション株式会社の連結業績の推移(売上高、営業利益、当期純利益)と事業別の売上高です。'
  crumbs = $crumbIr
  body = @"
$(Get-PageHero '財務ハイライト' '連結業績の推移です。' 'Financial Highlights')
<section class="section"><div class="container">
  <div class="grid cols-2">
    <div class="chart-box"><h3>売上高</h3><p class="unit">単位:億円</p>$(Get-BarChart $labels @($yrs | ForEach-Object { $_.sales }) '億円' $descSales)</div>
    <div class="chart-box"><h3>営業利益</h3><p class="unit">単位:億円</p>$(Get-BarChart $labels @($yrs | ForEach-Object { $_.op }) '億円' $descOp)</div>
  </div>
  <div class="table-wrap" style="margin-top:40px"><table class="data">
    <caption>連結業績の推移(単位:億円)</caption>
    <thead><tr><th scope="col">決算期</th><th scope="col" class="num">売上高</th><th scope="col" class="num">営業利益</th><th scope="col" class="num">親会社株主に帰属する当期純利益</th></tr></thead>
    <tbody>$tbody</tbody>
  </table></div>
</div></section>
<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">Sales by Segment</p><h2>事業別の売上高($(Esc $cur.fy))</h2></div>
  $(Get-ShareBars $segItems)
</div></section>
"@
}

# ---- Stock ----
$basic = ''; foreach ($r in @($stock.basic)) { $basic += "<tr><th scope=`"row`">$(Esc $r.k)</th><td>$(Esc $r.v)</td></tr>" }
$div = ''; foreach ($r in @($stock.dividends)) { $div += "<tr><th scope=`"row`">$(Esc $r.fy)</th><td class=`"num`">$($r.eps)</td><td class=`"num`">$($r.dps)</td><td class=`"num`">$(Esc $r.payout)</td></tr>" }
$holders = ''; foreach ($r in @($stock.holders)) { $holders += "<tr><td>$(Esc $r.name)</td><td class=`"num`">$(Esc $r.ratio)</td></tr>" }
$pgs += @{
  path = '/ir/stock/'
  title = '株式情報'
  description = 'TMコーポレーション株式会社の株式情報(基本情報、配当の推移、大株主の状況)です。'
  crumbs = $crumbIr
  body = @"
$(Get-PageHero '株式情報' '株式の基本情報、配当、大株主の状況です。' 'Stock Information')
<section class="section"><div class="container">
  <h2>株式の基本情報</h2>
  <div class="table-wrap"><table class="data"><caption class="sr-only">株式の基本情報</caption><tbody>$basic</tbody></table></div>
</div></section>
<section class="section soft"><div class="container">
  <h2>配当の推移</h2>
  <div class="table-wrap"><table class="data">
    <caption class="sr-only">配当の推移</caption>
    <thead><tr><th scope="col">決算期</th><th scope="col" class="num">1株当たり当期純利益(円)</th><th scope="col" class="num">1株当たり配当金(円)</th><th scope="col" class="num">配当性向</th></tr></thead>
    <tbody>$div</tbody>
  </table></div>
</div></section>
<section class="section"><div class="container">
  <h2>大株主の状況(上位6名)</h2>
  <div class="table-wrap"><table class="data">
    <caption class="sr-only">大株主の状況</caption>
    <thead><tr><th scope="col">株主名</th><th scope="col" class="num">持株比率</th></tr></thead>
    <tbody>$holders</tbody>
  </table></div>
</div></section>
"@
}

# ---- Calendar ----
$cal = ''
foreach ($r in @($Data['ir-calendar'])) {
  $cls = if ($r.status -eq '済') { 'done' } else { 'plan' }
  $cal += "<tr><th scope=`"row`"><time datetime=`"$($r.date)`">$(Format-Date $r.date)</time></th><td>$(Esc $r.event)</td><td><span class=`"status $cls`">$(Esc $r.status)</span></td></tr>"
}
$pgs += @{
  path = '/ir/calendar/'
  title = 'IRカレンダー'
  description = 'TMコーポレーション株式会社の決算発表や株主総会などのIRスケジュールです。'
  crumbs = $crumbIr
  body = @"
$(Get-PageHero 'IRカレンダー' '決算発表や株主総会の予定です。予定は変更になる場合があります。' 'IR Calendar')
<section class="section"><div class="container">
  <div class="table-wrap"><table class="data">
    <caption class="sr-only">IRカレンダー</caption>
    <thead><tr><th scope="col">日付</th><th scope="col">内容</th><th scope="col">状況</th></tr></thead>
    <tbody>$cal</tbody>
  </table></div>
</div></section>
"@
}

# ---- Library ----
$lib = ''
foreach ($r in @($Data['ir-docs'])) {
  $lib += "<tr><td><time datetime=`"$($r.date)`">$(Format-Date $r.date)</time></td><td><span class=`"tag`">$(Esc $r.category)</span></td><td>$(Esc $r.title)</td><td><a href=`"/downloads/$($r.file)`">PDF<span class=`"sr-only`">:$(Esc $r.title)</span></a></td></tr>"
}
$pgs += @{
  path = '/ir/library/'
  title = 'IR資料室'
  description = 'TMコーポレーション株式会社の決算短信、決算説明資料、有価証券報告書などのIR資料を掲載しています。'
  crumbs = $crumbIr
  body = @"
$(Get-PageHero 'IR資料室' '決算短信、有価証券報告書などの資料です。' 'IR Library')
<section class="section"><div class="container">
  <div class="table-wrap"><table class="data">
    <caption class="sr-only">IR資料一覧</caption>
    <thead><tr><th scope="col">公表日</th><th scope="col">区分</th><th scope="col">資料名</th><th scope="col">ダウンロード</th></tr></thead>
    <tbody>$lib</tbody>
  </table></div>
</div></section>
"@
}
$pgs
