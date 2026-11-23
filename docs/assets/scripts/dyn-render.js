/*
 * Renders the date-driven blocks produced by dyn-core.js into the static pages.
 * The static HTML (built from src/data/*.json = the 2026-11-23 snapshot) is the no-JS fallback;
 * this script replaces the marked blocks with content for the viewing date.
 *
 * Markers:  data-dyn="<block>"  (block content is replaced)
 *           data-dyn-text="<key>" (text content is replaced)
 *
 * Testing helper: open any page with ?dyn-date=YYYY-MM-DD to pretend it is that day
 * (kept for the browser tab via sessionStorage); ?dyn-date=reset clears it.
 */
(function () {
  'use strict';
  var D = window.TMDyn;
  if (!D) return;

  var me = document.currentScript;
  var ROOT = me && me.src ? me.src.replace(/assets\/scripts\/[^\/]*$/, '') : '';

  function nowIso() {
    try {
      var q = /[?&]dyn-date=([^&]*)/.exec(location.search);
      if (q) {
        if (q[1] === 'reset') sessionStorage.removeItem('tmDynDate');
        else if (/^\d{4}-\d{2}-\d{2}$/.test(q[1])) sessionStorage.setItem('tmDynDate', q[1]);
      }
      var s = sessionStorage.getItem('tmDynDate');
      if (s && /^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
    } catch (e) { /* storage unavailable: use the real date */ }
    return D.todayIso(new Date());
  }

  var ctx = D.makeCtx(nowIso());

  function esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
  function time(d) { return '<time datetime="' + d + '">' + D.dotted(d) + '</time>'; }
  function newsHref(id) { return ROOT + 'news/detail/index.html?id=' + id; }
  function catHref(label) { return ROOT + 'news/category/' + D.catSlug[label] + '/index.html'; }

  // ---- news ----
  function newsList(items) {
    if (!items.length) return '<p>該当するニュースはありません。</p>';
    return '<ul class="news-list">' + items.map(function (n) {
      return '<li>' + time(n.date) + '<span class="tag">' + esc(n.category) + '</span><a href="' + newsHref(n.id) + '">' + esc(n.title) + '</a></li>';
    }).join('') + '</ul>';
  }
  function renderNews(el) {
    var cat = el.getAttribute('data-cat') || '', limit = parseInt(el.getAttribute('data-limit') || '0', 10);
    var items = D.news(ctx).filter(function (n) { return !cat || n.category === cat; });
    if (limit > 0) items = items.slice(0, limit);
    el.innerHTML = newsList(items);
  }
  function renderNewsDetail(el) {
    var m = /[?&]id=([^&]*)/.exec(location.search);
    var id = m ? decodeURIComponent(m[1]) : '';
    var item = D.newsById(ctx, id);
    var company = 'TMコーポレーション株式会社';
    if (!item) {
      document.title = '記事が見つかりません | ' + company;
      el.innerHTML = '<h1 style="font-size:1.7rem">記事が見つかりません</h1><p>お探しのニュースは、存在しないか、まだ公開されていません。</p>' +
        '<p style="margin-top:40px"><a class="more-link" href="' + ROOT + 'news/index.html">ニュース一覧に戻る</a></p>';
      return;
    }
    document.title = item.title + ' | ' + company;
    var desc = document.querySelector('meta[name="description"]');
    if (desc) desc.setAttribute('content', item.summary);
    el.innerHTML = '<p>' + time(item.date) + ' <a class="tag" href="' + catHref(item.category) + '" style="text-decoration:none">' + esc(item.category) + '</a></p>' +
      '<h1 style="font-size:1.7rem">' + esc(item.title) + '</h1>' +
      item.body.map(function (p) { return '<p>' + esc(p) + '</p>'; }).join('') +
      '<p style="margin-top:40px"><a class="more-link" href="' + ROOT + 'news/index.html">ニュース一覧に戻る</a></p>';
  }

  // ---- IR ----
  function sgn(now, prev) { var v = (now - prev) / prev * 100; return (v >= 0 ? '+' : '-') + Math.abs(v).toFixed(1) + '%'; }
  function kpi(label, value, unit, extra, fade) {
    return '<div class="kpi' + (fade ? ' fade in' : '') + '"><p class="kpi-label">' + esc(label) + '</p><p class="kpi-value">' + esc(value) + '<span>' + esc(unit) + '</span></p>' + (extra || '') + '</div>';
  }
  function renderKpi(el) {
    var f = D.financials(ctx), c = f.cur, p = f.prev, fade = el.getAttribute('data-fade') === '1';
    function diff(a, b) { return '<p class="kpi-diff">前期比 ' + sgn(a, b) + '</p>'; }
    el.innerHTML = kpi('売上高', D.num(c.sales), '億円', diff(c.sales, p.sales), fade) +
      kpi('営業利益', D.num(c.op), '億円', diff(c.op, p.op), fade) +
      kpi('親会社株主に帰属する当期純利益', D.num(c.net), '億円', diff(c.net, p.net), fade);
  }
  function barChart(labels, values, desc) {
    var w = 600, h = 280, padL = 16, padR = 16, padT = 28, padB = 40, max = 0, i;
    for (i = 0; i < values.length; i++) if (values[i] > max) max = values[i];
    var step = 1; while (step * 10 <= max) step *= 10;
    var top = Math.ceil(max / step) * step, n = values.length, slot = (w - padL - padR) / n;
    var bw = Math.floor(slot * 0.55), plotH = h - padT - padB;
    function r1(x) { return Math.round(x * 10) / 10; }
    var svg = '<svg class="chart" viewBox="0 0 ' + w + ' ' + h + '" role="img" aria-label="' + esc(desc) + '"><line x1="' + padL + '" y1="' + (h - padB) + '" x2="' + (w - padR) + '" y2="' + (h - padB) + '" stroke="#8A97AB"/>';
    for (i = 0; i < n; i++) {
      var bh = r1(values[i] / top * plotH), x = r1(padL + slot * i + (slot - bw) / 2), y = r1(h - padB - bh);
      var cx = r1(x + bw / 2), fill = i === n - 1 ? '#0B3D91' : '#6FA3E8';
      svg += '<rect x="' + x + '" y="' + y + '" width="' + bw + '" height="' + bh + '" fill="' + fill + '" rx="2"/>' +
        '<text x="' + cx + '" y="' + (y - 6) + '" text-anchor="middle" font-size="14" font-weight="700" fill="#1A2433">' + D.num(values[i]) + '</text>' +
        '<text x="' + cx + '" y="' + (h - padB + 22) + '" text-anchor="middle" font-size="13" fill="#4A5568">' + esc(labels[i]) + '</text>';
    }
    return svg + '</svg>';
  }
  function renderFinCharts(el) {
    var ys = D.financials(ctx).years;
    var labels = ys.map(function (y) { return String(y.year).slice(2) + '/3'; });
    function desc(title, key) { return title + 'の推移(億円)。' + ys.map(function (y) { return y.fy + D.num(y[key]); }).join('、') + '。'; }
    el.innerHTML = '<div class="chart-box"><h3>売上高</h3><p class="unit">単位:億円</p>' + barChart(labels, ys.map(function (y) { return y.sales; }), desc('売上高', 'sales')) + '</div>' +
      '<div class="chart-box"><h3>営業利益</h3><p class="unit">単位:億円</p>' + barChart(labels, ys.map(function (y) { return y.op; }), desc('営業利益', 'op')) + '</div>';
  }
  function renderFinTable(el) {
    el.innerHTML = D.financials(ctx).years.map(function (y) {
      return '<tr><th scope="row">' + esc(y.fy) + '</th><td class="num">' + D.num(y.sales) + '</td><td class="num">' + D.num(y.op) + '</td><td class="num">' + D.num(y.net) + '</td></tr>';
    }).join('');
  }
  function renderFinSeg(el) {
    var segs = D.financials(ctx).segments, total = 0;
    segs.forEach(function (s) { total += s.sales; });
    el.innerHTML = segs.map(function (s) {
      var p = Math.round(s.sales / total * 1000) / 10;
      return '<div class="share-row"><span class="share-name">' + esc(s.name) + '</span><span class="share-track" aria-hidden="true"><span class="share-bar ' + s.class + '" style="width:' + p + '%"></span></span><span class="share-val">' + D.num(s.sales) + '億円(' + p + '%)</span></div>';
    }).join('');
  }
  function renderStockBasic(el) {
    el.innerHTML = D.stock(ctx).basic.map(function (r) { return '<tr><th scope="row">' + esc(r.k) + '</th><td>' + esc(r.v) + '</td></tr>'; }).join('');
  }
  function renderStockDiv(el) {
    el.innerHTML = D.stock(ctx).dividends.map(function (r) {
      return '<tr><th scope="row">' + esc(r.fy) + '</th><td class="num">' + r.eps + '</td><td class="num">' + r.dps + '</td><td class="num">' + esc(r.payout) + '</td></tr>';
    }).join('');
  }
  function renderCalendar(el) {
    el.innerHTML = D.calendar(ctx).map(function (r) {
      var cls = r.status === '済' ? 'done' : 'plan';
      return '<tr><th scope="row">' + time(r.date) + '</th><td>' + esc(r.event) + '</td><td><span class="status ' + cls + '">' + esc(r.status) + '</span></td></tr>';
    }).join('');
  }
  function renderDocs(el) {
    el.innerHTML = D.docs(ctx).map(function (r) {
      return '<tr><td>' + time(r.date) + '</td><td><span class="tag">' + esc(r.category) + '</span></td><td>' + esc(r.title) + '</td><td><a href="' + ROOT + 'downloads/' + r.file + '">PDF<span class="sr-only">:' + esc(r.title) + '</span></a></td></tr>';
    }).join('');
  }

  // ---- sustainability ----
  function renderKpis(rows) {
    return '<div class="grid cols-3">' + rows.map(function (r) { return kpi(r[0], r[1], r[2]); }).join('') + '</div>';
  }
  function goalTable(rows, fy) {
    return '<div class="table-wrap"><table class="data"><caption class="sr-only">目標と実績</caption><thead><tr><th scope="col">項目</th><th scope="col">目標</th><th scope="col">' + fy + '年度の実績</th></tr></thead><tbody>' +
      rows.map(function (r) { return '<tr><th scope="row">' + esc(r[0]) + '</th><td>' + esc(r[1]) + '</td><td>' + esc(r[2]) + '</td></tr>'; }).join('') + '</tbody></table></div>';
  }

  var BLOCKS = {
    'news': renderNews,
    'news-detail': renderNewsDetail,
    'kpi': renderKpi,
    'fin-charts': renderFinCharts,
    'fin-table': renderFinTable,
    'fin-seg': renderFinSeg,
    'stock-basic': renderStockBasic,
    'stock-div': renderStockDiv,
    'calendar': renderCalendar,
    'docs': renderDocs,
    'sus-env-kpi': function (el) { el.innerHTML = renderKpis(D.sustainability(ctx).envKpi); },
    'sus-env-goals': function (el) { var s = D.sustainability(ctx); el.innerHTML = goalTable(s.envGoals, s.fy); },
    'sus-soc-kpi': function (el) { el.innerHTML = renderKpis(D.sustainability(ctx).socKpi); },
    'sus-soc-goals': function (el) { var s = D.sustainability(ctx); el.innerHTML = goalTable(s.socGoals, s.fy); },
    'sus-climate': function (el) { el.textContent = D.sustainability(ctx).climate; }
  };

  function run() {
    var slots = D.textSlots(ctx), i, els;
    els = document.querySelectorAll('[data-dyn]');
    for (i = 0; i < els.length; i++) {
      var fn = BLOCKS[els[i].getAttribute('data-dyn')];
      if (fn) fn(els[i]);
    }
    els = document.querySelectorAll('[data-dyn-text]');
    for (i = 0; i < els.length; i++) {
      var key = els[i].getAttribute('data-dyn-text');
      if (Object.prototype.hasOwnProperty.call(slots, key)) els[i].textContent = slots[key];
    }
  }
  run();
})();
