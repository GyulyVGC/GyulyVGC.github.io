(function () {
  function shrinkNavbar() {
    const navbar = document.querySelector('.navbar');
    if (!navbar) return;
    if (window.scrollY > 110) {
      navbar.classList.add('top-nav-short');
    } else {
      navbar.classList.remove('top-nav-short');
    }
  }

  function initNavbarCollapse() {
    const toggler = document.querySelector('.navbar-toggler');
    const menu = document.getElementById('main-navbar');
    const navbar = document.querySelector('.navbar');
    if (!toggler || !menu || !navbar) return;

    toggler.addEventListener('click', function () {
      const isOpen = menu.classList.toggle('show');
      toggler.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
      navbar.classList.toggle('top-nav-expanded', isOpen);
    });
  }

  function initSearch() {
    const overlay = document.getElementById('beautifuljekyll-search-overlay');
    if (!overlay) return;
    const trigger = document.getElementById('nav-search-link');
    const input = document.getElementById('nav-search-input');
    const exit = document.getElementById('nav-search-exit');
    let lastFocus = null;

    function open(e) {
      if (e) e.preventDefault();
      lastFocus = document.activeElement;
      overlay.style.display = 'block';
      document.body.classList.add('overflow-hidden');
      if (input) {
        input.focus();
        input.select();
      }
    }

    function close(e) {
      if (e) e.preventDefault();
      overlay.style.display = 'none';
      document.body.classList.remove('overflow-hidden');
      if (lastFocus && typeof lastFocus.focus === 'function') {
        lastFocus.focus();
      }
    }

    if (trigger) trigger.addEventListener('click', open);
    if (exit) exit.addEventListener('click', close);
    document.addEventListener('keyup', function (e) {
      if (e.key === 'Escape' && overlay.style.display === 'block') close();
    });
  }

  function init() {
    initNavbarCollapse();
    shrinkNavbar();
    window.addEventListener('scroll', shrinkNavbar, { passive: true });
    initSearch();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
