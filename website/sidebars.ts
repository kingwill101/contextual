import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    {
      type: 'category',
      label: 'Getting Started',
      collapsible: false,
      items: [
        'index',
        'getting-started',
        'usage',
        'next-steps',
      ],
    },
    {
      type: 'category',
      label: 'API',
      items: [
        'api/overview',
        {
          type: 'category',
          label: 'Drivers',
          items: [
            'api/drivers/configuration',
            'api/drivers/console',
            'api/drivers/daily-file',
            'api/drivers/webhook',
            'api/drivers/stack',
            'api/drivers/sampling',
          ],
        },
      ],
    },
    {
      type: 'category',
      label: 'Advanced',
      items: [
        'advanced/middleware',
        'advanced/batching-and-shutdown',
        'advanced/type-formatters',
        'advanced/shelf-integration',
      ],
    },
    {
      type: 'category',
      label: 'Migration',
      items: ['migration/v2'],
    },
  ],
};

export default sidebars;
