# Contextual Documentation

[![docs.page](https://img.shields.io/badge/docs-docs.page-blue.svg)](https://docs.page/kingwill101/contextual)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.9.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow.svg)](https://www.buymeacoffee.com/kingwill101)

This documentation is built using [docs.page](https://docs.page), a modern documentation platform that uses your GitHub repository as the source of truth.

## Setup

The documentation is configured in the `docs/` directory with:

- `docs.json` - Configuration file for docs.page
- `index.mdx` - Homepage content
- Various `.md` and `.mdx` files for documentation pages

## Configuration

The `docs.json` file contains:
- Project metadata (name, description)
- Sidebar navigation structure
- Theme and layout settings

## Local Development

### Using docs.page CLI

Install the docs.page CLI globally:

```bash
npm install -g @docs.page/cli
```

Check for issues:

```bash
docs.page check
```

### Manual Preview

Since docs.page uses your repository directly, you can preview changes by:

1. Committing and pushing to your repository
2. Viewing the live documentation at the configured docs.page URL

### Local Previewing

For faster iteration during development, you can preview your documentation locally using a static server:

```bash
# Install a simple HTTP server (if not already installed)
npm install -g http-server

# Serve the docs directory
cd docs
http-server -p 3000
```

Then visit `http://localhost:3000` to preview your documentation. Note that this will only show the raw Markdown files, not the full docs.page rendering.

Alternatively, use the docs.page CLI for a more accurate preview:

```bash
# Using npx (no global install needed)
npx @docs.page/cli preview

# Or if installed globally
docs.page preview
```

## Validation

Before publishing, validate your documentation:

```bash
# Install dependencies
npm install

# Check for broken links and other issues
npm run check

# Preview locally
npm run preview

# Run full validation
npm run validate
```

Alternatively, using the CLI directly:

```bash
# Install docs.page CLI globally
npm install -g @docs.page/cli

# Check for broken links and other issues
docs.page check

# Preview locally
docs.page preview
```

## Writing Content

- Use `.mdx` for pages that need components
- Use `.md` for standard Markdown pages
- Frontmatter supports title, description, and other metadata
- MDX components are available for enhanced content

## Navigation

Navigation is configured in `docs.json` under the `sidebar` key:
- Groups organize related pages
- Nested pages create expandable sections
- Links must include file extensions (`.md`, `.mdx`)

## Components

docs.page supports MDX components for enhanced content:
- `<Info>`, `<Warning>`, `<Error>` for callouts
- `<CodeGroup>` for tabbed code examples
- `<Steps>` for step-by-step guides
- And many more

## Publishing

Documentation is automatically published when you push to the main branch of your repository. The live site is available at: `https://docs.page/{username}/{repository}`

## Contributing

When contributing to documentation:
1. Follow the existing structure in `docs.json`
2. Use proper frontmatter in page files
3. Test links and ensure they work
4. Run `docs.page check` to validate

For more information, see the [docs.page documentation](https://docs.page).
