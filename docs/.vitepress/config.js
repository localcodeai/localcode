import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'LocalCode',
  description: 'Apple Foundation Models for OpenCode - local, privacy-first AI CLI',
  srcDir: '.',
  outDir: '../.vitepress/dist',
  base: '/localcode/',
  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/localcode/favicon.svg' }],
    ['meta', { name: 'theme-color', content: '#646cff' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'LocalCode - Apple Foundation Models for OpenCode' }],
    ['meta', { property: 'og:description', content: 'Turn natural language into CLI commands using Apple\'s on-device AI' }],
    ['meta', { property: 'og:url', content: 'https://localcodeai.github.io/localcode/' }],
    ['meta', { name: 'twitter:card', content: 'summary' }],
    ['meta', { name: 'twitter:title', content: 'LocalCode' }],
    ['meta', { name: 'twitter:description', content: 'Apple Foundation Models for OpenCode - local, privacy-first AI CLI' }],
    ['link', { rel: 'canonical', href: 'https://localcodeai.github.io/localcode/' }],
  ],
  themeConfig: {
    nav: [
      { text: 'Guide', link: '/' },
      { text: 'Installation', link: '/installation' },
      { text: 'Testing', link: '/testing' },
    ],
    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Introduction', link: '/' },
          { text: 'Installation', link: '/installation' },
          { text: 'Quick Start', link: '/quickstart' },
        ]
      },
      {
        text: 'Development',
        items: [
          { text: 'Testing', link: '/testing' },
          { text: 'Architecture', link: '/architecture' },
        ]
      }
    ]
  }
})