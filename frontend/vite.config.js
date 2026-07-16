import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// In production the bundled static files are served by nginx, which proxies
// /api to the backend container. The `server.proxy` block is only for local
// `npm run dev` convenience.
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': 'http://localhost:5000',
    },
  },
  build: {
    outDir: 'dist',
  },
})
