# Project Story pages: list + one page per story (content: src/data/stories.json, parts: src/components/story.ps1).
# NOTE: Get-RecruitNav is defined in recruit.ps1, which build.ps1 runs first (pages are processed in file-name order).
$stories = @(Get-StoryList)
$pgs = @()
$crumbR = @(@{ label = '採用情報'; href = '/recruit/' })
$crumbS = @(@{ label = '採用情報'; href = '/recruit/' }, @{ label = 'プロジェクトストーリー'; href = '/recruit/project-story/' })

# ---- List ----
$cards = ''; $i = 0
foreach ($s in $stories) { $cards += Get-StoryCard $s $i; $i++ }
$pgs += @{
  path = '/recruit/project-story/'
  title = 'プロジェクトストーリー'
  description = 'TMコーポレーション株式会社の社員が取り組んだプロジェクトの物語です。農業×データ、「下戸マップ」の立ち上げ。直面した困難と、乗り越えた過程を紹介します。'
  crumbs = $crumbR
  body = @"
<section class="ps-top"><div class="container">
  <p class="ps-en">PROJECT STORY</p>
  <h1>プロジェクトストーリー</h1>
  <p class="ps-top-lead">うまくいったことも、うまくいかなかったことも。<br>TMコーポレーションの社員が、仕事の現場で何を考え、誰と議論し、どう乗り越えてきたのかを、取材をもとに物語としてお届けします。</p>
</div></section>
<section class="section ps-list"><div class="container">
  $(Get-RecruitNav '/recruit/project-story/')
  $cards
</div></section>
<section class="section soft"><div class="container ps-end">
  <h2>あなたの挑戦も、ここから。</h2>
  <p>募集職種や、一緒に働く社員の声もご覧ください。</p>
  <p><a class="btn" href="/recruit/jobs/">募集職種を見る</a> <a class="btn outline" href="/recruit/people/">社員紹介を見る</a></p>
</div></section>
"@
}

# ---- Detail ----
$count = $stories.Count
for ($idx = 0; $idx -lt $count; $idx++) {
  $s = $stories[$idx]
  $o = $stories[($idx + 1) % $count]
  $secs = ''; $no = 0
  foreach ($sec in @($s.sections)) {
    if ($sec.type -eq 'text') { $no++ }
    $secs += Get-StorySection $sec $s $no
  }
  $kw = ''; foreach ($k in @($s.keywords)) { $kw += "<li>$(Esc $k)</li>" }
  $next = ''
  if ($count -gt 1) {
    $next = @"
<section class="section"><div class="container ps-narrow">
  <a class="ps-next ps-$($o.class)" href="/recruit/project-story/$($o.slug)/">
    <span class="ps-next-label">NEXT STORY $(Esc $o.number)</span>
    <strong>$(Esc $o.catch)</strong>
    <span class="ps-next-meta">$(Esc $o.business)／$(Get-StoryNames $o)</span>
  </a>
</div></section>
"@
  }
  $pgs += @{
    path = "/recruit/project-story/$($s.slug)/"
    title = "PROJECT STORY $($s.number) " + $s.catch
    description = $s.summary
    crumbs = $crumbS
    body = @"
<div class="ps-page ps-$($s.class)">
<section class="ps-hero ps-$($s.class)"><div class="container ps-hero-inner">
  <div class="ps-hero-text">
    <p class="ps-hero-eyebrow">PROJECT STORY <b>$(Esc $s.number)</b></p>
    <p class="ps-biz">$(Esc $s.business)</p>
    <h1>$(Esc $s.catch)</h1>
    <p class="ps-hero-lead">$(Esc $s.lead)</p>
    <ul class="ps-keywords on-dark">$kw</ul>
  </div>
  <div class="ps-hero-visual">
    $(Get-StoryArt $s.class)
    $(Get-StoryFaces $s)
  </div>
</div></section>
<section class="ps-meta"><div class="container"><dl>
  <div><dt>事業</dt><dd><a href="$($s.businessHref)">$(Esc $s.business)</a></dd></div>
  <div><dt>プロジェクト</dt><dd>$(Esc $s.project)</dd></div>
  <div><dt>登場社員</dt><dd>$(Get-StoryNames $s $true)</dd></div>
</dl></div></section>
$secs
$next
<section class="section"><div class="container ps-narrow"><p style="text-align:center"><a class="more-link" href="/recruit/project-story/">プロジェクトストーリー一覧に戻る</a></p></div></section>
</div>
"@
  }
}
$pgs
