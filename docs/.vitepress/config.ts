import { defineConfig, type DefaultTheme } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
import type MarkdownIt from 'markdown-it'
import { readFileSync, readdirSync, statSync } from 'node:fs'
import { join, relative, sep } from 'node:path'
import { fileURLToPath } from 'node:url'

// ---------------------------------------------------------------------------
// The Alloy docs/ wiki is authored in an Obsidian style: globally-unique
// filenames linked with [[slug]] / [[slug|Display]] wikilinks and grouped
// into sections by a `layer: section` frontmatter overview file per folder.
//
// We do NOT rewrite that content. Instead we teach VitePress to (a) resolve
// the wikilinks at render time and (b) build the sidebar from the folder
// structure and frontmatter. The source files stay the canonical spec.
// ---------------------------------------------------------------------------

const DOCS_ROOT = fileURLToPath(new URL('..', import.meta.url)) // -> docs/

interface PageMeta {
  /** Route VitePress will serve, base-relative, no extension. e.g. /vision/vision */
  route: string
  /** Frontmatter title, falling back to the slug. */
  title: string
  /** Frontmatter layer: home | section | leaf (or undefined). */
  layer?: string
  /** Folder the file lives in, relative to docs/. '' for the root. */
  folder: string
  /** Bare filename without extension. */
  slug: string
}

function listMarkdown(dir: string): string[] {
  const out: string[] = []
  for (const entry of readdirSync(dir)) {
    if (entry.startsWith('.')) continue // skip .vitepress
    const abs = join(dir, entry)
    if (statSync(abs).isDirectory()) out.push(...listMarkdown(abs))
    else if (entry.endsWith('.md')) out.push(abs)
  }
  return out
}

function frontmatter(abs: string): Record<string, string> {
  const text = readFileSync(abs, 'utf8')
  const block = text.match(/^---\r?\n([\s\S]*?)\r?\n---/)
  if (!block) return {}
  const fm: Record<string, string> = {}
  for (const line of block[1].split(/\r?\n/)) {
    const m = line.match(/^(\w+):\s*(.+)$/)
    if (m) fm[m[1]] = m[2].trim().replace(/^["']|["']$/g, '')
  }
  return fm
}

// Build the slug -> page metadata index once at config load.
const pages = new Map<string, PageMeta>()
for (const abs of listMarkdown(DOCS_ROOT)) {
  const rel = relative(DOCS_ROOT, abs).split(sep).join('/') // e.g. vision/vision.md
  const slug = rel.replace(/^.*\//, '').replace(/\.md$/, '')
  const route = rel === 'index.md' ? '/' : '/' + rel.replace(/\.md$/, '')
  const fm = frontmatter(abs)
  pages.set(slug, {
    route,
    title: fm.title || slug,
    layer: fm.layer,
    folder: rel.includes('/') ? rel.slice(0, rel.lastIndexOf('/')) : '',
    slug,
  })
}

// --- Wikilink markdown-it plugin -------------------------------------------
// Registered before the inline `link` rule. Code spans are tokenised by an
// earlier rule, so `[[slug]]` written inside backticks (the docs explain the
// syntax that way) is never seen here and stays literal — exactly right.
function wikilinks(md: MarkdownIt) {
  md.inline.ruler.before('link', 'wikilink', (state, silent) => {
    const src = state.src
    const start = state.pos
    if (src.charCodeAt(start) !== 0x5b || src.charCodeAt(start + 1) !== 0x5b) {
      return false // not '[['
    }
    const close = src.indexOf(']]', start + 2)
    if (close < 0) return false
    const inner = src.slice(start + 2, close)
    if (inner.includes('[') || inner.includes('\n')) return false

    const [target, label] = inner.split('|')
    const [rawSlug, hash] = target.split('#')
    const slug = rawSlug.trim()
    const page = pages.get(slug)
    const text = (label ?? page?.title ?? slug).trim()

    if (!silent) {
      if (page) {
        const href = page.route + (hash ? '#' + hash.trim().toLowerCase().replace(/\s+/g, '-') : '')
        const open = state.push('link_open', 'a', 1)
        open.attrSet('href', href)
        const t = state.push('text', '', 0)
        t.content = text
        state.push('link_close', 'a', -1)
      } else {
        // Unknown target: render the display text so the build never breaks.
        const t = state.push('text', '', 0)
        t.content = text
      }
    }
    state.pos = close + 2
    return true
  })
}

// --- Sidebar ----------------------------------------------------------------
// Section order follows docs/index.md (the home page's "Map of the territory").
const SECTION_ORDER = [
  'vision',
  'intent-model',
  'intent-capture',
  'ecosystem',
  'runtime-artifacts',
  'agent-formations',
  'integration',
  'feedback',
  'data-model',
  'interfaces',
  'workflows',
  'delivery',
  'reference',
]

function overviewOf(folder: string): PageMeta | undefined {
  const inFolder = [...pages.values()].filter((p) => p.folder === folder)
  // Prefer <folder>/<folder>.md, else the (first) `layer: section` file.
  return (
    inFolder.find((p) => p.slug === folder) ??
    inFolder.find((p) => p.layer === 'section')
  )
}

function sidebar(): DefaultTheme.SidebarItem[] {
  return SECTION_ORDER.map((folder) => {
    const inFolder = [...pages.values()].filter((p) => p.folder === folder)
    const overview = overviewOf(folder)
    const leaves = inFolder
      .filter((p) => p !== overview)
      .sort((a, b) => a.title.localeCompare(b.title))
    const items: DefaultTheme.SidebarItem[] = []
    if (overview) items.push({ text: 'Overview', link: overview.route })
    for (const leaf of leaves) items.push({ text: leaf.title, link: leaf.route })
    return {
      text: overview?.title ?? folder,
      collapsed: true,
      items,
    }
  })
}

// ---------------------------------------------------------------------------
export default withMermaid(
  defineConfig({
    title: 'Alloy',
    description: 'Engineering-intent management layer above Foundry, beside Epilogue Tracker.',
    base: '/alloy/',
    cleanUrls: true,
    lastUpdated: true,
    ignoreDeadLinks: false,

    markdown: {
      config: (md) => md.use(wikilinks),
    },

    themeConfig: {
      nav: [
        { text: 'Home', link: '/' },
        { text: 'Vision', link: '/vision/vision' },
        { text: 'Data Model', link: '/data-model/data-model' },
        { text: 'Delivery', link: '/delivery/delivery' },
      ],
      sidebar: sidebar(),
      outline: 'deep',
      search: { provider: 'local' },
      socialLinks: [{ icon: 'github', link: 'https://github.com/svetzal/alloy' }],
      footer: {
        message: 'Alloy owns meaning. Foundry owns execution.',
        copyright: 'Copyright © 2026 Mojility Inc. All rights reserved.',
      },
    },
  }),
)
