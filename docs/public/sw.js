// OrionHealth PWA Service Worker - Offline Cache Strategy
// Cache-first for medical standards data, network-first for docs

const CACHE_NAME = 'orionhealth-v1';
const STATIC_ASSETS = [
  '/OrionHealth/',
  '/OrionHealth/dashboard',
  '/OrionHealth/medical-standards',
  '/OrionHealth/about',
  '/OrionHealth/privacy',
];

// Install: cache critical pages
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch(() => {
        // Ignore errors for optional pages
      });
    })
  );
  self.skipWaiting();
});

// Activate: clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((names) => {
      return Promise.all(
        names
          .filter((name) => name !== CACHE_NAME)
          .map((name) => caches.delete(name))
      );
    })
  );
  self.clients.claim();
});

// Fetch: cache-first for medical data, network-first for everything else
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Medical standards data: cache-first (offline accessible)
  if (url.pathname.includes('/medical-standards/')) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        return cached || fetch(event.request).then((response) => {
          return caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, response.clone());
            return response;
          });
        });
      })
    );
    return;
  }

  // Static assets: cache-first
  if (event.request.destination === 'style' || 
      event.request.destination === 'script' ||
      event.request.destination === 'font' ||
      event.request.destination === 'image') {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        return cached || fetch(event.request).then((response) => {
          return caches.open(CACHE_NAME).then((cache) => {
            cache.put(event.request, response.clone());
            return response;
          });
        });
      })
    );
    return;
  }

  // HTML pages: network-first, fallback to cache
  if (event.request.mode === 'navigate') {
    event.respondWith(
      fetch(event.request).catch(() => {
        return caches.match(event.request).then((cached) => {
          return cached || caches.match('/OrionHealth/');
        });
      })
    );
    return;
  }

  // Everything else: network-only
  event.respondWith(fetch(event.request).catch(() => {
    return caches.match(event.request);
  }));
});
