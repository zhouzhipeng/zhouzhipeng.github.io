importScripts("/assets/1550220011375/precache/precache-manifest.a8dbaa38595e515cfb2431a5dd23be5e.js", "https://storage.googleapis.com/workbox-cdn/releases/3.4.1/workbox-sw.js");

/* globals workbox */
/**
 * Workbox and precache manifest are injected at top
 * of this file by InjectManifest feature of workbox-webpack-plugin
 */

workbox.core.setCacheNameDetails({ precache: 'zety-precache' });

workbox.skipWaiting();
workbox.clientsClaim();

/**
 * The workboxSW.precacheAndRoute() method efficiently caches and responds to
 * requests for URLs in the manifest.
 * See https://goo.gl/S9QRab
 */
self.__precacheManifest = [].concat(self.__precacheManifest || []);
workbox.precaching.suppressWarnings();
workbox.precaching.precacheAndRoute(self.__precacheManifest, {
  directoryIndex: './',
});

/**
 * Precaching offline page
 */
workbox.precaching.precacheAndRoute([
  {
    url: '/offline.html',
    revision: Date.now(),
  },
]);

/**
 * Setting runtime caching strategy
 */
const networkFirstHandler = workbox.strategies.networkFirst({
  cacheName: 'zety-pages',
  plugins: [
    new workbox.expiration.Plugin({
      maxEntries: 200,
      maxAgeSeconds: 60 * 60 * 24, // Set cache max age to 24 hours - value in seconds
      purgeOnQuotaError: false,
    }),
    new workbox.cacheableResponse.Plugin({
      statuses: [200],
    }),
  ],
});

const customHandler = async(args) => {
  try {
    const response = await networkFirstHandler.handle(args);
    return response || await caches.match('/offline.html');
  } catch (error) {
    return await caches.match('/offline.html');
  }
};

workbox.routing.registerRoute(
  /zety./,
  customHandler
);

