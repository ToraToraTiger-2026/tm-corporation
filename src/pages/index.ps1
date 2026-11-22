$news = Get-SortedNews | Select-Object -First 5
$fy = @($Data['financials'].years)
$cur = $fy[-1]; $prev = $fy[-2]

$bizCards = ''
foreach ($b in @($Data['businesses'])) {
  $bizCards += "<div class=`"card $($b.class) fade`">$(Get-SvgIcon $b.icon)<h3>$(Esc $b.name)</h3><p>$(Esc $b.summary)</p><a class=`"more-link`" href=`"/business/$($b.slug)/`">詳しく見る<span class=`"sr-only`">($(Esc $b.name))</span></a></div>"
}

@{
  path = '/'
  title = 'TMコーポレーション株式会社'
  description = 'TMコーポレーション株式会社の公式サイトです。金融サービス、アグリビジネス、ウェブサービス運営、ITコンサルティングの4事業を展開しています。'
  crumbs = $null
  body = @"
<section class="hero"><div class="container hero-inner">
  <div>
    <p class="eyebrow" style="color:#BBD3F6">TM Corporation</p>
    <h1>信頼を礎に、<br>暮らしと産業の未来を育てる。</h1>
    <p>金融、農業、ウェブ、IT。4つの事業を通じて、社会の基盤を支え、持続的な成長に貢献します。</p>
    <p style="margin-top:32px"><a class="btn on-dark" href="/business/">事業紹介を見る</a> <a class="btn outline" style="background:transparent;color:#fff;border-color:#fff" href="/ir/">IR情報</a></p>
  </div>
  <svg class="hero-visual" viewBox="0 0 360 300" role="img" aria-label="4つの事業を表すイメージ図">
    <rect x="20" y="20" width="150" height="120" rx="10" fill="#fff" fill-opacity=".92"/>
    <rect x="190" y="20" width="150" height="120" rx="10" fill="#9CC2F5" fill-opacity=".9"/>
    <rect x="20" y="160" width="150" height="120" rx="10" fill="#6FA3E8" fill-opacity=".85"/>
    <rect x="190" y="160" width="150" height="120" rx="10" fill="#fff" fill-opacity=".35"/>
    <path d="M45 105h20V80h20v25h20V55h20" stroke="#0B3D91" stroke-width="4" fill="none"/>
    <circle cx="265" cy="80" r="30" stroke="#0B3D91" stroke-width="4" fill="none"/><path d="M235 80h60M265 50c14 14 14 46 0 60" stroke="#0B3D91" stroke-width="3" fill="none"/>
    <path d="M95 250V205M95 205c0-18 14-28 32-28 0 18-14 28-32 28zM95 225c0-14-10-22-28-22 0 14 10 22 28 22z" stroke="#fff" stroke-width="4" fill="none"/>
    <rect x="225" y="190" width="80" height="55" rx="4" stroke="#fff" stroke-width="4" fill="none"/><path d="M245 262h40" stroke="#fff" stroke-width="4"/>
  </svg>
</div></section>

<section class="section"><div class="container">
  <div class="section-head" style="display:flex;justify-content:space-between;align-items:end;flex-wrap:wrap;gap:12px">
    <div><p class="eyebrow">News</p><h2 style="margin:0">お知らせ</h2></div>
    <a class="more-link" href="/news/">一覧を見る</a>
  </div>
  $(Get-NewsList $news)
</div></section>

<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">Business</p><h2>事業紹介</h2><p class="lead">金融・農業・ウェブ・ITの4事業が連携し、グループ全体で価値を生み出します。</p></div>
  <div class="grid cols-4">$bizCards</div>
</div></section>

<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Group Strength</p><h2>4事業の連携による強み</h2></div>
  <div class="grid cols-3">
    <div class="fade"><h3>農業 × IT</h3><p>にんにくやおかわかめの圃場のセンサーデータと、ITコンサルティングの分析手法を組み合わせ、収穫量や出荷時期の予測に活用しています。</p></div>
    <div class="fade"><h3>金融 × ウェブ</h3><p>「下戸マップ」に掲載されている飲食店へ、キャッシュレス決済の導入や設備資金のご案内を行い、事業者を支援します。</p></div>
    <div class="fade"><h3>農業 × 金融</h3><p>契約農家の設備投資や運転資金を金融サービスで支え、安定した生産と販路づくりにつなげます。</p></div>
  </div>
</div></section>

<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">IR Highlights</p><h2>IRハイライト</h2><p class="lead">$(Esc $cur.fy)の連結業績です。</p></div>
  <div class="grid cols-3">
    <div class="kpi fade"><p class="kpi-label">売上高</p><p class="kpi-value">$(Format-Num $cur.sales)<span>億円</span></p><p class="kpi-diff">前期比 $(Format-Pct $cur.sales $prev.sales)</p></div>
    <div class="kpi fade"><p class="kpi-label">営業利益</p><p class="kpi-value">$(Format-Num $cur.op)<span>億円</span></p><p class="kpi-diff">前期比 $(Format-Pct $cur.op $prev.op)</p></div>
    <div class="kpi fade"><p class="kpi-label">親会社株主に帰属する当期純利益</p><p class="kpi-value">$(Format-Num $cur.net)<span>億円</span></p><p class="kpi-diff">前期比 $(Format-Pct $cur.net $prev.net)</p></div>
  </div>
  <p style="margin-top:28px"><a class="btn outline" href="/ir/">IR情報トップへ</a></p>
</div></section>

<section class="section"><div class="container">
  <div class="grid cols-2">
    <a class="banner agri fade" href="/sustainability/"><p class="eyebrow" style="color:#BBD3F6">Sustainability</p><h3>サステナビリティ</h3><p>農業とともに、環境と地域の持続可能性に取り組みます。</p></a>
    <a class="banner fade" href="/recruit/"><p class="eyebrow" style="color:#BBD3F6">Recruit</p><h3>採用情報</h3><p>私たちと一緒に、社会の基盤を支える仕事に挑戦しませんか。</p></a>
  </div>
</div></section>
"@
}
