// Minimal JS: mobile menu, dropdown toggles, page-top button, fade-in, contact form validation.
(function () {
  document.documentElement.classList.add('js');

  var toggle = document.querySelector('.menu-toggle');
  var nav = document.getElementById('global-nav');
  if (toggle && nav) {
    toggle.addEventListener('click', function () {
      var open = nav.classList.toggle('open');
      toggle.setAttribute('aria-expanded', String(open));
    });
  }

  document.querySelectorAll('.sub-toggle').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var li = btn.closest('.has-sub');
      var open = li.classList.toggle('open');
      btn.setAttribute('aria-expanded', String(open));
    });
  });

  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return;
    document.querySelectorAll('.has-sub.open').forEach(function (li) {
      li.classList.remove('open');
      var b = li.querySelector('.sub-toggle');
      if (b) b.setAttribute('aria-expanded', 'false');
    });
    if (nav && nav.classList.contains('open')) {
      nav.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
      toggle.focus();
    }
  });

  var top = document.getElementById('page-top');
  if (top) {
    var onScroll = function () { top.classList.toggle('show', window.scrollY > 400); };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  var fades = document.querySelectorAll('.fade');
  if ('IntersectionObserver' in window) {
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) { if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); } });
    }, { threshold: 0.1 });
    fades.forEach(function (el) { io.observe(el); });
  } else {
    fades.forEach(function (el) { el.classList.add('in'); });
  }

  // Contact form (validation only; nothing is sent)
  var form = document.getElementById('contact-form');
  if (form) {
    form.setAttribute('novalidate', '');
    var msgs = { valueMissing: 'この項目は必須です。', typeMismatch: '入力形式をご確認ください。', patternMismatch: '入力形式をご確認ください。' };
    var validate = function (field) {
      var err = document.getElementById(field.id + '-error');
      var v = field.validity;
      var text = '';
      if (!v.valid) text = v.valueMissing ? msgs.valueMissing : (v.typeMismatch || v.patternMismatch ? msgs.typeMismatch : field.validationMessage);
      if (err) err.textContent = text;
      field.setAttribute('aria-invalid', text ? 'true' : 'false');
      return !text;
    };
    form.querySelectorAll('input, select, textarea').forEach(function (f) {
      f.addEventListener('blur', function () { validate(f); });
    });
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var firstBad = null;
      form.querySelectorAll('input, select, textarea').forEach(function (f) {
        if (!validate(f) && !firstBad) firstBad = f;
      });
      if (firstBad) { firstBad.focus(); return; }
      form.hidden = true;
      var done = document.getElementById('contact-done');
      if (done) { done.hidden = false; done.focus(); }
    });
  }
})();
