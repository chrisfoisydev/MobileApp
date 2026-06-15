// Custom bootstrap: the Flutter service worker is intentionally NOT
// registered for this prototype, so the freshest build always loads with a
// single normal refresh (no incognito or cache-clearing needed).
//
// Flutter substitutes {{flutter_js}} and {{flutter_build_config}} at build
// time; this file is used in place of the auto-generated bootstrap.
{{flutter_js}}
{{flutter_build_config}}

(async () => {
  // Free returning visitors from any worker/cache installed by earlier
  // deploys, then load the app without registering a new one.
  try {
    if ('serviceWorker' in navigator) {
      const regs = await navigator.serviceWorker.getRegistrations();
      await Promise.all(regs.map((r) => r.unregister()));
    }
    if (window.caches && caches.keys) {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
    }
  } catch (e) {
    // Best-effort cleanup; ignore failures.
  }
  _flutter.loader.load();
})();
