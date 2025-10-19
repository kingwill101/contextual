import { themes as prismThemes } from 'prism-react-renderer';
import type { Config } from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Contextual',
  tagline: 'Structured, typed, ergonomic logging for Dart',
  favicon: 'img/favicon.ico',
  future: {
    v4: true,
  },
  url: 'https://kingwill101.github.io',
  baseUrl: '/contextual/',
  organizationName: 'kingwill101',
  projectName: 'contextual',
  onBrokenLinks: 'throw',
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },
  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          editUrl: 'https://github.com/kingwill101/contextual/edit/main/website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],
  themeConfig: {
    image: 'img/social-card.png',
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Contextual',
      logo: {
        alt: 'Contextual logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          href: 'https://pub.dev/packages/contextual',
          label: 'Pub.dev',
          position: 'right',
        },
        {
          href: 'https://github.com/kingwill101/contextual',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            { label: 'Getting Started', to: '/' },
            { label: 'API Overview', to: '/api/overview' },
            { label: 'Type Formatters', to: '/advanced/type-formatters' },
          ],
        },
        {
          title: 'Community',
          items: [
            { label: 'Pub.dev', href: 'https://pub.dev/packages/contextual' },
            { label: 'GitHub Issues', href: 'https://github.com/kingwill101/contextual/issues' },
          ],
        },
        {
          title: 'More',
          items: [
            { label: 'Contextual Shelf', href: 'https://pub.dev/packages/contextual_shelf' },
            { label: 'Buy Me a Coffee', href: 'https://www.buymeacoffee.com/kingwill101' },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Contextual contributors. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
