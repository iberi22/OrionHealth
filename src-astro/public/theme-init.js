// Applies the saved or preferred theme before first paint. A file (not inline) so the CSP allows it via 'self'.
(() => {
  const theme = (() => {
    try {
      if (typeof localStorage !== 'undefined' && localStorage.getItem('oh-theme')) {
        return localStorage.getItem('oh-theme');
      }
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        return 'dark';
      }
    } catch (e) {
      // ignore
    }
    return 'light';
  })();

  if (theme === 'dark') {
    document.documentElement.setAttribute('data-theme', 'dark');
  } else {
    document.documentElement.removeAttribute('data-theme');
  }
})();
