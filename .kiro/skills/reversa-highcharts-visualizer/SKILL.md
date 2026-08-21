---
name: reversa-highcharts-visualizer
description: Create interactive data visualizations with Highcharts.js, generating standalone HTML with animated, responsive and accessible charts from inline, CSV or JSON data.
disable-model-invocation: true
license: MIT
compatibility: Claude Code, Codex, Cursor, Gemini CLI and other agents compatible with Agent Skills.
metadata:
  author: sandeco
  version: "1.0.0"
  framework: reversa
  team: shared-skills
  role: charts-renderer
---

# Highcharts Visualizer

Create professional data visualizations using Highcharts.js. Always generates **standalone HTML**
(single file, self-contained) with interactive, animated, responsive and accessible graphics.

## Fluxo de Trabalho

### 1. Receive Data

Data can come from:

- **Inline in the conversation** → User pastes data, table, list of values
- **CSV/JSON sent** → Parse the content using `view_file` and inject the data directly into the generated HTML. Never create scripts in Python.
- **Excel Spreadsheet** → Extract data from tables and inject them into HTML. Don't use Python.
- **Example data** → When the user wants to explore a type of chart without real data
- **Data URL** → Use `web_fetch` to fetch remote data

### 2. Analyze the Data

Before generating the graph, understand the nature of the data:

- **Dimensions**: how many series? How many categories? Temporal or categorical?
- **Scale**: range of values, outliers, distribution
- **Relationships**: comparison, composition, distribution, trend, correlation
- **Volume**: few points (<100), medium (100-10K), large (>10K — use boost module)

Analyze the data internally after reading and inject the tags via string. Don't create intermediate Python programs.

### 3. Choose the Chart Type

See `references/CHART_CATALOG.md` for the complete catalog of 40+ chart types,
with guidance on when to use each one.

**Quick decision rule:**

| Objective | Recommended types |
|----------|-------------------|
| Trend over time | line, area, spline, areaspline |
| Comparison between categories | column, bar, lollipop, bullet |
| Composition/proportion | pie, donut, stacked column, stacked area, treemap, sunburst |
| Distribution | histogram, box plot, scatter, bell curve |
| Correlation | scatter, bubble, heatmap |
| Flow/process | sankey, dependency wheel, network graph |
| Hierarquia | treemap, sunburst, organization chart |
| Geographic | map (Highcharts Maps module) |
| Financeiro / timeline | stock chart (candlestick, OHLC, flags) |
| Progresso / KPI | gauge, solid gauge, activity gauge |
| Project / planning | gantt chart |
| Funnel/conversion | funnel, pyramid |

If the user did not specify the type, suggest 2-3 options that best represent the data.

### 4. Generate the Code

See `references/HIGHCHARTS_PATTERNS.md` for tested code patterns.

**Fundamental rules:**

1. **Standalone HTML**: single file `.html`. When run by the Reversa Docs Team, Highcharts comes from `assets/vendor/` (downloaded by Publisher via `vendor-pins.yaml`). When run alone, it accepts CDN as a fallback but the preferred path is local.
2. **Pinned version**: `highcharts@11.4.8`. Core and modules must be the same version.
3. **Modules on demand**: only include extra scripts when necessary (see modules table).
4. **Accessibility always**: always include `assets/vendor/highcharts-accessibility.js`.
5. **Exporting always**: always include `assets/vendor/highcharts-exporting.js`.
6. **Responsive**: the graphic must adapt to the container/viewport.
7. **Tema consistente**: aplicar cores coesas e tipografia profissional.
8. **Animation**: Enable entrance animations and smooth transitions.
9. **Rich tooltips**: formatted tooltips, with units and context.
10. **Large data**: for >10K points, include `modules/boost.js` (need to enter `vendor-pins.yaml`).
11. **No `fetch()` for local files**: data comes from `window.RV_DATA.metrics` (or `window.RV_DATA.timeline`), loaded by `assets/js/data.js`.

**Required modules per chart type (preference: local path in `assets/vendor/`):**

| Resource | Local (when run by the Docs team) | Fallback CDN |
|---------|--------------------------------------|--------------|
| Core (required) | `assets/vendor/highcharts.js` | `https://code.highcharts.com/11.4.8/highcharts.js` |
| Accessibility (required) | `assets/vendor/highcharts-accessibility.js` | `.../11.4.8/modules/accessibility.js` |
| Exporting (required) | `assets/vendor/highcharts-exporting.js` | `.../11.4.8/modules/exporting.js` |
| Treemap | `assets/vendor/highcharts-treemap.js` | `.../11.4.8/modules/treemap.js` |
| Sankey | `assets/vendor/highcharts-sankey.js` | `.../11.4.8/modules/sankey.js` |
| Timeline | `assets/vendor/highcharts-timeline.js` | `.../11.4.8/modules/timeline.js` |
| Others (Sunburst, Heatmap, Funnel, etc.) | add in `vendor-pins.yaml` before using | `.../11.4.8/modules/<modulo>.js` |
| Stock (candlestick, OHLC) | add in `vendor-pins.yaml` before using | `.../stock/11.4.8/highstock.js` |
| Maps | add in `vendor-pins.yaml` before using | `.../maps/11.4.8/highmaps.js` |
| Gantt | add in `vendor-pins.yaml` before using | `.../gantt/11.4.8/highcharts-gantt.js` |

> If a page needs a module that is **not yet** in `vendor-pins.yaml`, the correct path is:
> 1. Ask the Publisher to add the pin (commit to this skill or open issue), with primary URL + fallbacks.
> 2. Only then use the module.
> Pointing directly to the CDN on the final pages breaks the invariant "works via `file://` without internet".

All CDNs (fallback) in the format: `https://code.highcharts.com/11.4.8/{path}`.

### 5. Salvar e Entregar

Save the generated HTML directly to the destination folder using `write_to_file`. Always generate the pure HTML file with all data processed and injected into the `<script>` variables. Don't use Python snippets.

## Quality Guidelines

- **Professional aesthetics**: cohesive colors (use Highcharts or custom palettes), clean typography, adequate spacing
- **Formatted data**: numbers with thousands separators, localized dates, units on axes
- **Clear captions**: descriptive series names, position that does not obstruct the data
- **Rich interactivity**: hover highlights, contextual tooltips, zoom when applicable
- **Dark mode**: when appropriate, offer dark version with `backgroundColor: '#1a1a2e'`
- **Multiple graphics**: for dashboards, organize in a responsive CSS grid
- **Commented code**: comments in Portuguese explaining each section

## Tratamento de Erros

See `references/ERRORS.md` for error scenarios and solutions.
