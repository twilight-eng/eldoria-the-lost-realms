#!/usr/bin/env bash
set -euo pipefail
: "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL}"
: "${CAPTURE_DIR:?Set CAPTURE_DIR to the evidence output directory}"
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"

/usr/bin/time -p node <<'NODE'
const fs = require('node:fs');
const path = require('node:path');
const { createRequire } = require('node:module');
const runtime = path.join(process.env.HOME, '.local/share/omgithub-playwright');
const runtimeRequire = createRequire(path.join(runtime, 'package.json'));
const { chromium } = runtimeRequire('playwright');
const config = JSON.parse(fs.readFileSync(path.join(runtime, process.platform === 'darwin' ? 'metal.json' : 'linux.json'), 'utf8'));
if (process.platform === 'linux') process.env.DISPLAY ||= ':' + fs.readFileSync(path.join(runtime, 'display'), 'utf8').trim();

(async () => {
  let browser;
  let exitCode = 0;
  try {
    browser = await chromium.launch({ ...config.browser.launchOptions, timeout: 30000 }).catch(error => { error.exitCode = 75; throw error; });
    for (const [label, width, height] of [['desktop', 1440, 900], ['mobile', 390, 844]]) {
      const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 1 }).catch(error => { error.exitCode = 75; throw error; });
      const defects = [];
      page.on('pageerror', error => defects.push(error.message));
      page.on('response', response => {
        const responseUrl = new URL(response.url());
        if (response.status() >= 400 && responseUrl.origin === new URL(process.env.CAPTURE_URL).origin && responseUrl.pathname !== '/favicon.ico') defects.push(`HTTP ${response.status()}: ${responseUrl.pathname}`);
      });
      page.on('requestfailed', request => { if (new URL(request.url()).origin === new URL(process.env.CAPTURE_URL).origin) defects.push(`Request failed: ${request.url()}`); });
      const response = await page.goto(process.env.CAPTURE_URL, { waitUntil: 'load', timeout: 45000 }).catch(error => { error.exitCode = 75; throw error; });
      if (!response || !response.ok()) {
        const error = new Error(`Navigation returned HTTP ${response?.status() ?? 'no response'}`);
        error.exitCode = !response || [408, 429, 500, 502, 503, 504].includes(response.status()) ? 75 : 1;
        throw error;
      }
      await page.locator('#game').waitFor({ state: 'visible', timeout: 30000 });
      // A canvas is only appended once the Three.js scene initialized successfully.
      await page.locator('#scene canvas').waitFor({ state: 'visible', timeout: 45000 }).catch(error => { error.exitCode = 1; throw new Error(`Game did not render a WebGL canvas: ${error.message}`); });
      await page.waitForTimeout(1500);
      if (defects.length) throw new Error(`${label} render errors: ${defects.join(' | ')}`);
      await page.screenshot({ path: path.join(process.env.CAPTURE_DIR, `final-${label}.png`), timeout: 30000 }).catch(error => { error.exitCode = 75; throw error; });
      console.log(`Captured ${label}: ${width}x${height}`);
      await page.close();
    }
  } catch (error) {
    console.error(error);
    exitCode = error.exitCode || 1;
  } finally {
    if (browser) await browser.close().catch(error => { console.error(error); exitCode ||= 75; });
  }
  process.exitCode = exitCode;
})();
NODE
