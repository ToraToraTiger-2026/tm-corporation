$biz = @($Data['businesses'])
$fin = $Data['financials']
$cur = @($fin.years)[-1]
$pgs = @()

# segment share (same order as businesses.json)
$segItems = @()
for ($k = 0; $k -lt $biz.Count; $k++) {
  $segItems += [pscustomobject]@{ name = $biz[$k].name; sales = @($fin.segments)[$k].sales; class = $biz[$k].class }
}

$cards = ''
foreach ($b in $biz) {
  $cards += "<div class=`"card $($b.class) fade`">$(Get-SvgIcon $b.icon)<p class=`"eyebrow`">$(Esc $b.en)</p><h3>$(Esc $b.name)</h3><p>$(Esc $b.summary)</p><a class=`"more-link`" href=`"/business/$($b.slug)/`">詳しく見る<span class=`"sr-only`">($(Esc $b.name))</span></a></div>"
}

$pgs += @{
  path = '/business/'
  title = '事業紹介'
  description = 'TMコーポレーション株式会社の4つの事業(金融サービス、アグリビジネス、ウェブサービス運営、ITコンサルティング)と、事業間の連携による強みをご紹介します。'
  crumbs = @()
  body = @"
$(Get-PageHero '事業紹介' '金融・農業・ウェブ・ITの4事業を展開しています。それぞれの専門性に加え、事業間の連携が私たちの強みです。' 'Business')
<section class="section"><div class="container"><div class="grid cols-2">$cards</div></div></section>
<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">Group Strength</p><h2>4事業の連携による強み</h2></div>
  <div class="grid cols-3">
    <div><h3>農業 × IT</h3><p>にんにくやおかわかめの圃場のセンサーデータと、ITコンサルティングの分析手法を組み合わせ、収穫量や出荷時期の予測に活用しています。</p></div>
    <div><h3>金融 × ウェブ</h3><p>「下戸マップ」に掲載されている飲食店へ、キャッシュレス決済の導入や設備資金のご案内を行っています。</p></div>
    <div><h3>農業 × 金融</h3><p>契約農家の設備投資や運転資金を金融サービスで支え、安定した生産と販路づくりにつなげています。</p></div>
  </div>
</div></section>
<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Sales by Segment</p><h2>事業別の売上高</h2><p class="lead">$(Esc $cur.fy)の連結売上高 $(Format-Num $cur.sales)億円の内訳です(ダミーデータ)。</p></div>
  $(Get-ShareBars $segItems)
</div></section>
"@
}

for ($k = 0; $k -lt $biz.Count; $k++) {
  $b = $biz[$k]
  $svc = ''; foreach ($s in @($b.services)) { $svc += "<div class=`"card $($b.class)`"><h3>$(Esc $s.title)</h3><p>$(Esc $s.text)</p></div>" }
  $str = ''; foreach ($s in @($b.strengths)) { $str += "<div><h3>$(Esc $s.title)</h3><p>$(Esc $s.text)</p></div>" }
  $res = ''; foreach ($r in @($b.results)) { $res += "<div class=`"kpi`"><p class=`"kpi-label`">$(Esc $r.label)</p><p class=`"kpi-value`">$(Esc $r.value)<span>$(Esc $r.unit)</span></p></div>" }
  $extLink = ''
  if ($b.link) { $extLink = "<p style=`"margin-top:32px`"><a class=`"btn outline`" href=`"$(Esc $b.link.url)`" target=`"_blank`" rel=`"noopener noreferrer`">$(Esc $b.link.label)<span class=`"sr-only`">(外部サイト・新しいタブで開きます)</span><svg width=`"14`" height=`"14`" viewBox=`"0 0 14 14`" aria-hidden=`"true`"><path d=`"M5 2H2v10h10V9M8 2h4v4M12 2L6 8`" fill=`"none`" stroke=`"currentColor`" stroke-width=`"1.6`"/></svg></a></p>" }
  $others = ''; foreach ($o in $biz) { if ($o.slug -ne $b.slug) { $others += "<li><a href=`"/business/$($o.slug)/`">$(Esc $o.name)</a></li>" } }
  $sales = @($fin.segments)[$k].sales
  $pgs += @{
    path = "/business/$($b.slug)/"
    title = $b.name
    description = $b.summary
    crumbs = @(@{ label = '事業紹介'; href = '/business/' })
    body = @"
<section class="page-hero biz-hero $($b.class)"><div class="container">
  <p class="eyebrow">$(Esc $b.en)</p>
  <h1>$(Esc $b.name)</h1>
  <p class="lead">$(Esc $b.lead)</p>
  <p style="margin:16px 0 0;color:var(--c-text-sub);font-size:.9rem">$(Esc $cur.fy)の売上高:$(Format-Num $sales)億円(ダミーデータ)</p>
</div></section>
<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Services</p><h2>サービス内容</h2></div>
  <div class="grid cols-3">$svc</div>
  $extLink
</div></section>
<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">Strengths</p><h2>強み</h2></div>
  <div class="grid cols-3">$str</div>
</div></section>
<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Results</p><h2>実績</h2><p class="lead">数値はデモ用のダミーです。</p></div>
  <div class="grid cols-3">$res</div>
</div></section>
<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">Synergy</p><h2>グループ内での連携</h2></div>
  <p class="prose">$(Esc $b.synergy)</p>
</div></section>
<section class="section"><div class="container">
  <h2 style="font-size:1.1rem">ほかの事業</h2>
  <ul class="biz-nav">$others<li><a href="/business/">事業紹介トップ</a></li></ul>
  <p style="margin-top:32px"><a class="btn" href="/contact/">お問い合わせ</a></p>
</div></section>
"@
  }
}
$pgs
