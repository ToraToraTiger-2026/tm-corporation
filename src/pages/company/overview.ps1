$c = $Site.company
@{
  path = '/company/overview/'
  title = '会社概要'
  description = 'TMコーポレーション株式会社の会社概要(設立、資本金、従業員数、事業内容など)をご案内します。'
  crumbs = @(@{ label = '企業情報'; href = '/company/' })
  body = @"
$(Get-PageHero '会社概要' '' 'Overview')
<section class="section"><div class="container">
  <div class="table-wrap"><table class="data">
    <caption class="sr-only">会社概要</caption>
    <tbody>
      <tr><th scope="row">社名</th><td>$(Esc $c.name)(英語表記:$(Esc $c.nameEn))</td></tr>
      <tr><th scope="row">証券コード</th><td>$(Esc $c.market) $(Esc $c.code)</td></tr>
      <tr><th scope="row">設立</th><td>$(Esc $c.founded)</td></tr>
      <tr><th scope="row">資本金</th><td>$(Esc $c.capital)</td></tr>
      <tr><th scope="row">従業員数</th><td>$(Esc $c.employees)</td></tr>
      <tr><th scope="row">売上高</th><td>$(Esc $c.sales)</td></tr>
      <tr><th scope="row">決算期</th><td>3月31日</td></tr>
      <tr><th scope="row">代表者</th><td>代表取締役社長 兼 CEO 森下 達彦</td></tr>
      <tr><th scope="row">本社所在地</th><td>$(Esc $c.address)</td></tr>
      <tr><th scope="row">事業内容</th><td>金融サービス/アグリビジネス(にんにく・おかわかめの栽培、加工品の販売)/ウェブサービス運営(「下戸マップ」の運営)/ITコンサルティング</td></tr>
    </tbody>
  </table></div>
</div></section>
"@
}
