# Layout components: header / footer / breadcrumb (dot-sourced by build.ps1)

function Get-HeaderNav([string]$current) {
  $items = ''
  $i = 0
  foreach ($n in $Site.nav) {
    $i++
    $active = ''
    if ($current -eq $n.href -or ($n.href -ne '/' -and $current.StartsWith($n.href))) { $active = ' aria-current="true"' }
    if ($n.children) {
      $sub = ''
      foreach ($c in $n.children) { $sub += "<li><a href=`"$($c.href)`">$(Esc $c.label)</a></li>" }
      $items += "<li class=`"has-sub`"><div class=`"nav-row`"><a class=`"nav-link`" href=`"$($n.href)`"$active>$(Esc $n.label)</a><button type=`"button`" class=`"sub-toggle`" aria-expanded=`"false`" aria-controls=`"sub-$i`" aria-label=`"$(Esc $n.label)のメニューを開閉`"><svg width=`"12`" height=`"12`" viewBox=`"0 0 12 12`" aria-hidden=`"true`"><path d=`"M2 4l4 4 4-4`" fill=`"none`" stroke=`"currentColor`" stroke-width=`"1.6`"/></svg></button></div><ul class=`"sub`" id=`"sub-$i`">$sub</ul></li>"
    } else {
      $items += "<li><div class=`"nav-row`"><a class=`"nav-link`" href=`"$($n.href)`"$active>$(Esc $n.label)</a></div></li>"
    }
  }
  return @"
<header class="site-header" id="top">
  <div class="container header-inner">
    <a class="logo" href="/" aria-label="TMコーポレーション株式会社 トップページ">
      <svg class="logo-mark" width="36" height="36" viewBox="0 0 36 36" aria-hidden="true"><rect width="36" height="36" rx="6" fill="#0B3D91"/><path d="M8 11h20M18 11v16M10 27h5M21 27h5" stroke="#fff" stroke-width="2.6" fill="none"/></svg>
      <span class="logo-text"><strong>TMコーポレーション</strong><small>TM Corporation</small></span>
    </a>
    <button type="button" class="menu-toggle" aria-expanded="false" aria-controls="global-nav"><span class="bars" aria-hidden="true"></span><span class="sr-only">メニュー</span></button>
    <nav class="global-nav" id="global-nav" aria-label="グローバルナビゲーション">
      <ul class="nav-list">$items</ul>
    </nav>
  </div>
</header>
"@
}

function Get-Breadcrumb($crumbs, [string]$title) {
  $li = '<li><a href="/">ホーム</a></li>'
  foreach ($c in $crumbs) { $li += "<li><a href=`"$($c.href)`">$(Esc $c.label)</a></li>" }
  $li += "<li aria-current=`"page`">$(Esc $title)</li>"
  return "<nav class=`"breadcrumb`" aria-label=`"パンくずリスト`"><div class=`"container`"><ol>$li</ol></div></nav>"
}

function Get-Footer {
  $cols = ''
  foreach ($n in $Site.nav) {
    $l = ''
    if ($n.children) { foreach ($c in $n.children) { $l += "<li><a href=`"$($c.href)`">$(Esc $c.label)</a></li>" } }
    $cols += "<div class=`"fcol`"><h2 class=`"fh`"><a href=`"$($n.href)`">$(Esc $n.label)</a></h2>$(if ($l) { "<ul>$l</ul>" })</div>"
  }
  $pol = ''
  foreach ($f in $Site.footerLinks) { $pol += "<li><a href=`"$($f.href)`">$(Esc $f.label)</a></li>" }
  $year = (Get-Date).Year
  return @"
<footer class="site-footer">
  <div class="container">
    <div class="footer-grid">$cols</div>
    <div class="footer-bottom">
      <ul class="policy">$pol</ul>
      <p class="demo-note">本サイトは架空の企業を題材にしたデモサイトです。</p>
      <p class="copy"><small>&copy; $year TM Corporation (fictional). All rights reserved.</small></p>
    </div>
  </div>
</footer>
"@
}
