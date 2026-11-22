@{
  path = '/company/'
  title = '企業情報'
  description = 'TMコーポレーション株式会社の企業理念、会社概要、沿革、役員紹介、アクセスをご案内します。'
  crumbs = @()
  body = @"
$(Get-PageHero '企業情報' '私たちの考え方、会社の概要、歩み、経営体制についてご紹介します。' 'Company')
<section class="section"><div class="container">
  <div class="grid cols-3">
    <div class="card"><h3>企業理念</h3><p>誠実さ・信頼・社会貢献を大切にする、私たちの基本的な考え方です。</p><a class="more-link" href="/company/philosophy/">詳しく見る</a></div>
    <div class="card"><h3>会社概要</h3><p>設立年、資本金、従業員数、事業内容などの基本情報です。</p><a class="more-link" href="/company/overview/">詳しく見る</a></div>
    <div class="card"><h3>沿革</h3><p>1968年の設立から現在までの歩みをご紹介します。</p><a class="more-link" href="/company/history/">詳しく見る</a></div>
    <div class="card"><h3>役員紹介</h3><p>取締役の氏名・経歴・担当領域をご紹介します。</p><a class="more-link" href="/company/executives/">詳しく見る</a></div>
    <div class="card"><h3>アクセス</h3><p>本社所在地と最寄り駅からのご案内です。</p><a class="more-link" href="/company/access/">詳しく見る</a></div>
  </div>
</div></section>
"@
}
