# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LobsterBoard is a self-hosted drag-and-drop dashboard builder with 50+ widgets, template gallery, custom pages system, and zero cloud dependencies. It runs as a single Node.js server with no build step for development (ES modules are available for distribution).

**Tech Stack:**
- Node.js (CommonJS for server, ES modules for distribution)
- Vanilla JavaScript (no frameworks)
- Server-Sent Events (SSE) for live system stats
- `systeminformation` package for system monitoring

**Works standalone or with OpenClaw** - optional OpenClaw widgets are available.

## Development Commands

```bash
# Start development server (local only)
node server.cjs

# Start development server (accessible from local network)
HOST=0.0.0.0 node server.cjs

# Build distribution (rollup)
npm run build

# Watch build
npm run build:watch
```

**Environment Variables:**
- `PORT` - Server port (default: 8080)
- `HOST` - Server host (default: 127.0.0.1, use 0.0.0.0 for network access)

## Architecture

### Core Files

**server.cjs** - Main HTTP server handling:
- Static file serving (app.html, css/, js/)
- Config load/save endpoints (`/config`)
- System stats streaming via SSE (`/api/stats/stream`)
- Template gallery API (`/api/templates/*`)
- Pages system auto-discovery and mounting (`/pages/*`, `/api/pages/*`)
- RSS/iCal proxy endpoints for widgets
- Todo/Notes persistence

**app.html** - Main dashboard builder UI

**js/builder.js** - Drag-drop editor logic:
- Canvas management (zoom, snap grid, scrollable mode)
- Widget selection, dragging, resizing
- Edit mode toggling (Ctrl+E)
- Config export/import
- Template export

**js/widgets.js** - Widget definitions (50+ widgets)
- Each widget defines: `name`, `icon`, `category`, `defaultWidth`, `defaultHeight`, `properties`, `preview`, `generateHtml()`, `generateJs()`
- Shared SSE connection for system stats widgets
- Helper functions: `_formatBytes()`, `_formatBytesPerSec()`, `_formatUptime()`

**js/templates.js** - Template gallery system (import/export/share layouts)

### Pages System

Custom pages are auto-discovered from `pages/` directory. Each page has:

```
pages/my-page/
├── page.json       # Metadata (id, title, icon, order, enabled, nav)
├── index.html      # Page UI
├── api.cjs         # Optional server-side API routes (must use .cjs)
└── style.css       # Optional additional styles
```

**page.json schema:**
- `id` - URL slug (must match folder name)
- `title` - Display name
- `icon` - Emoji icon
- `order` - Sort position (lower = first)
- `enabled` - Active state
- `nav` - Show in navigation (default: true)
- `standalone` - Works without OpenClaw

**API Format (api.cjs):**
```js
module.exports = function(ctx) {
  // ctx.dataDir - absolute path to data/<page-id>/
  // ctx.readData(filename) - read JSON from data dir
  // ctx.writeData(filename, obj) - write JSON to data dir

  return {
    routes: {
      'GET /': (req, res, { query, body, params }) => {
        return { items: [] }; // Auto JSON response
      }
    }
  };
};
```

**Pages Configuration:** `pages.json` overrides individual page settings:
```json
{
  "pages": {
    "my-page": { "enabled": true, "order": 50 }
  }
}
```

### Templates System

Templates live in `templates/<template-id>/`:
- `config.json` - Widget layout
- `meta.json` - Template metadata (id, name, description, author, tags, canvasSize, widgetCount, widgetTypes, requiresSetup, preview)
- `preview.png` - Screenshot preview

**templates/templates.json** - Template index registry

### Configuration

**config.json** - Main dashboard layout:
- `canvas` - `{ width, height }` or `{ width, height: "auto" }` for scrollable
- `fontScale` - Global font scaling
- `widgets[]` - Array of widget objects with `id`, `type`, `x`, `y`, `width`, `height`, `properties`

### Widget Categories

Widgets are organized by category in the WIDGETS object:
- System Monitoring (cpu-memory, disk-usage, network-speed, docker-containers, uptime-monitor)
- Weather (weather, weather-multi)
- Time & Productivity (clock, world-clock, countdown, todo-list, pomodoro, notes)
- Media & Content (rss-ticker, calendar, now-playing, quote-of-day, quick-links)
- AI/LLM Monitoring (ai-usage-claude, ai-cost-tracker, api-status, active-sessions, token-gauge)
- Finance (stock-ticker, crypto-price)
- Smart Home (indoor-climate, camera-feed, power-usage)
- Utility (auth-status, sleep-score, github-stats, unread-emails, system-log, activity-list, cron-jobs, releases)
- Layout (text-header, horizontal-line, vertical-line, pages-menu)
- Embeds (image variants, iframe-embed)

## Widget Development Pattern

When adding a new widget, define it in `js/widgets.js` (and `src/widgets.js` for distribution):

```javascript
'widget-type': {
  name: 'Widget Name',
  icon: '🔧',
  category: 'small', // or 'medium', 'large'
  description: 'What it does',
  defaultWidth: 200,
  defaultHeight: 120,
  hasApiKey: false, // or true if requires API key
  properties: {
    title: 'Default Title',
    refreshInterval: 300,
    // ... other properties
  },
  preview: `<div>Preview HTML</div>`,
  generateHtml: (props) => `HTML template with ${props.id} placeholders`,
  generateJs: (props) => `JavaScript code to update widget-${props.id}`
}
```

## Data Persistence

- **config.json** - Dashboard layout (auto-saved)
- **data/<page-id>/** - Page-specific data files
- **data/todos.json** - Todo list data
- **data/notes.json** - Notes widget data

## Important Notes

- Server uses CommonJS (`.cjs`), but package.json has `"type": "module"` for distribution builds
- Pages API files **must use .cjs extension** due to package.json module type
- All widget scripts execute in global scope (use `new Function()`)
- Edit mode is toggled via **Ctrl+E** keyboard shortcut
- Canvas can be fixed height or scrollable (`height: "auto"`)
- System stats use shared SSE connection to avoid multiple connections
- Template screenshots are captured via html2canvas when exporting

## Testing Changes

After editing server-side code, restart the server. For client-side changes, hard refresh the browser (Ctrl+Shift+R). The edit mode (Ctrl+E) provides live preview of widget changes.
