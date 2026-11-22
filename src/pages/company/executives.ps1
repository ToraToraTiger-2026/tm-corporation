$execs = @($Data['executives'])
$pgs = @()

$cards = ''
foreach ($e in $execs) {
  $cards += "<a class=`"person-card fade`" href=`"/company/executives/$($e.slug)/`"><div class=`"photo-frame`">$(Get-PersonPhoto $e.photo ($e.name + ' ' + $e.role))</div><h3>$(Esc $e.name)</h3><p>$(Esc $e.role)</p></a>"
}
$pgs += @{
  path = '/company/executives/'
  title = '役員紹介'
  description = 'TMコーポレーション株式会社の取締役の氏名・役職・経歴・担当領域をご紹介します。'
  crumbs = @(@{ label = '企業情報'; href = '/company/' })
  body = @"
$(Get-PageHero '役員紹介' '取締役の経歴と担当領域をご紹介します。(氏名・経歴はすべて架空です)' 'Executives')
<section class="section"><div class="container"><div class="grid cols-4">$cards</div></div></section>
"@
}

foreach ($e in $execs) {
  $bio = ''
  foreach ($line in @($e.bio)) { $bio += "<li>$(Esc $line)</li>" }
  $pgs += @{
    path = "/company/executives/$($e.slug)/"
    title = $e.name + '(' + $e.role + ')'
    description = "TMコーポレーション株式会社 $($e.role) $($e.name)の経歴と担当領域です。"
    crumbs = @(@{ label = '企業情報'; href = '/company/' }, @{ label = '役員紹介'; href = '/company/executives/' })
    body = @"
<section class="section"><div class="container">
  <div class="person-detail">
    <div class="photo-frame">$(Get-PersonPhoto $e.photo ($e.name + ' ' + $e.role))</div>
    <div>
      <p class="eyebrow">$(Esc $e.role)</p>
      <h1>$(Esc $e.name)</h1>
      <p style="color:var(--c-text-sub)">$(Esc $e.kana)</p>
      <h2 style="margin-top:32px">担当領域</h2>
      <p>$(Esc $e.area)</p>
      <h2>略歴</h2>
      <ul>$bio</ul>
      <p style="margin-top:32px"><a class="more-link" href="/company/executives/">役員一覧に戻る</a></p>
    </div>
  </div>
</div></section>
"@
  }
}
$pgs
