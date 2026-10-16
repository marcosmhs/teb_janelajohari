import { defineConfig } from 'astro/config';

// Landing estática: gera HTML puro em dist/, servido na raiz do Firebase
// Hosting. O app Flutter fica em /app/ (ver scripts/build-hosting.sh).
export default defineConfig({
  site: 'https://teb-janelajohari.web.app',
  output: 'static',
  build: { inlineStylesheets: 'always' },
});
