# Highcharts Chart Catalog

Complete reference of 40+ chart types with usage guidance and example options.

---

## 1. Line & Spline

**When to use:** Trends over time, time series, evolution of metrics.

**Variantes:** `line`, `spline` (curvas suaves), `step` (degraus)

```javascript
{
    chart: { type: 'line' },
    title: { text: 'Chart Title' },
    xAxis: { categories: ['Jan','Fev','Mar','Abr','Mai','Jun'] },
    yAxis: { title: { text: 'Valores' } },
    plotOptions: {
        line: {
            dataLabels: { enabled: true },
            enableMouseTracking: true
        }
    },
    series: [{
        name: 'Series A',
        data: [7, 6.9, 9.5, 14.5, 18.2, 21.5]
    }]
}
```

---

## 2. Area & Areaspline

**When to use:** Trends with volume/magnitude, composition over time (stacked).

**Variantes:** `area`, `areaspline`, `arearange`, `areasplinerange`

```javascript
{
    chart: { type: 'areaspline' },
    plotOptions: {
        areaspline: {
            fillOpacity: 0.3,
            marker: { enabled: false }
        }
    },
    series: [{ name: 'Series', data: [...] }]
}
```

**Stacked area** for composition:
```javascript
plotOptions: {
    area: {
        stacking: 'normal', // or 'percent' for 100%
        lineWidth: 1,
        marker: { enabled: false }
    }
}
```

---

## 3. Column & Bar

**When to use:** Comparison between discrete categories. Column = vertical, Bar = horizontal.

**Variantes:** `column`, `bar`, `columnrange`, `columnpyramid`

```javascript
{
    chart: { type: 'column' },
    xAxis: { categories: ['A', 'B', 'C', 'D'] },
    plotOptions: {
        column: {
            borderRadius: 5,
            dataLabels: { enabled: true }
        }
    },
    series: [
{ name: 'Series 1', date: [49, 71, 106, 129] },
{ name: 'Series 2', date: [83, 78, 98, 93] }
    ]
}
```

**Stacked / Grouped / Percent:**
```javascript
plotOptions: {
    column: {
        stacking: 'normal', // 'percent' to 100%
        groupPadding: 0.1,
        pointPadding: 0.05
    }
}
```

---

## 4. Pie & Donut

**When to use:** Composition of a whole, proportions, market share. Maximum 7-8 slices.

```javascript
{
    chart: { type: 'pie' },
    plotOptions: {
        pie: {
            allowPointSelect: true,
            cursor: 'pointer',
            dataLabels: {
                enabled: true,
                format: '<b>{point.name}</b>: {point.percentage:.1f}%'
            },
            showInLegend: true
        }
    },
    series: [{
        name: 'Participation',
        colorByPoint: true,
        data: [
            { name: 'Item A', y: 45 },
            { name: 'Item B', y: 26.8 },
            { name: 'Item C', y: 12.8, sliced: true, selected: true },
            { name: 'Outros', y: 15.4 }
        ]
    }]
}
```

**Donut** (pie with innerSize):
```javascript
plotOptions: { pie: { innerSize: '60%' } }
```

**Semi-circle donut:**
```javascript
plotOptions: {
    pie: {
        innerSize: '50%',
        startAngle: -90,
        endAngle: 90,
        center: ['50%', '75%']
    }
}
```

---

## 5. Scatter & Bubble

**When to use:** Correlation between two variables (scatter), three variables (bubble).

**Requires:** `highcharts-more.js` for bubble.

```javascript
// Scatter
{ chart: { type: 'scatter' },
  xAxis: { title: { text: 'Variable X' } },
  yAxis: { title: { text: 'Variable Y' } },
  series: [{ data: [[1,2],[3,4],[5,1],[7,8]] }]
}

// Bubble
{ chart: { type: 'bubble' },
  series: [{ data: [[9,81,63],[98,5,89],[51,50,73]] }] // [x, y, z]
}
```

---

## 6. Heatmap

**When to use:** Value matrix, two-dimensional patterns, activity calendars.

**Requires:** `modules/heatmap.js`

```javascript
{
    chart: { type: 'heatmap' },
    colorAxis: {
        min: 0,
        minColor: '#FFFFFF',
        maxColor: '#c4463a'
    },
    series: [{
        borderWidth: 1,
        data: [[0,0,10],[0,1,19],[1,0,92],[1,1,58]], // [x, y, value]
        dataLabels: { enabled: true, color: '#000' }
    }]
}
```

---

## 7. Treemap & Sunburst

**When to use:** Hierarchies, proportion within categories, budgets.

**Requires:** `modules/treemap.js`, `modules/sunburst.js`

```javascript
// Treemap
{
    chart: { type: 'treemap' },
    series: [{
        layoutAlgorithm: 'squarified',
        data: [
            { name: 'A', value: 6, colorValue: 1 },
            { name: 'B', value: 3, colorValue: 2 },
            { name: 'C', value: 4, colorValue: 3 }
        ]
    }]
}

// Sunburst (hierarchical with parent/id)
{
    chart: { type: 'sunburst' },
    series: [{
        data: [
            { id: '0', name: 'Root' },
            { id: '1', parent: '0', name: 'Filho A', value: 5 },
            { id: '2', parent: '0', name: 'Filho B', value: 3 }
        ]
    }]
}
```

---

## 8. Gauge & Solid Gauge

**When to use:** KPIs, progress, status indicators, speedometers.

**Requires:** `highcharts-more.js`, `modules/solid-gauge.js`

```javascript
// Solid Gauge (estilo moderno)
{
    chart: { type: 'solidgauge' },
    pane: {
        startAngle: -90, endAngle: 90,
        background: {
            backgroundColor: '#EEE',
            innerRadius: '60%', outerRadius: '100%',
            shape: 'arc'
        }
    },
    yAxis: { min: 0, max: 100, stops: [
        [0.1, '#55BF3B'], [0.5, '#DDDF0D'], [0.9, '#DF5353']
    ]},
    series: [{ name: 'Progresso', data: [73], innerRadius: '60%' }]
}
```

---

## 9. Sankey & Dependency Wheel

**When to use:** Flows, transfers, relationships between entities.

**Requires:** `modules/sankey.js`, `modules/dependency-wheel.js`

```javascript
// Sankey
{
    chart: { type: 'sankey' },
    series: [{
        keys: ['from', 'to', 'weight'],
        data: [
            ['Brasil', 'EUA', 5], ['Brasil', 'Europa', 3],
['EUA', 'Asia', 2], ['Europe', 'Asia', 1]
        ]
    }]
}
```

---

## 10. Funnel & Pyramid

**When to use:** Conversion funnels, lossy sequential processes.

**Requires:** `modules/funnel.js`

```javascript
{
    chart: { type: 'funnel' },
    plotOptions: { funnel: { neckWidth: '30%', neckHeight: '25%' } },
    series: [{
        data: [
            ['Visitantes', 15654], ['Downloads', 4064],
['Signup', 1987], ['Purchase', 976], ['Renovation', 846]
        ]
    }]
}
```

---

## 11. Wordcloud

**When to use:** Frequency of words, tags, popular terms.

**Requires:** `modules/wordcloud.js`

```javascript
{
    chart: { type: 'wordcloud' },
    series: [{
        data: [
            { name: 'JavaScript', weight: 15 },
            { name: 'Python', weight: 12 },
            { name: 'React', weight: 8 }
        ]
    }]
}
```

---

## 12. Network Graph

**When to use:** Relationships between entities, graphs, social networks.

**Requires:** `modules/networkgraph.js`

```javascript
{
    chart: { type: 'networkgraph' },
    plotOptions: {
        networkgraph: {
            layoutAlgorithm: { enableSimulation: true },
            keys: ['from', 'to']
        }
    },
    series: [{
        data: [['A','B'],['B','C'],['C','D'],['D','A'],['B','D']]
    }]
}
```

---

## 13. Box Plot & Histogram

**When to use:** Statistical distribution, quartiles, outliers.

**Requires:** `highcharts-more.js`, `modules/histogram-bellcurve.js`

```javascript
// Box Plot
{
    chart: { type: 'boxplot' },
    series: [{
        data: [
            [760, 801, 848, 895, 965], // [low, q1, median, q3, high]
            [733, 853, 939, 980, 1080]
        ]
    }]
}
```

---

## 14. Stock Charts (Highstock)

**When to use:** Financial data, time series with range selector, navigator.

**Requires:** `stock/highstock.js` (replaces highcharts.js)

```javascript
Highcharts.stockChart('container', {
    rangeSelector: { selected: 1 },
    series: [{
        name: 'AAPL',
        data: [[Date.UTC(2024,0,1), 150], [Date.UTC(2024,0,2), 152], ...],
        tooltip: { valueDecimals: 2 }
    }]
});
```

---

## 15. Maps (Highmaps)

**When to use:** Geographic data, choropleth maps.

**Requires:** `maps/highmaps.js` (replaces highcharts.js) + GeoJSON map

---

## 16. Gantt Chart

**When to use:** Planning, schedules, project management.

**Requires:** `gantt/highcharts-gantt.js` (replaces highcharts.js)

---

## 17. Outros Tipos

- **Lollipop**: `modules/lollipop.js` — bars with dot at the end
- **Dumbbell**: `modules/dumbbell.js` — before/after, range between two points
- **Timeline**: `modules/timeline.js` — events over time
- **Venn**: `modules/venn.js` — diagramas de Venn
- **Waterfall**: type `waterfall` — value decomposition
- **Polar / Spider**: using `chart: { polar: true }` — multidimensional comparison
- **3D Charts**: using `highcharts-3d.js` — 3D versions of column, pie, scatter

---

## Combining Graphics (Dual Axis / Mixed)

```javascript
{
    yAxis: [
        { title: { text: 'Receita (R$)' } },
        { title: { text: 'Unidades' }, opposite: true }
    ],
    series: [
        { type: 'column', name: 'Unidades', data: [...], yAxis: 1 },
        { type: 'spline', name: 'Receita', data: [...], yAxis: 0 }
    ]
}
```

## Drilldown

**Requires:** `modules/drilldown.js`

```javascript
{
    series: [{
        name: 'Categorias',
        data: [
            { name: 'Frutas', y: 55, drilldown: 'frutas' },
            { name: 'Vegetais', y: 25, drilldown: 'vegetais' }
        ]
    }],
    drilldown: {
        series: [
{ id: 'fruits', date: [['Apple',30],['Banana',15],['Orange',10]] },
            { id: 'vegetais', data: [['Cenoura',10],['Tomate',8],['Alface',7]] }
        ]
    }
}
```
