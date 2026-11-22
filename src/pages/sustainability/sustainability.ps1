$pgs = @()
$crumbS = @(@{ label = 'サステナビリティ'; href = '/sustainability/' })

function Get-Kpis($rows) {
  $h = ''
  foreach ($r in $rows) { $h += "<div class=`"kpi`"><p class=`"kpi-label`">$(Esc $r[0])</p><p class=`"kpi-value`">$(Esc $r[1])<span>$(Esc $r[2])</span></p></div>" }
  return "<div class=`"grid cols-3`">$h</div>"
}
function Get-GoalTable($rows) {
  $h = ''
  foreach ($r in $rows) { $h += "<tr><th scope=`"row`">$(Esc $r[0])</th><td>$(Esc $r[1])</td><td>$(Esc $r[2])</td></tr>" }
  return "<div class=`"table-wrap`"><table class=`"data`"><caption class=`"sr-only`">目標と実績</caption><thead><tr><th scope=`"col`">項目</th><th scope=`"col`">目標</th><th scope=`"col`">2025年度の実績</th></tr></thead><tbody>$h</tbody></table></div>"
}
function Get-SubNav([string]$active) {
  $items = @(@('基本方針', '/sustainability/'), @('環境(E)', '/sustainability/environment/'), @('社会(S)', '/sustainability/social/'), @('ガバナンス(G)', '/sustainability/governance/'))
  $li = ''
  foreach ($i in $items) { $cur = if ($i[1] -eq $active) { ' aria-current="page"' } else { '' }; $li += "<li><a href=`"$($i[1])`"$cur>$(Esc $i[0])</a></li>" }
  return "<nav aria-label=`"サステナビリティ内のページ`"><ul class=`"filter`">$li</ul></nav>"
}

# ---- Top: policy ----
$pgs += @{
  path = '/sustainability/'
  title = 'サステナビリティ'
  description = 'TMコーポレーション株式会社のサステナビリティの基本方針と、重要課題(マテリアリティ)をご紹介します。'
  crumbs = @()
  body = @"
$(Get-PageHero 'サステナビリティ' '事業を通じて、社会と環境の持続可能性に貢献します。' 'Sustainability')
<section class="section"><div class="container">
  $(Get-SubNav '/sustainability/')
  <div class="section-head"><p class="eyebrow">Policy</p><h2>基本方針</h2></div>
  <p class="prose">私たちは、金融・農業・ウェブ・ITの4つの事業を通じて、お客様や地域社会の課題に向き合っています。事業の成長と、環境・社会の持続可能性を両立させることが、長期的な信頼につながると考え、次の方針のもとで取り組みます。</p>
  <ul class="prose">
    <li>法令と社会規範を守り、誠実に事業を行います。</li>
    <li>気候変動をはじめとする環境への影響を把握し、低減に努めます。</li>
    <li>従業員、取引先、地域の方々の人権を尊重し、安心して働ける環境をつくります。</li>
    <li>ステークホルダーとの対話を大切にし、情報を適切に開示します。</li>
  </ul>
</div></section>
<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">Materiality</p><h2>重要課題(マテリアリティ)</h2></div>
  <div class="grid cols-3">
    <div class="card agri"><h3>持続可能な農業と食の安定供給</h3><p>にんにく・おかわかめの栽培における水・肥料の使用量の削減と、契約農家の経営の安定を支援します。</p></div>
    <div class="card"><h3>気候変動への対応</h3><p>事業活動で生じる温室効果ガスの削減と、再生可能エネルギーの利用を進めます。</p><a class="more-link" href="/sustainability/environment/">環境(E)へ</a></div>
    <div class="card"><h3>人材の育成と多様性</h3><p>多様な人材が成長し、活躍できる環境を整えます。</p><a class="more-link" href="/sustainability/social/">社会(S)へ</a></div>
    <div class="card finance"><h3>責任ある金融とデジタル</h3><p>お客様の資産と情報を守り、誰もが使いやすいサービスを提供します。</p></div>
    <div class="card"><h3>ガバナンスの強化</h3><p>透明性の高い意思決定と、実効性のあるリスク管理を行います。</p><a class="more-link" href="/sustainability/governance/">ガバナンス(G)へ</a></div>
  </div>
</div></section>
<section class="section"><div class="container">
  <a class="banner agri" href="/news/category/sustainability/"><p class="eyebrow" style="color:#BBD3F6">News</p><h3>サステナビリティに関するニュース</h3><p>レポートの公開や取り組みの最新情報をご覧いただけます。</p></a>
</div></section>
"@
}

# ---- Environment ----
$pgs += @{
  path = '/sustainability/environment/'
  title = '環境(E)'
  description = 'TMコーポレーション株式会社の環境への取り組み(気候変動対応、農業事業での水・肥料の削減、食品ロス削減)をご紹介します。'
  crumbs = $crumbS
  body = @"
$(Get-PageHero '環境(E)' '農業事業を中心に、水・エネルギー・資源の使用量を減らす取り組みを進めています。' 'Environment')
<section class="section"><div class="container">
  $(Get-SubNav '/sustainability/environment/')
  <div class="section-head"><p class="eyebrow">Climate</p><h2>気候変動への対応</h2></div>
  <p class="prose">事業活動で生じる温室効果ガス(Scope1・2)を、2030年度までに2022年度比40%削減し、2050年度までに実質ゼロにすることを目標としています。本社や拠点の電力の切り替えと、農業事業の設備(乾燥・貯蔵設備など)の更新を中心に取り組んでいます。</p>
  <div class="section-head" style="margin-top:48px"><p class="eyebrow">Agriculture</p><h2>農業事業での取り組み</h2></div>
  $(Get-Kpis @(@('圃場の水使用量(2022年度比)', '-28', '%'), @('農業設備の電力に占める再エネ比率', '35', '%'), @('化学肥料の使用量(2022年度比)', '-15', '%')))
  <ul class="prose" style="margin-top:32px">
    <li><strong>必要な量だけの給水:</strong>土壌の水分をセンサーで把握し、にんにくやおかわかめに必要な量だけを与えます。</li>
    <li><strong>輪作と堆肥の活用:</strong>作物を入れ替えて育てる輪作や堆肥の利用により、化学肥料の使用量を減らしています。</li>
    <li><strong>食品ロスの削減:</strong>出荷の規格に合わないにんにくなどを、熟成にんにくなどの加工品にして販売しています。</li>
  </ul>
  <div class="section-head" style="margin-top:48px"><p class="eyebrow">Targets</p><h2>目標と実績</h2></div>
  $(Get-GoalTable @(@('温室効果ガス排出量(Scope1・2)', '2030年度に2022年度比40%削減', '2022年度比 -18%'), @('農業設備の再生可能エネルギー比率', '2030年度に70%', '35%'), @('圃場の水使用量', '2030年度に2022年度比40%削減', '2022年度比 -28%'), @('規格外農産物の加工・販売率', '2028年度に90%', '72%')))
</div></section>
"@
}

# ---- Social ----
$pgs += @{
  path = '/sustainability/social/'
  title = '社会(S)'
  description = 'TMコーポレーション株式会社の社会への取り組み(人材育成、多様性、地域との連携、農福連携)をご紹介します。'
  crumbs = $crumbS
  body = @"
$(Get-PageHero '社会(S)' '従業員、取引先、地域の皆様とともに成長することを目指しています。' 'Social')
<section class="section"><div class="container">
  $(Get-SubNav '/sustainability/social/')
  <div class="section-head"><p class="eyebrow">People</p><h2>人材の育成と多様性</h2></div>
  $(Get-Kpis @(@('従業員1人あたりの年間研修時間', '38', '時間'), @('女性管理職比率', '24', '%'), @('男性の育児休業取得率', '62', '%')))
  <p class="prose" style="margin-top:32px">4つの事業をまたぐ異動や研修の機会を設け、幅広い経験を積めるようにしています。性別や年齢にかかわらず活躍できるよう、柔軟な働き方の制度を整えています。</p>
  <div class="section-head" style="margin-top:48px"><p class="eyebrow">Community</p><h2>地域・農業との連携</h2></div>
  <div class="grid cols-3">
    <div class="card agri"><h3>若手就農者の支援</h3><p>就農を目指す若い方に、にんにくやおかわかめの栽培技術の研修と、設備投資の資金面の支援を行っています(年間12名)。</p></div>
    <div class="card agri"><h3>農福連携</h3><p>障がいのある方が、自社の農場で働ける機会をつくり、働きやすい環境を整えています。</p></div>
    <div class="card"><h3>デジタルの学びの場</h3><p>地域の事業者や自治体の職員を対象に、ITの基礎講座を開催しています。</p></div>
  </div>
  <div class="section-head" style="margin-top:48px"><p class="eyebrow">Targets</p><h2>目標と実績</h2></div>
  $(Get-GoalTable @(@('女性管理職比率', '2030年度に30%', '24%'), @('男性の育児休業取得率', '2028年度に80%', '62%'), @('若手就農者の支援人数', '年間15名', '12名'), @('従業員エンゲージメント調査の肯定回答率', '2028年度に75%', '68%')))
</div></section>
"@
}

# ---- Governance ----
$pgs += @{
  path = '/sustainability/governance/'
  title = 'ガバナンス(G)'
  description = 'TMコーポレーション株式会社のコーポレート・ガバナンス(取締役会、委員会、リスク管理、コンプライアンス)をご紹介します。'
  crumbs = $crumbS
  body = @"
$(Get-PageHero 'ガバナンス(G)' '透明性の高い意思決定と、実効性のあるリスク管理に取り組んでいます。' 'Governance')
<section class="section"><div class="container">
  $(Get-SubNav '/sustainability/governance/')
  <div class="section-head"><p class="eyebrow">Board</p><h2>取締役会の体制</h2></div>
  $(Get-Kpis @(@('取締役の人数', '8', '名'), @('うち社外取締役', '2', '名(25%)'), @('取締役会の年間開催回数', '14', '回')))
  <p class="prose" style="margin-top:32px">取締役会の下に、指名・報酬委員会と監査委員会を設置しています。いずれも社外取締役が委員長を務め、経営の監督の実効性を高めています。取締役の一覧は<a href="/company/executives/">役員紹介</a>をご覧ください。</p>
  <div class="section-head" style="margin-top:48px"><p class="eyebrow">Compliance &amp; Risk</p><h2>コンプライアンスとリスク管理</h2></div>
  <div class="grid cols-3">
    <div class="card"><h3>コンプライアンス</h3><p>行動規範を定め、全従業員に年1回の研修を実施しています。内部通報の窓口は、社内と社外の両方に設けています。</p></div>
    <div class="card"><h3>リスク管理</h3><p>事業ごとのリスクを定期的に評価し、重要なものは取締役会に報告しています。</p></div>
    <div class="card"><h3>情報セキュリティ</h3><p>個人情報と取引情報を保護するため、アクセス管理や訓練を継続的に行っています。</p></div>
  </div>
</div></section>
"@
}
$pgs
