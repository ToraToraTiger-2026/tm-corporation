$rows = ''
foreach ($h in @($Data['history'])) {
  $rows += "<li><span class=`"tl-year`">$(Esc $h.year)</span><span class=`"tl-text`">$(Esc $h.text)</span></li>"
}
@{
  path = '/company/history/'
  title = '沿革'
  description = 'TMコーポレーション株式会社の沿革です。1968年の設立から現在までの歩みをご紹介します。'
  crumbs = @(@{ label = '企業情報'; href = '/company/' })
  body = @"
$(Get-PageHero '沿革' '' 'History')
<section class="section"><div class="container"><ol class="timeline">$rows</ol></div></section>
"@
}
