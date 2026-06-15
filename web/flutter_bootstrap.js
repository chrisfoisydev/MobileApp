// Custom bootstrap. The Flutter service worker is intentionally NOT
// registered for this prototype, so the freshest build always loads with a
// single normal refresh (no incognito or cache-clearing needed).
//
// NOTE: the two loader placeholders below are substituted with multi-line
// code at build time, so they must stay on their own lines and must never
// appear inside a comment.
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
