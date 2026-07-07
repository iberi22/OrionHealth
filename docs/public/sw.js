// OrionHealth PWA Service Worker - Offline Cache Strategy
// Cache-first for medical standards data, network-first for docs

const CACHE_NAME = 'orionhealth-v1.1.0';
const STATIC_ASSETS = [
  '/OrionHealth/',
  '/OrionHealth/dashboard',
  '/OrionHealth/medical-standards',
  '/OrionHealth/medical-standards/guidelines',
  '/OrionHealth/medical-standards/interactions',
  '/OrionHealth/about',
  '/OrionHealth/privacy',
  '/OrionHealth/favicon.svg',
  '/OrionHealth/manifest.json',
  '/OrionHealth/offline.html'
];

const MEDICAL_DATA = [
  '/OrionHealth/icd10.json',
  '/OrionHealth/icd10_expanded.json',
  '/OrionHealth/loinc.json',
  '/OrionHealth/rxnorm.json',
  '/OrionHealth/snomed.json',
  '/OrionHealth/clinical_guidelines.json',
  '/OrionHealth/rxnorm_interactions.json'
];

// Install: cache critical pages and medical data
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll([...STATIC_ASSETS, ...MEDICAL_DATA]).catch((err) => {
        console.error('SW: Cache install error', err);
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

// Fetch: specialized strategies
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Medical standards data & assets: cache-first (offline accessible)
  if (url.pathname.endsWith('.json') || url.pathname.includes('/medical-standards/')) {
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

  // Feature documentation: network-first, fallback to cache
  if (url.pathname.includes('/docs/features/')) {
    event.respondWith(
      fetch(event.request).then((response) => {
        const cloned = response.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, cloned));
        return response;
      }).catch(() => {
        return caches.match(event.request);
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

  // HTML pages: network-first, fallback to cache, then to offline page
  if (event.request.mode === 'navigate') {
    event.respondWith((async () => {
      try {
        return await fetch(event.request);
      } catch (err) {
        return await caches.match(event.request) ||
               await caches.match('/OrionHealth/') ||
               await caches.match('/OrionHealth/offline.html');
      }
    })());
    return;
  }

  // Everything else: network-only
  event.respondWith(fetch(event.request).catch(() => {
    return caches.match(event.request);
  }));
});
