import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import assert from 'assert';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const html = fs.readFileSync(path.join(root, 'docs/index.html'), 'utf8');
const start = html.indexOf('const VIEW_MIN_ZOOM_FLOOR');
const end = html.indexOf('function slugFilename');
assert.ok(start >= 0 && end > start, 'zoom helpers missing from docs/index.html');
const src = html.slice(start, end);
const api = new Function(`${src}\nreturn {VIEW_MIN_ZOOM_FLOOR,VIEW_MIN_ZOOM_CAP,VIEW_MAX_FIT_ZOOM,fitZoomNeeded,unlockMinZoomForFit,fitGraph};`)();

function mockCy({w, h, bb, minZ = 0.01}) {
  let minZoom = minZ;
  let zoom = 1;
  const cy = {
    width: () => w,
    height: () => h,
    elements: () => ({length: 1, boundingBox: () => bb}),
    resize() {},
    destroyed: () => false,
    minZoom(v) { if (v === undefined) return minZoom; minZoom = v; },
    zoom(v) {
      if (v === undefined) return zoom;
      if (typeof v === 'number') zoom = v;
      else if (v && typeof v.level === 'number') zoom = v.level;
      if (zoom < minZoom) zoom = minZoom;
      return zoom;
    },
    fit(pad) {
      const z = Math.min((w - 2 * pad) / bb.w, (h - 2 * pad) / bb.h);
      cy.zoom(z);
    },
    center() {},
  };
  return cy;
}

const massive = mockCy({w: 1200, h: 800, bb: {w: 260150, h: 260150}});
api.unlockMinZoomForFit(massive, 60);
assert.ok(massive.minZoom() < 0.01, `minZoom still ${massive.minZoom()} after unlock`);
api.fitGraph(massive, 60);
assert.ok(massive.zoom() < 0.01, `fit zoom ${massive.zoom()} still clamped to old 0.01 floor`);
assert.ok(massive.zoom() > massive.minZoom(), 'fit should sit above the 0.2x headroom floor');
const before = massive.zoom();
massive.zoom(before * 0.8);
assert.ok(massive.zoom() < before, 'zoom-out must not be a no-op after a massive-model fit');

const tiny = mockCy({w: 1200, h: 800, bb: {w: 200, h: 200}});
api.fitGraph(tiny, 60);
assert.ok(tiny.zoom() <= api.VIEW_MAX_FIT_ZOOM + 1e-9, 'small graphs must still cap at VIEW_MAX_FIT_ZOOM');
assert.equal(tiny.minZoom(), api.VIEW_MIN_ZOOM_CAP);

assert.equal((html.match(/minZoom:0\.01/g) || []).length, 0, 'docs still hardcodes minZoom:0.01');
assert.ok(html.includes('Download PNG'), 'canvas PNG button missing');
assert.ok(html.includes('downloadCanvasPng'), 'downloadCanvasPng missing');
assert.ok(html.includes('takeViewport();zoomAboutCenter'), 'toolbar zoom must take over the viewport');

console.log('ok', {
  massiveMinZoom: massive.minZoom(),
  massiveFitZoom: massive.zoom(),
  tinyFitZoom: tiny.zoom(),
});
