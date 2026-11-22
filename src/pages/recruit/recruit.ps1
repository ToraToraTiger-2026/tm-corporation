$jobs = @($Data['jobs'])
$emps = @($Data['employees'])
$pgs = @()
$crumbR = @(@{ label = '採用情報'; href = '/recruit/' })

function Get-RecruitNav([string]$active) {
  $items = @(@('メッセージ', '/recruit/'), @('募集職種', '/recruit/jobs/'), @('社員紹介', '/recruit/people/'))
  $li = ''
  foreach ($i in $items) { $cur = if ($i[1] -eq $active) { ' aria-current="page"' } else { '' }; $li += "<li><a href=`"$($i[1])`"$cur>$(Esc $i[0])</a></li>" }
  return "<nav aria-label=`"採用情報内のページ`"><ul class=`"filter`">$li</ul></nav>"
}

# ---- Top: message ----
$pgs += @{
  path = '/recruit/'
  title = '採用情報'
  description = 'TMコーポレーション株式会社の採用情報です。代表メッセージ、求める人物像、働く環境をご紹介します。'
  crumbs = @()
  body = @"
$(Get-PageHero '採用情報' '社会の基盤を支える仕事に、私たちと一緒に挑戦しませんか。' 'Recruit')
<section class="section"><div class="container">
  $(Get-RecruitNav '/recruit/')
  <div class="section-head"><p class="eyebrow">Message</p><h2>代表メッセージ</h2></div>
  <div class="prose">
    <p>私たちは、金融・農業・ウェブ・ITという異なる分野の事業を通じて、社会の基盤を支えています。分野は違っても、共通しているのは、お客様と誠実に向き合い、信頼を積み重ねるという姿勢です。</p>
    <p>4つの事業の連携から、新しい価値が生まれています。皆さんの経験や視点を、ぜひ私たちの事業に活かしてください。一人ひとりの成長が、会社の成長につながると考えています。</p>
    <p><strong>代表取締役社長 兼 CEO 森下 達彦</strong>(架空)</p>
  </div>
</div></section>
<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">People We Seek</p><h2>求める人物像</h2></div>
  <div class="grid cols-3">
    <div class="card"><h3>誠実な人</h3><p>相手の立場に立ち、約束を守って行動できる方。</p></div>
    <div class="card"><h3>学び続ける人</h3><p>未知の分野にも関心をもち、自ら学ぶ姿勢のある方。</p></div>
    <div class="card"><h3>周囲と協力できる人</h3><p>立場や事業の違いを超えて、チームで成果を出せる方。</p></div>
  </div>
</div></section>
<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Environment</p><h2>働く環境</h2></div>
  <div class="grid cols-3">
    <div><h3>事業をまたぐ成長機会</h3><p>4つの事業をまたぐ異動や研修の機会があります。</p></div>
    <div><h3>柔軟な働き方</h3><p>職種に応じて、在宅勤務やフレックスタイム制度を利用できます。</p></div>
    <div><h3>育児・介護との両立</h3><p>男性の育児休業取得率は62%です。短時間勤務などの制度も整えています。</p></div>
  </div>
  <p style="margin-top:32px"><a class="btn" href="/recruit/jobs/">募集職種を見る</a> <a class="btn outline" href="/recruit/people/">社員紹介を見る</a></p>
</div></section>
"@
}

# ---- Jobs ----
$cards = ''
foreach ($j in $jobs) {
  $reqs = ''; foreach ($r in @($j.requirements)) { $reqs += "<li>$(Esc $r)</li>" }
  $cards += "<div class=`"card $($j.class)`"><p class=`"eyebrow`">$(Esc $j.business)</p><h3>$(Esc $j.title)</h3><p>$(Esc $j.summary)</p><ul class=`"checklist`">$reqs</ul><p style=`"font-size:.85rem;margin:0 0 16px`">区分:$(Esc $j.type)/勤務地:$(Esc $j.place)</p><a class=`"more-link`" href=`"/contact/`">お問い合わせ・エントリー<span class=`"sr-only`">($(Esc $j.title))</span></a></div>"
}
$pgs += @{
  path = '/recruit/jobs/'
  title = '募集職種'
  description = 'TMコーポレーション株式会社の募集職種(金融サービス、アグリビジネス、ウェブサービス運営、ITコンサルティング、コーポレート)の一覧です。'
  crumbs = $crumbR
  body = @"
$(Get-PageHero '募集職種' '事業ごとの募集職種です。(本サイトは架空のため、実際の募集はありません)' 'Jobs')
<section class="section"><div class="container">
  $(Get-RecruitNav '/recruit/jobs/')
  <div class="grid cols-2">$cards</div>
</div></section>
"@
}

# ---- People list + detail ----
$pcards = ''
foreach ($e in $emps) {
  $pcards += "<a class=`"person-card fade`" href=`"/recruit/people/$($e.slug)/`"><div class=`"photo-frame`">$(Get-PersonPhoto $e.photo ($e.name + ' ' + $e.department))</div><h3>$(Esc $e.name)</h3><p>$(Esc $e.department)<br>$(Esc $e.joinYear)</p></a>"
}
$pgs += @{
  path = '/recruit/people/'
  title = '社員紹介'
  description = 'TMコーポレーション株式会社の社員紹介です。所属部署、入社年度、仕事への思いをご紹介します。'
  crumbs = $crumbR
  body = @"
$(Get-PageHero '社員紹介' '一緒に働く仲間をご紹介します。(氏名・内容はすべて架空です)' 'People')
<section class="section"><div class="container">
  $(Get-RecruitNav '/recruit/people/')
  <div class="grid cols-3">$pcards</div>
</div></section>
"@
}
foreach ($e in $emps) {
  $pgs += @{
    path = "/recruit/people/$($e.slug)/"
    title = $e.name + '(' + $e.department + ')'
    description = "TMコーポレーション株式会社 $($e.department) $($e.name)(" + $e.joinYear + ")のメッセージです。"
    crumbs = @(@{ label = '採用情報'; href = '/recruit/' }, @{ label = '社員紹介'; href = '/recruit/people/' })
    body = @"
<section class="section"><div class="container">
  <div class="person-detail">
    <div class="photo-frame">$(Get-PersonPhoto $e.photo ($e.name + ' ' + $e.department))</div>
    <div>
      <p class="eyebrow">$(Esc $e.job)</p>
      <h1>$(Esc $e.name)</h1>
      <table class="data" style="margin-bottom:28px"><caption class="sr-only">プロフィール</caption><tbody>
        <tr><th scope="row">所属部署</th><td>$(Esc $e.department)</td></tr>
        <tr><th scope="row">入社年度</th><td>$(Esc $e.joinYear)</td></tr>
        <tr><th scope="row">職種</th><td>$(Esc $e.job)</td></tr>
      </tbody></table>
      <h2>メッセージ</h2>
      <p>$(Esc $e.message)</p>
      <p style="margin-top:32px"><a class="more-link" href="/recruit/people/">社員紹介一覧に戻る</a></p>
    </div>
  </div>
</div></section>
"@
  }
}
$pgs
