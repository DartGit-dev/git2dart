# Tratamento de Erros — Highcharts Visualizer

## Insufficient or empty data

**Symptom:** Chart renders empty or with message "No data to display".

**Action:** Configure `noData` module or check the data before creating the chart:
```javascript
// Include: modules/no-data-to-display.js
lang: { noData: 'No data available to display' },
noData: { style: { fontWeight: 'bold', fontSize: '16px', color: '#666' } }
```

Warn the user:
> "The data provided appears to be empty or not processed correctly. Could you check?"

## Incompatible data format

**Symptom:** Console or graph error with NaN/undefined values.

**Action:** Validate data with `scripts/parse_data.py` before embedding. The script automatically converts
numeric strings ("1234.56" → 1234.56) and dates in multiple formats.

## CDN module does not load

**Symptom:** "Highcharts is not defined" error or unrecognized chart type.

**Action:** Check order of scripts. The `highcharts.js` core must come first, then the modules.
For Stock/Maps/Gantt, use the respective main script (highstock.js, highmaps.js, highcharts-gantt.js)
**in place of** highcharts.js, not alongside.

Ordem correta:
```html
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/highcharts-more.js"></script>
<script src="https://code.highcharts.com/modules/solid-gauge.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>
<script src="https://code.highcharts.com/modules/accessibility.js"></script>
```

## Non-responsive graph

**Symptom:** Graphic does not resize with the window, or is cut off.

**Action:** Do not set fixed `chart.width`. Use containers with responsive CSS.
Ensure that `chart.reflow` is not disabled.

```javascript
chart: {
// DO NOT set fixed width/height
// Let Highcharts adapt to the container
    reflow: true
}
```

## Slow performance with lots of data

**Symptom:** Graphic freezing or taking a long time to render with >10,000 points.

**Action:**
1. Include `modules/boost.js`
2. Set `boostThreshold: 5000` in the series
3. Disable animations: `plotOptions: { series: { animation: false } }`
4. Desabilitar markers: `marker: { enabled: false }`
5. Consider aggregating data (downsampling) via `scripts/analyze_data.py`

## Tooltips with incorrect values

**Symptom:** Tooltip shows "undefined" or wrong format.

**Action:** Verify that the data is in the correct format for the chart type.
Use custom `tooltip.formatter` to have full control over the format.

## Unreadable colors

**Symptom:** Series or labels with insufficient contrast.

**Action:** Use `Highcharts.getOptions().colors` to check the active palette.
For dark mode, ensure that labels/grid/tick have light colors.
The accessibility module alerts you to contrast issues.

## CSV with different encoding (UTF-8 BOM, Latin1)

**Symptom:** Special characters (accents) appear as "�" or "é".

**Action:** `scripts/parse_data.py` attempts to detect encoding automatically.
If it fails, force encoding:
```bash
python scripts/parse_data.py data.csv --encoding latin1
```

## Excel file with multiple tabs

**Symptom:** Extracted data is from the wrong tab.

**Action:**
```bash
python scripts/parse_data.py data.xlsx --sheet "Sheet2"
```
