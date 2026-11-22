$c = $Site.company
@{
  path = '/company/access/'
  title = 'アクセス'
  description = 'TMコーポレーション株式会社 本社所在地とアクセスのご案内です(架空の住所です)。'
  crumbs = @(@{ label = '企業情報'; href = '/company/' })
  body = @"
$(Get-PageHero 'アクセス' '' 'Access')
<section class="section"><div class="container">
  <div class="grid cols-2" style="align-items:start">
    <div>
      <h2>本社</h2>
      <p>$(Esc $c.address)</p>
      <p>電話:$(Esc $c.phone)</p>
      <h3>交通のご案内</h3>
      <ul>
        <li>東京駅(架空の出口):徒歩5分</li>
        <li>二重橋前駅:徒歩3分</li>
      </ul>
      <p class="notice">本サイトは架空の企業を題材にしたデモサイトです。住所・電話番号は実在しません。</p>
    </div>
    <svg viewBox="0 0 480 320" role="img" aria-label="本社周辺の略図(イメージ)" style="width:100%;border:1px solid var(--c-line);border-radius:6px;background:#F3F6FA">
      <path d="M0 200h480M0 110h480M120 0v320M330 0v320" stroke="#D9E1EC" stroke-width="14" fill="none"/>
      <rect x="150" y="125" width="150" height="60" fill="#E4ECF7"/>
      <rect x="345" y="215" width="90" height="70" fill="#E4ECF7"/>
      <rect x="20" y="215" width="80" height="70" fill="#E4ECF7"/>
      <circle cx="225" cy="155" r="14" fill="#0B3D91"/><text x="248" y="160" font-size="16" font-weight="700" fill="#082B66" font-family="sans-serif">TMタワー</text>
      <rect x="345" y="20" width="110" height="30" rx="4" fill="#fff" stroke="#D9E1EC"/><text x="357" y="40" font-size="14" fill="#4A5568" font-family="sans-serif">最寄駅(イメージ)</text>
    </svg>
  </div>
</div></section>
"@
}
