@{
  path = '/company/philosophy/'
  title = '企業理念'
  description = 'TMコーポレーション株式会社の企業理念・ビジョン・行動指針をご紹介します。'
  crumbs = @(@{ label = '企業情報'; href = '/company/' })
  body = @"
$(Get-PageHero '企業理念' '誠実に向き合い、信頼を積み重ね、社会に貢献する。これが私たちの変わらない姿勢です。' 'Philosophy')
<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Mission</p><h2>ミッション</h2></div>
  <p class="prose" style="font-size:1.25rem;font-weight:700;color:var(--c-primary-dark)">信頼を礎に、人と産業の未来を育てる。</p>
  <p class="prose">私たちは、金融・農業・ウェブ・ITという異なる分野の事業を通じて、お客様と社会の課題に向き合います。目先の成果だけでなく、長く信頼していただける関係づくりを大切にしています。</p>
</div></section>
<section class="section soft"><div class="container">
  <div class="section-head"><p class="eyebrow">Vision</p><h2>ビジョン</h2></div>
  <p class="prose">4つの事業の知見をつなぎ、暮らしと産業の基盤を支えるグループを目指します。農業とITの融合による食の安定供給、金融とウェブの連携による事業者支援など、事業の垣根を越えた価値の創出に取り組みます。</p>
</div></section>
<section class="section"><div class="container">
  <div class="section-head"><p class="eyebrow">Values</p><h2>行動指針</h2></div>
  <div class="grid cols-3">
    <div class="card"><h3>誠実であること</h3><p>法令と社会規範を守り、お客様や取引先に対して正直に行動します。</p></div>
    <div class="card"><h3>信頼を積み重ねること</h3><p>約束を守り、継続的な改善を通じて、安心してご利用いただけるサービスを提供します。</p></div>
    <div class="card"><h3>社会に貢献すること</h3><p>事業を通じて、地域社会と環境の持続可能性に貢献します。</p></div>
  </div>
</div></section>
"@
}
