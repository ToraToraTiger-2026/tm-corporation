/*
 * TM Corporation (fictional demo site): date-driven content generators.
 *
 * Everything here is a PURE function of the viewing date, so no rebuild or manual
 * maintenance is needed: news, IR calendar, IR library, financials, stock facts,
 * recruiting year and sustainability figures all follow "today".
 *
 *  - Same input date  -> same output (deterministic; seeded PRNG, no Math.random).
 *  - The state of the site on 2026-11-23 (BASE_ISO) is reproduced exactly; the static
 *    JSON under src/data/ is that same snapshot and serves as the no-JS fallback.
 *  - Past facts (history, founding, executive careers) are NOT generated.
 *
 * Dates are handled as 'YYYY-MM-DD' strings (lexicographic order == chronological order),
 * so there are no time-zone surprises.
 */
(function (root) {
  'use strict';

  var FOUNDED = 1968;            // period number = fiscal year - FOUNDED
  var BASE_ISO = '2026-11-23';   // snapshot date; "now" is never earlier than this
  var FLOOR_ISO = '2026-04-01';  // generated content starts here (first news is 2026-04-18)
  var SHARES = 24000000;         // issued shares (fixed)
  var NEWS_MONTHS = 24;          // how far back lists reach

  // ---------- small helpers ----------
  function pad(n) { return n < 10 ? '0' + n : '' + n; }
  function iso(y, m, d) { return y + '-' + pad(m) + '-' + pad(d); }
  function parts(s) { var p = s.split('-'); return { y: +p[0], m: +p[1], d: +p[2] }; }
  function dotted(s) { return s.replace(/-/g, '.'); }
  function num(n) { return String(Math.round(n)).replace(/\B(?=(\d{3})+(?!\d))/g, ','); }
  function addMonths(s, k) {
    var p = parts(s), t = p.y * 12 + (p.m - 1) + k;
    var y = Math.floor(t / 12), m = t % 12 + 1, d = Math.min(p.d, 28);
    return iso(y, m, d);
  }
  function todayIso(date) { return iso(date.getFullYear(), date.getMonth() + 1, date.getDate()); }
  function rng(seed) { // mulberry32
    var a = seed >>> 0;
    return function () {
      a = (a + 0x6D2B79F5) >>> 0;
      var t = a;
      t = Math.imul(t ^ (t >>> 15), t | 1);
      t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
  function pct(a, b) { return (((a - b) / b) * 100).toFixed(1); }
  function period(y) { return y - FOUNDED; }          // 第N期 (fiscal year ending March of y)
  function fyLabel(y) { return y + '年3月期'; }

  // ---------- context: everything that depends on "today" ----------
  function makeCtx(nowIso) {
    if (!nowIso || nowIso < BASE_ISO) nowIso = BASE_ISO;
    var y = parts(nowIso).y;
    return {
      now: nowIso,
      year: y,
      latestFY: nowIso >= iso(y, 5, 20) ? y : y - 1,       // latest fiscal year whose results are published
      recruitClass: nowIso >= iso(y, 7, 15) ? y + 1 : y,   // new-graduate class being recruited
      sustFY: nowIso >= iso(y, 10, 20) ? y - 1 : y - 2     // fiscal year covered by the latest sustainability report
    };
  }

  // ---------- financials ----------
  var FIN_ANCHOR = { 2022: [228, 23, 15], 2023: [243, 25, 17], 2024: [258, 28, 19], 2025: [271, 31, 21], 2026: [286, 33, 23] };
  var SEG_NAMES = ['金融サービス', 'アグリビジネス', 'ウェブサービス運営', 'ITコンサルティング'];
  var SEG_CLASS = ['finance', 'agri', 'web', 'consulting'];
  var SEG_BASE = [134, 62, 18, 72];
  var SEG_TREND = [-4, -2, 12, 8]; // permille of share per year
  var finCache = {};

  function fin(f) {
    if (f < 2022) f = 2022;
    if (finCache[f]) return finCache[f];
    var r;
    if (f <= 2026) {
      var a = FIN_ANCHOR[f];
      r = { fy: fyLabel(f), year: f, sales: a[0], op: a[1], net: a[2] };
    } else {
      var p = fin(f - 1), g = rng(f * 7919 + 13);
      var sales = Math.round(p.sales * (1000 + 20 + Math.floor(g() * 51)) / 1000);          // +2.0% .. +7.0%
      var pm = p.op / p.sales * 1000;
      var m = Math.min(125, Math.max(105, pm + (g() - 0.5) * 10));                           // margin 10.5% .. 12.5%
      var op = Math.max(p.op + 1, Math.round(sales * m / 1000));
      var k = 66 + Math.floor(g() * 9);                                                      // net / operating = 0.66 .. 0.74
      var net = Math.max(p.net + 1, Math.round(op * k / 100));
      r = { fy: fyLabel(f), year: f, sales: sales, op: op, net: net };
    }
    r.eps = Math.round(r.net * 100000000 / SHARES);
    r.dps = Math.round(r.eps * 3 / 10);
    r.payout = '30%';
    finCache[f] = r;
    return r;
  }

  function segments(f, sales) {
    var n = Math.min(Math.max(f - 2026, 0), 15), out = [], i;
    if (n === 0) {
      for (i = 0; i < 4; i++) out.push({ name: SEG_NAMES[i], class: SEG_CLASS[i], sales: SEG_BASE[i] });
      return out;
    }
    var g = rng(f * 104729 + 7), w = [], tot = 0;
    for (i = 0; i < 4; i++) {
      w[i] = Math.max(0.02, SEG_BASE[i] / 286 + SEG_TREND[i] / 1000 * n + (g() - 0.5) * 0.006);
      tot += w[i];
    }
    var ex = [], fl = [], used = 0;
    for (i = 0; i < 4; i++) { ex[i] = w[i] / tot * sales; fl[i] = Math.floor(ex[i]); used += fl[i]; }
    var order = [0, 1, 2, 3].sort(function (a, b) { return (ex[b] - fl[b]) - (ex[a] - fl[a]) || a - b; });
    for (i = 0; i < sales - used; i++) fl[order[i]]++;
    for (i = 0; i < 4; i++) out.push({ name: SEG_NAMES[i], class: SEG_CLASS[i], sales: fl[i] });
    return out;
  }

  function financials(ctx) {
    var years = [], f;
    for (f = ctx.latestFY - 4; f <= ctx.latestFY; f++) years.push(fin(f));
    var cur = years[4];
    return { years: years, cur: cur, prev: years[3], segments: segments(cur.year, cur.sales) };
  }

  function stock(ctx) {
    var rows = [], f, cur = ctx.latestFY;
    for (f = cur - 4; f <= cur; f++) { var x = fin(f); rows.push({ fy: x.fy, eps: x.eps, dps: x.dps, payout: x.payout }); }
    var n = Math.max(cur - 2026, 0);
    var holders = Math.round((6800 + 80 * n) / 100) * 100;
    return {
      dividends: rows,
      basic: [
        { k: '証券コード', v: '9999' },
        { k: '上場市場', v: '東京証券取引所 プライム市場' },
        { k: '決算期', v: '3月31日' },
        { k: '定時株主総会', v: '6月' },
        { k: '発行済株式総数', v: '24,000,000株' },
        { k: '単元株式数', v: '100株' },
        { k: '株主数', v: num(holders) + '名' },
        { k: '株主名簿管理人', v: '青葉信託銀行株式会社' }
      ]
    };
  }

  function company(ctx) {
    var n = Math.max(ctx.latestFY - 2026, 0), c = fin(ctx.latestFY);
    return {
      employees: (582 + 5 * n) + '名(連結)',
      sales: num(c.sales) + '億円(' + c.fy + '・連結)'
    };
  }

  // ---------- news ----------
  var CATS = { notice: 'お知らせ', ir: 'IR', press: 'プレス', sustainability: 'サステナビリティ' };
  var CAT_SLUG = { 'お知らせ': 'notice', 'IR': 'ir', 'プレス': 'press', 'サステナビリティ': 'sustainability' };

  var PRESS_DATASUPPORT = [
    ['ITコンサルティング:データ活用の伴走支援サービスを開始します', 'データの整備から分析、現場への定着までを一貫して支援します。',
      ['当社は、企業や自治体向けに、データの整備から分析、現場への定着までを一貫して支援する伴走型サービスを開始します。', '金融・農業・ウェブ各事業で培った知見を活用します。']],
    ['ITコンサルティング:自治体向けのデジタル人材育成プログラムを開始します', '職員のデータ活用力を高める研修と実習をセットで提供します。',
      ['当社は、自治体の職員向けに、データ活用の基礎から実習までを学べるデジタル人材育成プログラムを開始します。', '研修の後も、現場での活用を伴走して支援します。']],
    ['ITコンサルティング:中小企業向けの業務改善診断サービスを提供します', '業務の流れを可視化し、改善の優先順位を提案します。',
      ['当社は、中小企業向けに、業務の流れを可視化して改善の優先順位を提案する診断サービスの提供を開始します。', '診断の結果をもとに、システムの導入から定着までを支援します。']],
    ['ITコンサルティング:生成AIの社内活用を支援する導入支援サービスを開始します', '利用ルールの整備から、データの安全な取り扱いまでを支援します。',
      ['当社は、生成AIを社内で活用したい企業向けに、利用ルールの整備からデータの安全な取り扱いまでを支援する導入支援サービスを開始します。', '業務に合った使い方を、現場の担当者と一緒に検討します。']]
  ];
  var PRESS_PAYLINE = [
    ['金融サービス:中小企業向け電子決済プラン「TMペイライン」を拡充しました', '請求書の発行から入金確認までを一括で行える機能を追加しました。',
      ['中小企業向け電子決済プラン「TMペイライン」に、請求書の発行から入金確認までを一括で行える機能を追加しました。', '事業者の事務負担を軽減し、資金繰りの見通しを立てやすくします。']],
    ['金融サービス:「TMペイライン」に資金繰りの見通しを確認できる機能を追加しました', '入出金の予定をもとに、数か月先の残高の目安を表示します。',
      ['中小企業向け電子決済プラン「TMペイライン」に、入出金の予定をもとに数か月先の残高の目安を表示する機能を追加しました。', '資金が不足しそうな時期を早めに把握できるようにします。']],
    ['金融サービス:事業者向けの融資申込みのオンライン手続きを拡充しました', '必要書類の提出から審査状況の確認まで、画面上で完結できます。',
      ['事業者向け融資の申込みについて、必要書類の提出から審査状況の確認までを、画面上で完結できるようにしました。', '来店の負担を減らし、お客様の事務の時間を短縮します。']],
    ['金融サービス:資産運用のサポートに、定期的な相談の機会を設けました', '担当者が年に複数回、運用状況をご説明します。',
      ['資産運用のサポートについて、担当者が年に複数回、運用状況をご説明する定期的な相談の機会を設けました。', 'お客様の事業の状況に合わせた見直しを提案します。']]
  ];
  var PRESS_FARMLINK = [
    ['アグリビジネス:契約農家向け需給予測サービス「TMファームリンク」の提供を開始します', '出荷量と需要の見込みを可視化し、契約農家の計画づくりを支援します。',
      ['当社は、契約農家向けの需給予測サービス「TMファームリンク」の提供を開始します。圃場のセンサーデータと取引データをもとに、にんにくやおかわかめの出荷時期の目安を提示します。', '今後は、加工品の販売データとも連携し、予測の精度向上に取り組みます。']],
    ['アグリビジネス:「TMファームリンク」に加工品の販売データを連携しました', '加工品の需要も踏まえて、出荷の計画を立てられます。',
      ['契約農家向けの需給予測サービス「TMファームリンク」に、加工品の販売データを連携しました。加工品の需要も踏まえて、にんにくやおかわかめの出荷計画を立てられます。', '今後も、予測の精度向上に取り組みます。']],
    ['アグリビジネス:規格外農産物を活用した新しい加工品の販売を開始します', '出荷の規格に合わない農産物を、新しい加工品として届けます。',
      ['当社は、出荷の規格に合わないにんにくやおかわかめを活用した、新しい加工品の販売を開始します。', '食品ロスの削減と、契約農家の収入の安定に役立てます。']],
    ['アグリビジネス:圃場センサーの対象を拡大し、栽培管理の支援を強化します', '土壌の水分や気温の把握を、より多くの圃場に広げます。',
      ['当社は、土壌の水分や気温を把握する圃場センサーの設置を、より多くの契約農家の圃場に広げます。', '水や肥料を必要な量だけ与える栽培管理の支援を強化します。']]
  ];
  var NOTICE_ORG = [
    ['事業部門間の連携を強化するため、グループ横断のデータ推進室を設置しました。'],
    ['農業事業の生産体制を強化するため、アグリビジネス事業に生産技術部を新設しました。'],
    ['サービスの安全性を高めるため、ウェブサービス事業にセキュリティ統括室を設置しました。'],
    ['お客様への提案力を高めるため、金融サービス事業に決済サービス部を新設しました。']
  ];

  function pick(list, y) { return list[((y - 2026) % list.length + list.length) % list.length]; }

  function newsForYear(y) {
    var n = period(y), F = fyLabel, C = y + 1, items = [], a, b;
    function add(m, d, slug, cat, title, summary, body) {
      var date = iso(y, m, d);
      items.push({ id: date.replace(/-/g, '') + '-' + slug, slug: slug, date: date, category: cat, title: title, summary: summary, body: body });
    }
    var cur = fin(y), prv = fin(y - 1);
    var spct = pct(cur.sales, prv.sales), opct = pct(cur.op, prv.op);

    a = pick(PRESS_DATASUPPORT, y);
    add(4, 18, 'press-datasupport', 'プレス', a[0], a[1], a[2]);

    add(5, 20, 'ir-fy' + y, 'IR', F(y) + ' 決算短信を公表しました',
      '連結売上高は' + num(cur.sales) + '億円(前期比' + spct + '%増)となりました。',
      [F(y) + 'の連結業績について、決算短信を公表しました。連結売上高は' + num(cur.sales) + '億円(前期比' + spct + '%増)、営業利益は' + num(cur.op) + '億円(同' + opct + '%増)となりました。']);

    add(6, 24, 'ir-agm', 'IR', '第' + n + '期定時株主総会 決議ご通知を掲載しました',
      '第' + n + '期定時株主総会の決議結果をお知らせします。',
      [y + '年6月24日に開催した第' + n + '期定時株主総会において、すべての議案が原案どおり承認可決されました。']);

    add(7, 15, 'notice-recruit', 'お知らせ', C + '年度 新卒採用のエントリー受付を開始しました',
      C + '年度入社の新卒採用エントリーの受付を開始しました。',
      [C + '年度入社の新卒採用について、エントリーの受付を開始しました。募集職種や選考の流れは、採用情報ページをご確認ください。']);

    add(8, 8, 'ir-q1', 'IR', F(C) + ' 第1四半期決算短信を公表しました',
      F(C) + '第1四半期の決算短信を公表しました。',
      [F(C) + '第1四半期の連結業績について、決算短信を公表しました。詳細はIR資料室をご覧ください。']);

    var stores = num(8000 + 1000 * (y - 2026));
    add(8, 25, 'press-gekomap', 'プレス', 'ウェブサービス運営:「下戸マップ」の掲載店舗数が' + stores + '店を超えました',
      'お酒を飲まない人でも入りやすいお店の掲載が、' + stores + '店を超えました。',
      ['当社が運営する「下戸マップ」の掲載店舗数が、' + stores + '店を超えました。利用者の匿名の投稿をもとに、お酒を飲まない人でも入りやすいお店の情報を掲載しています。', '今後も、運営による投稿の確認体制を維持しながら、掲載エリアと情報の充実に取り組みます。']);

    a = pick(PRESS_PAYLINE, y);
    add(9, 12, 'press-payline', 'プレス', a[0], a[1], a[2]);

    b = pick(NOTICE_ORG, y);
    add(10, 1, 'notice-org', 'お知らせ', '組織変更および人事異動のお知らせ',
      y + '年10月1日付の組織変更および人事異動についてお知らせします。',
      [y + '年10月1日付で、' + b[0], 'あわせて、人事異動を実施しましたので、お知らせします。']);

    add(10, 20, 'sus-report', 'サステナビリティ', '「TMグループ サステナビリティレポート' + y + '」を公開しました',
      '環境・社会・ガバナンスの取り組みと実績をまとめたレポートを公開しました。',
      ['環境・社会・ガバナンスに関する' + (y - 1) + '年度の取り組みと実績をまとめた「TMグループ サステナビリティレポート' + y + '」を公開しました。', 'にんにく・おかわかめの栽培における水や肥料の使用量の削減や、地域の農家との協働事例も掲載しています。']);

    a = pick(PRESS_FARMLINK, y);
    add(11, 5, 'press-farmlink', 'プレス', a[0], a[1], a[2]);

    add(11, 14, 'ir-q2', 'IR', F(C) + ' 第2四半期決算短信を公表しました',
      F(C) + '第2四半期(累計)の決算短信を公表しました。',
      [F(C) + '第2四半期(累計)の連結業績について、決算短信を公表しました。詳細はIR資料室をご覧ください。']);

    add(2, 12, 'ir-q3', 'IR', F(y) + ' 第3四半期決算短信を公表しました',
      F(y) + '第3四半期(累計)の決算短信を公表しました。',
      [F(y) + '第3四半期(累計)の連結業績について、決算短信を公表しました。詳細はIR資料室をご覧ください。']);

    return items;
  }

  function byDateDesc(a, b) { return a.date < b.date ? 1 : (a.date > b.date ? -1 : 0); }

  // All items published up to "now" (no window). Used for list building and for id lookup.
  function allNews(ctx) {
    var out = [], y;
    for (y = 2026; y <= ctx.year; y++) {
      newsForYear(y).forEach(function (it) { if (it.date >= FLOOR_ISO && it.date <= ctx.now) out.push(it); });
    }
    return out.sort(byDateDesc);
  }
  function news(ctx) {
    var from = addMonths(ctx.now, -NEWS_MONTHS);
    return allNews(ctx).filter(function (it) { return it.date > from; });
  }
  // Resolve a permalink id (YYYYMMDD-slug). Valid forever for any past date >= 2026-04-01.
  function newsById(ctx, id) {
    var m = /^(\d{4})(\d{2})(\d{2})-([a-z0-9-]+)$/.exec(id || '');
    if (!m) return null;
    var y = +m[1];
    if (y < 2026 || y > ctx.year) return null;
    var hit = newsForYear(y).filter(function (it) { return it.id === id; })[0];
    return hit && hit.date >= FLOOR_ISO && hit.date <= ctx.now ? hit : null;
  }

  // ---------- IR calendar / library ----------
  function calendar(ctx) {
    var ev = [], y, from = ctx.year - 1, to = ctx.year + 2;
    for (y = from; y <= to; y++) {
      ev.push({ date: iso(y, 2, 12), event: fyLabel(y) + ' 第3四半期決算発表' });
      ev.push({ date: iso(y, 3, 31), event: fyLabel(y) + ' 決算期末' });
      ev.push({ date: iso(y, 5, 20), event: fyLabel(y) + ' 決算発表' });
      ev.push({ date: iso(y, 6, 24), event: '第' + period(y) + '期 定時株主総会' });
      ev.push({ date: iso(y, 8, 8), event: fyLabel(y + 1) + ' 第1四半期決算発表' });
      ev.push({ date: iso(y, 11, 14), event: fyLabel(y + 1) + ' 第2四半期決算発表' });
    }
    ev.sort(function (a, b) { return a.date < b.date ? -1 : (a.date > b.date ? 1 : 0); });
    var past = ev.filter(function (e) { return e.date <= ctx.now && e.date >= FLOOR_ISO; });
    var next = ev.filter(function (e) { return e.date > ctx.now; }).slice(0, 5);
    var last = past.slice(-1);
    return last.map(function (e) { return { date: e.date, event: e.event, status: '済' }; })
      .concat(next.map(function (e) { return { date: e.date, event: e.event, status: '予定' }; }));
  }

  var DOC_FILE = { tanshin: 'tanshin-2026.pdf', tanshinq: 'tanshin-2027q2.pdf', setsumei: 'setsumei-2027q2.pdf', yuho: 'yuho-58.pdf', shoshu: 'shoshu-58.pdf', integrated: 'integrated-2026.pdf' };

  function docs(ctx) {
    var out = [], y, n, from = addMonths(ctx.now, -NEWS_MONTHS);
    for (y = 2026; y <= ctx.year; y++) {
      n = period(y);
      [
        [iso(y, 11, 14), '決算', fyLabel(y + 1) + ' 第2四半期 決算短信', 'tanshinq'],
        [iso(y, 11, 14), '決算', fyLabel(y + 1) + ' 第2四半期 決算説明資料', 'setsumei'],
        [iso(y, 10, 20), '統合報告', 'TMグループ 統合報告書' + y, 'integrated'],
        [iso(y, 6, 24), '法定開示', '第' + n + '期 有価証券報告書', 'yuho'],
        [iso(y, 6, 2), '株主総会', '第' + n + '期 定時株主総会 招集通知', 'shoshu'],
        [iso(y, 5, 20), '決算', fyLabel(y) + ' 決算短信', 'tanshin']
      ].forEach(function (r) {
        if (r[0] >= FLOOR_ISO && r[0] <= ctx.now && r[0] > from) out.push({ date: r[0], category: r[1], title: r[2], file: DOC_FILE[r[3]] });
      });
    }
    return out.sort(byDateDesc);
  }

  // ---------- recruiting ----------
  function recruit(ctx) {
    var c = ctx.recruitClass;
    return { classYear: c, gradYear: c, gradText: c + '年3月卒業見込み' };
  }

  // ---------- sustainability ----------
  function prog(base, step, limit, n) {
    var v = base + step * n;
    return Math.round(step > 0 ? Math.min(v, limit) : Math.max(v, limit));
  }
  function sustainability(ctx) {
    var rep = ctx.sustFY, n = Math.max(rep - 2025, 0), T = Math.min(rep + 5, 2049), M = rep + 3;
    var v = {
      water: prog(-28, -1.5, -38, n), renew: prog(35, 3, 65, n), ghg: prog(-18, -2, -36, n), fert: prog(-15, -1.5, -28, n),
      proc: prog(72, 2, 88, n), fem: prog(24, 1, 29, n), par: prog(62, 2, 78, n), young: prog(12, 0.5, 14, n),
      eng: prog(68, 1, 74, n), train: prog(38, 1, 48, n)
    };
    return {
      fy: rep, targetYear: T, midYear: M, values: v,
      envKpi: [['圃場の水使用量(2022年度比)', String(v.water), '%'], ['農業設備の電力に占める再エネ比率', String(v.renew), '%'], ['化学肥料の使用量(2022年度比)', String(v.fert), '%']],
      envGoals: [
        ['温室効果ガス排出量(Scope1・2)', T + '年度に2022年度比40%削減', '2022年度比 ' + v.ghg + '%'],
        ['農業設備の再生可能エネルギー比率', T + '年度に70%', v.renew + '%'],
        ['圃場の水使用量', T + '年度に2022年度比40%削減', '2022年度比 ' + v.water + '%'],
        ['規格外農産物の加工・販売率', M + '年度に90%', v.proc + '%']
      ],
      socKpi: [['従業員1人あたりの年間研修時間', String(v.train), '時間'], ['女性管理職比率', String(v.fem), '%'], ['男性の育児休業取得率', String(v.par), '%']],
      socGoals: [
        ['女性管理職比率', T + '年度に30%', v.fem + '%'],
        ['男性の育児休業取得率', M + '年度に80%', v.par + '%'],
        ['若手就農者の支援人数', '年間15名', v.young + '名'],
        ['従業員エンゲージメント調査の肯定回答率', M + '年度に75%', v.eng + '%']
      ],
      climate: '事業活動で生じる温室効果ガス(Scope1・2)を、' + T + '年度までに2022年度比40%削減し、2050年度までに実質ゼロにすることを目標としています。本社や拠点の電力の切り替えと、農業事業の設備(乾燥・貯蔵設備など)の更新を中心に取り組んでいます。'
    };
  }

  // ---------- one-stop snapshot + simple text slots ----------
  function snapshot(nowIso) {
    var ctx = makeCtx(nowIso);
    return {
      ctx: ctx, news: news(ctx), calendar: calendar(ctx), docs: docs(ctx), financials: financials(ctx),
      stock: stock(ctx), company: company(ctx), recruit: recruit(ctx), sustainability: sustainability(ctx)
    };
  }

  function textSlots(ctx) {
    var s = sustainability(ctx), r = recruit(ctx), c = company(ctx);
    return {
      year: String(ctx.year),
      latestFY: fyLabel(ctx.latestFY),
      gradYear: String(r.gradYear),
      employees: c.employees,
      sales: c.sales,
      parental: String(s.values.par),
      young: String(s.values.young)
    };
  }

  root.TMDyn = {
    BASE_ISO: BASE_ISO, makeCtx: makeCtx, todayIso: todayIso, dotted: dotted, num: num, pct: pct,
    fin: fin, financials: financials, stock: stock, company: company, news: news, allNews: allNews, newsById: newsById, newsForYear: newsForYear,
    calendar: calendar, docs: docs, recruit: recruit, sustainability: sustainability, snapshot: snapshot, textSlots: textSlots,
    catSlug: CAT_SLUG, cats: CATS, period: period, fyLabel: fyLabel
  };
})(typeof window !== 'undefined' ? window : this);
