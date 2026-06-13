import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'LocalCode',
  description: 'Apple Foundation Models for OpenCode - local, privacy-first AI CLI',
  srcDir: '.',
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