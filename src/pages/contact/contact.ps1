@{
  path = '/contact/'
  title = 'お問い合わせ'
  description = 'TMコーポレーション株式会社へのお問い合わせフォームです。'
  crumbs = @()
  body = @"
$(Get-PageHero 'お問い合わせ' '' 'Contact')
<section class="section"><div class="container">
  <div class="prose">
    <form id="contact-form" action="/contact/" method="post" novalidate>
      <div class="form-row">
        <label for="f-type">お問い合わせ種別<span class="req">必須</span></label>
        <select id="f-type" name="type" required aria-describedby="f-type-error">
          <option value="">選択してください</option>
          <option>事業・サービスについて</option>
          <option>IR・株式について</option>
          <option>採用について</option>
          <option>取材・報道について</option>
          <option>その他</option>
        </select>
        <p class="error-msg" id="f-type-error" role="alert"></p>
      </div>
      <div class="form-row">
        <label for="f-company">会社名・団体名<span class="sr-only">(任意)</span></label>
        <input type="text" id="f-company" name="company" autocomplete="organization">
      </div>
      <div class="form-row">
        <label for="f-name">お名前<span class="req">必須</span></label>
        <input type="text" id="f-name" name="name" required autocomplete="name" aria-describedby="f-name-error">
        <p class="error-msg" id="f-name-error" role="alert"></p>
      </div>
      <div class="form-row">
        <label for="f-email">メールアドレス<span class="req">必須</span></label>
        <input type="email" id="f-email" name="email" required autocomplete="email" aria-describedby="f-email-error">
        <p class="error-msg" id="f-email-error" role="alert"></p>
      </div>
      <div class="form-row">
        <label for="f-tel">電話番号<span class="sr-only">(任意)</span></label>
        <input type="tel" id="f-tel" name="tel" autocomplete="tel" pattern="[0-9+()\-]*" inputmode="tel" placeholder="例:03-0000-0000" aria-describedby="f-tel-error">
        <p class="error-msg" id="f-tel-error" role="alert"></p>
      </div>
      <div class="form-row">
        <label for="f-body">お問い合わせ内容<span class="req">必須</span></label>
        <textarea id="f-body" name="body" required aria-describedby="f-body-error"></textarea>
        <p class="error-msg" id="f-body-error" role="alert"></p>
      </div>
      <div class="form-row">
        <input type="checkbox" id="f-agree" name="agree" required aria-describedby="f-agree-error">
        <label for="f-agree" style="display:inline">個人情報の取り扱い(<a href="/privacy/">プライバシーポリシー</a>)に同意する<span class="req">必須</span></label>
        <p class="error-msg" id="f-agree-error" role="alert"></p>
      </div>
      <button type="submit" class="btn">確認して送信</button>
    </form>

    <div id="contact-done" class="notice" hidden tabindex="-1" role="status">
      <h2 style="font-size:1.2rem">入力内容を確認しました</h2>
      <p>入力内容に不備はありませんでした。なお、このフォームからは、実際の送信は行われません。</p>
      <p><a href="/">トップページへ戻る</a></p>
    </div>
  </div>
</div></section>
"@
}
