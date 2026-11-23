# Project Story components (dot-sourced by build.ps1). Content lives in src/data/stories.json.
# Used by src/pages/recruit/story.ps1 and src/pages/recruit/recruit.ps1.

function Get-StoryEmp([string]$slug) {
  @($Data['employees']) | Where-Object { $_.slug -eq $slug } | Select-Object -First 1
}

function Get-StoryList { @($Data['stories']) }

function Get-StoryArt([string]$class) {
  # Decorative line art in the brand style (no external images). Colour comes from CSS (currentColor).
  if ($class -eq 'agri') {
    return @'
<svg class="ps-art" viewBox="0 0 520 380" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M0 250C120 215 260 235 520 200"/><path d="M0 285C130 245 270 270 520 232"/><path d="M0 320C140 275 280 305 520 266"/><path d="M0 355C150 305 290 340 520 300"/>
  <path d="M80 236V210M80 210c0-10 8-16 18-16 0 10-8 16-18 16zM80 222c0-8-6-12-14-12 0 8 6 12 14 12z"/>
  <path d="M170 262V236M170 236c0-10 8-16 18-16 0 10-8 16-18 16zM170 248c0-8-6-12-14-12 0 8 6 12 14 12z"/>
  <path d="M260 290V264M260 264c0-10 8-16 18-16 0 10-8 16-18 16zM260 276c0-8-6-12-14-12 0 8 6 12 14 12z"/>
  <path d="M390 214V132"/><rect x="379" y="110" width="22" height="22" rx="4"/>
  <path d="M372 98c10-10 26-10 36 0M360 86c17-16 47-16 64 0M348 74c24-22 68-22 92 0" opacity=".75"/>
  <path d="M30 100l52-32 52 20 52-44 52 30 52-26"/><circle cx="30" cy="100" r="4"/><circle cx="82" cy="68" r="4"/><circle cx="134" cy="88" r="4"/><circle cx="186" cy="44" r="4"/><circle cx="238" cy="74" r="4"/><circle cx="290" cy="48" r="4"/>
</svg>
'@
  }
  return @'
<svg class="ps-art" viewBox="0 0 520 380" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M0 120h520M0 230h520M0 330h520M110 0v380M260 0v380M410 0v380" opacity=".55"/>
  <path d="M0 300C130 250 200 330 330 240S470 170 520 190" opacity=".8"/>
  <path d="M300 214c-28-30-46-52-46-78a46 46 0 0 1 92 0c0 26-18 48-46 78z"/><circle cx="300" cy="136" r="16"/>
  <path d="M96 62h72l-14 74c-2 10-10 16-22 16s-20-6-22-16z"/><path d="M102 86h60M132 152v34M112 186h40"/>
  <rect x="352" y="262" width="130" height="62" rx="12"/><path d="M372 284h90M372 304h56"/><circle cx="332" cy="300" r="5"/>
</svg>
'@
}

# Photo set in stories.json ("thumb", file in src/assets/images/, 16:9 recommended). Used for the list card and the article hero.
function Test-StoryThumb($story) {
  return [bool]($story.thumb -and (Test-Path (Join-Path $Root ('src/assets/images/' + $story.thumb))))
}

function Get-StoryThumbImg($story, [string]$class, [bool]$eager) {
  $pos = if ($story.thumbPos) { " style=`"object-position:$(Esc $story.thumbPos)`"" } else { '' }
  $load = if ($eager) { 'fetchpriority="high"' } else { 'loading="lazy"' }
  return "<img class=`"$class`" src=`"/assets/images/$($story.thumb)`" alt=`"$(Esc $story.thumbAlt)`" width=`"1672`" height=`"941`" $load decoding=`"async`"$pos>"
}

function Get-StoryFaces($story) {
  $n = @($story.people).Count
  $h = ''
  foreach ($p in @($story.people)) {
    $e = Get-StoryEmp $p.slug
    if ($e) { $h += "<span class=`"ps-face`">$(Get-PersonPhoto $e.photo ($e.name + ' ' + $e.department))</span>" }
  }
  return "<div class=`"ps-faces n$n`">$h</div>"
}

function Get-StoryNames($story, [bool]$link = $false) {
  $names = @()
  foreach ($p in @($story.people)) {
    $e = Get-StoryEmp $p.slug
    if (-not $e) { continue }
    if ($link) { $names += "<a href=`"/recruit/people/$($e.slug)/`">$(Esc $e.name)</a>" } else { $names += (Esc $e.name) }
  }
  return ($names -join '・')
}

function Get-StoryCard($story, [int]$index) {
  $rev = if ($index % 2 -eq 1) { ' reverse' } else { '' }
  $href = "/recruit/project-story/$($story.slug)/"
  $people = ''
  foreach ($p in @($story.people)) {
    $e = Get-StoryEmp $p.slug
    if ($e) { $people += "<li><span class=`"ps-mini`">$(Get-PersonPhoto $e.photo ($e.name))</span><span><strong>$(Esc $e.name)</strong><small>$(Esc $e.department)</small></span></li>" }
  }
  $kw = ''; foreach ($k in @($story.keywords)) { $kw += "<li>$(Esc $k)</li>" }
  # Thumbnail: a photo in src/assets/images/ (16:9 recommended) when set in stories.json; otherwise SVG art + portraits.
  $hasPhoto = Test-StoryThumb $story
  if ($hasPhoto) {
    $visualCls = 'ps-card-visual has-photo'
    $visual = Get-StoryThumbImg $story 'ps-thumb' $false
    $rev += ' photo-card'
  } else {
    $visualCls = 'ps-card-visual'
    $visual = "$(Get-StoryArt $story.class)$(Get-StoryFaces $story)"
  }
  return @"
<article class="ps-card ps-$($story.class)$rev fade">
  <a class="$visualCls" href="$href" tabindex="-1" aria-hidden="true">
    $visual
    <span class="ps-num">STORY <b>$(Esc $story.number)</b></span>
  </a>
  <div class="ps-card-body">
    <p class="eyebrow">STORY $(Esc $story.number) / $(Esc $story.business)</p>
    <h2><a href="$href">$(Esc $story.catch)</a></h2>
    <p class="ps-project">$(Esc $story.project)</p>
    <p>$(Esc $story.summary)</p>
    <ul class="ps-keywords">$kw</ul>
    <ul class="ps-people">$people</ul>
    <p><a class="btn" href="$href">記事を読む<span class="sr-only">(STORY $(Esc $story.number))</span></a></p>
  </div>
</article>
"@
}

function Get-StoryQuote($q) {
  $e = Get-StoryEmp $q.person
  if (-not $e) { return '' }
  return @"
<figure class="ps-quote">
  <div class="ps-quote-photo">$(Get-PersonPhoto $e.photo ($e.name + ' ' + $e.department))</div>
  <div class="ps-quote-body">
    <blockquote><p>$(Esc $q.text)</p></blockquote>
    <figcaption><strong>$(Esc $e.name)</strong><span>$(Esc $e.department)・$(Esc $e.joinYear)</span></figcaption>
  </div>
</figure>
"@
}

function Get-StoryCast($sec, $story) {
  $cards = ''
  foreach ($p in @($story.people)) {
    $e = Get-StoryEmp $p.slug
    if (-not $e) { continue }
    $cards += @"
<div class="ps-cast-card">
  <div class="ps-cast-photo">$(Get-PersonPhoto $e.photo ($e.name + ' ' + $e.department))</div>
  <div>
    <p class="ps-cast-dept">$(Esc $e.department)<br>$(Esc $e.joinYear)・$(Esc $e.job)</p>
    <h3>$(Esc $e.name)</h3>
    <p class="ps-cast-role"><span>役割</span>$(Esc $p.role)</p>
    <a class="more-link" href="/recruit/people/$($e.slug)/">社員紹介を見る<span class="sr-only">($(Esc $e.name))</span></a>
  </div>
</div>
"@
  }
  return @"
<section class="ps-sec soft"><div class="container ps-wide">
  <p class="ps-label">$(Esc $sec.label)</p>
  <h2>$(Esc $sec.heading)</h2>
  <div class="ps-cast n$(@($story.people).Count)">$cards</div>
</div></section>
"@
}

function Get-StoryFlow($sec) {
  $li = ''; $i = 0
  foreach ($s in @($sec.steps)) {
    $i++
    $li += "<li><span class=`"ps-step`">$i</span><h3>$(Esc $s.title)</h3><p>$(Esc $s.text)</p></li>"
  }
  return @"
<section class="ps-sec soft"><div class="container ps-wide">
  <p class="ps-label">$(Esc $sec.label)</p>
  <h2>$(Esc $sec.heading)</h2>
  <ol class="ps-flow">$li</ol>
</div></section>
"@
}

function Get-StorySection($sec, $story, [int]$no) {
  switch ($sec.type) {
    'cast' { return Get-StoryCast $sec $story }
    'flow' { return Get-StoryFlow $sec }
    'message' {
      $paras = ''; foreach ($b in @($sec.body)) { $paras += "<p>$(Esc $b)</p>" }
      $sig = ''
      foreach ($q in @($sec.signature)) {
        $e = Get-StoryEmp $q.person
        if ($e) { $sig += "<li><span class=`"ps-mini`">$(Get-PersonPhoto $e.photo ($e.name))</span><span><strong>$(Esc $e.name)</strong><em>$(Esc $q.text)</em></span></li>" }
      }
      return @"
<section class="ps-sec"><div class="container ps-narrow">
  <div class="ps-message ps-$($story.class)">
    <p class="ps-label">$(Esc $sec.label)</p>
    <h2>$(Esc $sec.heading)</h2>
    $paras
    <ul class="ps-sign">$sig</ul>
    <p class="ps-cta"><a class="btn" href="/recruit/jobs/">募集職種を見る</a> <a class="btn outline" href="/recruit/people/">社員紹介を見る</a></p>
  </div>
</div></section>
"@
    }
    default {
      $paras = ''; foreach ($b in @($sec.body)) { $paras += "<p>$(Esc $b)</p>" }
      $quotes = ''; foreach ($q in @($sec.quotes)) { $quotes += Get-StoryQuote $q }
      $num = '{0:00}' -f $no
      return @"
<section class="ps-sec"><div class="container ps-narrow">
  <p class="ps-label"><span class="ps-secno">$num</span>$(Esc $sec.label)</p>
  <h2>$(Esc $sec.heading)</h2>
  $paras
  $quotes
</div></section>
"@
    }
  }
}

# Links on an employee page to the stories that feature that employee.
function Get-PersonStories([string]$slug) {
  $li = ''
  foreach ($s in Get-StoryList) {
    foreach ($p in @($s.people)) {
      if ($p.slug -eq $slug) { $li += "<li><a href=`"/recruit/project-story/$($s.slug)/`"><span class=`"tag`">STORY $(Esc $s.number)</span>$(Esc $s.catch)</a></li>" }
    }
  }
  if (-not $li) { return '' }
  return "<h2 style=`"margin-top:36px`">登場するプロジェクトストーリー</h2><ul class=`"ps-related`">$li</ul>"
}
