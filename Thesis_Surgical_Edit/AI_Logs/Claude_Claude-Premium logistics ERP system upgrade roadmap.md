# Premium logistics ERP system upgrade roadmap

**Created:** 4/4/2026 3:54:40  
**Updated:** 4/4/2026 3:57:53  
**Exported:** 4/4/2026 4:09:06  
**Link:** [https://claude.ai/chat/f56f3988-6350-490c-8756-ea131714a55a](https://claude.ai/chat/f56f3988-6350-490c-8756-ea131714a55a)  

## Response:
4/4/2026, 3:57:53 AM



````plaintext
Thought process: Architected comprehensive ERP audit across print engineering, UX polish, analytics, and offline AI features.

The user wants a comprehensive audit and roadmap for their ERP system. They've shared 12 screenshots and a PDF export. Let me analyze what I see and provide actionable code and advice across the 4 pillars.

From the PDF (d2.pdf): It shows a BR (Bon de Réception) for ART-011 (Fax Paper Roll), qty 1, DA 400. It has buttons visible ("Confirmer", "Print PDF", "Close") - this is the problem. The layout is too spread out for an administrative form.

From the screenshots:
- Dashboard: clean RTL layout, 4 KPI cards, table with status badges


- Items list, BR/BS forms with step-numbered UX, DA module approval workflow, Wilson EOQ parameter inputs, ABC three-class breakdown, timestamped audit log, accordion guide sections, and user settings with institution info.

The core issues with the PDF are that interactive buttons shouldn't print, there's excessive whitespace, and it doesn't match official Algerian administrative form standards. I need to write CSS that hides UI elements during print, optimizes spacing, and applies proper formatting for official documents.

Writing print styles... all UI chrome (sidebar, titlebar, btn-bar, modal overlay backdrop)
- Shows only the modal-box content
- Formats it as a compact A5 or half-A4 form
- Monochrome, tight borders
- Two receipts per A4 page

**Pillar 2: UX Polish**

Looking at the screenshots:
- The step-numbered flow (1-6) in BR/BS forms is excellent
- Stock indicator colors are good
- Could add input masking for ref numbers
- Could add smooth transitions

**Pillar 3: ABC & Wilson Visualization**

Lightweight JS charting without external libraries - pure SVG/Canvas charts.

**Pillar 4: AI-like features**

Offline predictive features:
- Consumption velocity calculation
- Fuzzy search (Levenshtein distance)
- Auto-categorization

Now I'm working on the print CSS. The issue is that when `window.print()` opens a new window with the modal content, the buttons are still showing up. I need to refine the print function to strip out those interactive elements and only display the receipt data itself.

Writing print styles... Writing print styles...

For the AI features, I'm thinking through how to implement consumption velocity by analyzing the movements array to calculate daily usage rates and predict stockout dates, fuzzy search using Levenshtein distance for article matching, and keyword-based auto-categorization. The user wants four concrete pillars with actual code, so I should focus on delivering quality implementations rather than trying to cover everything.

Looking at the PDF structure, the `printBon()` function opens a new window and copies the modal's innerHTML, which includes the modal buttons that shouldn't print. I can fix this either by hiding those buttons with CSS in the print window or by stripping them from the HTML before copying. I'll show both approaches along with a refactored print function.

For the two-per-A4 layout, each bon needs to be around 135mm tall to fit properly on an A4 page with margins, which is definitely doable with the right CSS page-break rules.
````

## ERP_Academie v12 — Audit & Optimization Roadmap

I've reviewed all 12 screenshots and the `d2.pdf` sample. The diagnostic is clear: the UX logic is solid, the data architecture is correct, and the three critical weaknesses are the print output, a few UX friction points, and the absence of predictive intelligence. Here is the full roadmap with production-ready code.

---

## Pillar 1 — Print Document Engineering (The PDF Fix)

**Diagnosis from `d2.pdf`:** Three problems.
1. Buttons ("Confirmer", "Print PDF", "Close") are rendering because `modal.innerHTML` copies them verbatim into the print window.
2. The form occupies a full A4 page for a single line item — wasteful and unprofessional.
3. No "ORIGINAL / COPIE" watermark distinction.

**Solution: Replace `printBon()` entirely** and add proper CSS. The new function surgically extracts only the data, not the UI chrome, and generates a compact half-A4 bon so two fit per printed sheet.

```javascript
// REPLACE your existing printBon() function with this:
function printBon() {
  const modal = document.querySelector('.modal-box');
  if (!modal) return;

  // Extract only the data nodes, not buttons
  const title = modal.querySelector('.modal-title')?.innerHTML || '';
  const header = modal.querySelector('.bon-header')?.innerHTML || '';
  const table = modal.querySelector('.bon-table')?.outerHTML || '';
  const sig = modal.querySelector('.bon-sig')?.outerHTML || '';

  const isIN = title.includes('BR') || title.includes('استلام') || title.includes('Réception');
  const docCode = isIN ? 'BR' : 'BS';

  const printHTML = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<title>${docCode}</title>
<style>
  /* ── RESET ── */
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    font-family: 'Traditional Arabic', 'Arial', Tahoma, sans-serif;
    font-size: 9.5pt;
    color: #000;
    background: white;
    direction: rtl;
  }

  /* ── BON WRAPPER — Half A4 so 2 fit per sheet ── */
  .bon {
    width: 180mm;
    min-height: 128mm;
    max-height: 134mm;
    padding: 5mm 6mm;
    border: 1.5pt solid #000;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    page-break-inside: avoid;
  }

  /* ── HEADER ── */
  .bon-state {
    text-align: center;
    font-size: 8pt;
    font-weight: 700;
    letter-spacing: 0.3pt;
    border-bottom: 0.5pt solid #000;
    padding-bottom: 2mm;
    margin-bottom: 2mm;
  }
  .bon-state small {
    display: block;
    font-weight: 400;
    font-size: 7.5pt;
  }
  .bon-meta {
    display: flex;
    justify-content: space-between;
    font-size: 8pt;
    font-weight: 700;
    margin-bottom: 2mm;
    border-bottom: 0.5pt dashed #666;
    padding-bottom: 1.5mm;
  }

  /* ── INNER HEADER FROM MODAL ── */
  .bon-header { text-align: center; margin-bottom: 2mm; }
  .bon-header h3 { font-size: 9pt; font-weight: 700; }
  .bon-header p { font-size: 7.5pt; }
  .bon-header div { display: flex; justify-content: space-between; font-size: 8pt; margin-top: 1.5mm; }

  /* ── TABLE ── */
  .bon-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 8.5pt;
    margin-bottom: 2mm;
    flex: 1;
  }
  .bon-table th {
    background: #000 !important;
    color: #fff !important;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
    padding: 2mm 2.5mm;
    font-weight: 700;
    border: 0.5pt solid #000;
    text-align: right;
  }
  .bon-table td {
    padding: 2mm 2.5mm;
    border: 0.5pt solid #333;
    text-align: right;
    vertical-align: middle;
  }
  .bon-table tr:nth-child(even) td {
    background: #f2f2f2;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  /* ── SIGNATURE BLOCKS ── */
  .bon-sig {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 4mm;
    margin-top: auto;
    padding-top: 2mm;
    border-top: 0.5pt solid #000;
  }
  .bon-sig-box {
    text-align: center;
    padding-top: 12mm;
    border-top: 0.5pt solid #000;
    font-size: 7.5pt;
    font-weight: 700;
  }

  /* ── WATERMARK COPY LINE ── */
  .copy-line {
    text-align: center;
    font-size: 7pt;
    color: #666;
    margin-top: 2mm;
    letter-spacing: 1pt;
    text-transform: uppercase;
  }

  /* ── SEPARATOR between two bons on same page ── */
  .page-cut {
    border: none;
    border-top: 1pt dashed #999;
    margin: 4mm 0;
    text-align: center;
    position: relative;
  }
  .page-cut::after {
    content: '✂';
    position: absolute;
    top: -7pt;
    right: 0;
    font-size: 9pt;
    color: #999;
  }

  @page {
    size: A4 portrait;
    margin: 8mm 10mm;
  }

  @media print {
    body { margin: 0; }
    .bon { border: 1.5pt solid #000; }
    .no-print { display: none !important; }
  }
</style>
</head>
<body>

<!-- ── BON ORIGINAL ── -->
<div class="bon">
  <div class="bon-state">
    الجمهورية الجزائرية الديمقراطية الشعبية
    <small>وزارة التربية الوطنية — مديرية التربية لولاية البيض — مصلحة الوسائل العامة</small>
  </div>
  <div class="bon-meta">
    <span>${isIN ? 'وصل استلام — BON DE RÉCEPTION' : 'وصل إخراج — BON DE SORTIE'}</span>
    <span style="color:#000;font-weight:700">نسخة أصلية — ORIGINAL</span>
  </div>
  ${header}
  ${table}
  <div class="bon-sig">
    <div class="bon-sig-box">أمين المخزن<br>Magasinier</div>
    <div class="bon-sig-box">${isIN ? 'المستلم<br>Réceptionnaire' : 'المصلحة الطالبة<br>Service Demandeur'}</div>
    <div class="bon-sig-box">المسؤول المالي<br>Responsable Budget</div>
  </div>
</div>

<!-- ── SEPARATOR ── -->
<div class="page-cut"></div>

<!-- ── BON COPIE ── -->
<div class="bon">
  <div class="bon-state">
    الجمهورية الجزائرية الديمقراطية الشعبية
    <small>وزارة التربية الوطنية — مديرية التربية لولاية البيض — مصلحة الوسائل العامة</small>
  </div>
  <div class="bon-meta">
    <span>${isIN ? 'وصل استلام — BON DE RÉCEPTION' : 'وصل إخراج — BON DE SORTIE'}</span>
    <span style="color:#888;font-weight:700">نسخة — COPIE</span>
  </div>
  ${header}
  ${table}
  <div class="bon-sig">
    <div class="bon-sig-box">أمين المخزن<br>Magasinier</div>
    <div class="bon-sig-box">${isIN ? 'المستلم<br>Réceptionnaire' : 'المصلحة الطالبة<br>Service Demandeur'}</div>
    <div class="bon-sig-box">المسؤول المالي<br>Responsable Budget</div>
  </div>
</div>

<script>window.onload = function(){ window.print(); window.close(); }</script>
</body>
</html>`;

  const w = window.open('', '_blank', 'width=720,height=560');
  w.document.write(printHTML);
  w.document.close();
}
```

Also fix your main app's `@media print` block for the dashboard/list print path (when the user prints from the `doPrint()` function):

```css
/* ADD this to your main <style> block — replaces the existing @media print */
@media print {
  @page {
    size: A4 portrait;
    margin: 10mm 12mm;
  }

  /* Hide everything except content */
  #login-screen,
  .titlebar,
  .sidebar,
  .btn-bar,
  .hdr-right,
  .alert-strip,
  .warn-box,
  .no-print,
  #modal,
  #toast-container,
  .sb-notif,
  .lang-bar {
    display: none !important;
  }

  body {
    background: white !important;
    font-size: 10pt;
    direction: rtl;
  }

  .app {
    max-width: 100% !important;
    margin: 0 !important;
    border: none !important;
    box-shadow: none !important;
    border-radius: 0 !important;
  }

  /* Force header to be minimal */
  .hdr {
    background: none !important;
    color: #000 !important;
    border-bottom: 1.5pt solid #000 !important;
    padding: 4pt 0 !important;
    height: auto !important;
    print-color-adjust: exact;
    -webkit-print-color-adjust: exact;
  }
  .hdr-title {
    color: #000 !important;
    font-size: 12pt !important;
    font-weight: 700 !important;
  }

  .body-wrap {
    height: auto !important;
    display: block !important;
  }

  .content {
    overflow: visible !important;
    padding: 6pt !important;
  }

  /* Tables print sharp */
  .dt {
    font-size: 8.5pt;
    border-collapse: collapse;
  }
  .dt th {
    background: #000 !important;
    color: #fff !important;
    print-color-adjust: exact;
    -webkit-print-color-adjust: exact;
    padding: 3pt 5pt;
    border: 0.5pt solid #000;
  }
  .dt td {
    padding: 3pt 5pt;
    border: 0.5pt solid #444;
  }
  .dt tr:nth-child(even) td {
    background: #f5f5f5 !important;
    print-color-adjust: exact;
  }

  /* Row animation off */
  .dt tbody tr {
    animation: none !important;
    opacity: 1 !important;
  }

  /* KPI cards in print */
  .kpi-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 4pt;
    margin-bottom: 6pt;
  }
  .kpi {
    border: 0.5pt solid #000;
    padding: 4pt;
    border-radius: 0;
  }
  .kpi-val { font-size: 14pt; }

  /* Print header block */
  .print-header {
    display: block !important;
    text-align: center;
    border-bottom: 1pt solid #000;
    padding-bottom: 4pt;
    margin-bottom: 6pt;
  }

  /* ABC blocks */
  .abc-cls { border: 0.5pt solid #000 !important; break-inside: avoid; }
  .abc-a { background: none !important; }
  .abc-b { background: none !important; }
  .abc-c { background: none !important; }

  /* Badges in mono */
  .badge {
    border: 0.5pt solid #000 !important;
    background: none !important;
    color: #000 !important;
    print-color-adjust: exact;
  }
}
```

---

## Pillar 2 — Enterprise UX/UI Polish

**Three targeted fixes based on the screenshots:**

**Fix A: Auto-format the document reference field** (the most impactful single UX change — prevents ref number errors):

```javascript
// Add this function and call it after renderForm() renders
function initRefMasking(type) {
  const refEl = document.getElementById('f-ref');
  if (!refEl) return;

  const prefix = type === 'IN' ? 'BR' : 'BS';
  const ym = new Date().toISOString().slice(0, 7).replace('-', ''); // "202604"

  refEl.addEventListener('focus', function () {
    if (!this.value) {
      // Count existing movements of this type for auto-numbering
      const count = movements.filter(m => m.type === type).length + 1;
      this.value = `${prefix}-${ym}-${String(count).padStart(3, '0')}`;
      this.select(); // Select all so user can immediately overtype
    }
  });

  refEl.addEventListener('input', function () {
    // Real-time format check — warn if pattern broken
    const pattern = /^[A-Z]{2}-\d{6}-\d{3}$/;
    const hint = document.getElementById('hint-ref');
    if (hint) {
      if (this.value.length > 5 && !pattern.test(this.value)) {
        hint.textContent = `⚠ التنسيق المطلوب: ${prefix}-YYYYMM-NNN (مثال: ${prefix}-202604-001)`;
        hint.classList.add('show');
        this.style.borderColor = 'var(--orange)';
      } else {
        hint.classList.remove('show');
        this.style.borderColor = '';
      }
    }
  });
}
```

Call it after the form renders — add `initRefMasking(type)` at the end of `renderForm(type)`.

**Fix B: Animated stock status transition** (micro-interaction — shows staff immediately that their selection matters):

```css
/* Add to main style block */
.stock-ind {
  transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  transform-origin: top;
}
.stock-ind.si-zero {
  animation: pulse-red 1.2s ease infinite;
}
@keyframes pulse-red {
  0%, 100% { box-shadow: 0 0 0 0 rgba(139, 26, 26, 0.4); }
  50% { box-shadow: 0 0 0 6px rgba(139, 26, 26, 0); }
}

/* Step numbers animate to green on completion */
.step-num {
  transition: background 0.3s ease, transform 0.2s ease;
}
.step-num.done {
  background: var(--green) !important;
  transform: scale(1.1);
}

/* DA cards - hover lift */
.da-card {
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}
.da-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0,0,0,0.12);
}

/* Table rows - smoother hover */
.dt tr:hover td {
  transition: background 0.12s ease;
}

/* Clickable KPI pulse on alert */
.kpi:has(.kv-r), .kpi:has(.kv-o) {
  animation: kpi-pulse 2s ease infinite;
}
@keyframes kpi-pulse {
  0%, 100% { box-shadow: none; }
  50% { box-shadow: 0 0 0 3px rgba(186, 106, 0, 0.25); }
}
```

**Fix C: Dashboard row click — preload the article into the form** (eliminates 3 redundant selection steps):

```javascript
// Replace your showArticleDetail function's modal buttons section:
// In the modal footer, add a "direct issue" button that pre-populates the form:

function showArticleDetail(code) {
  const a = articles.find(x => x.code === code);
  if (!a) return;
  const l = t();
  const mvts = movements.filter(m => m.code === code);

  const html = `<div class="modal-overlay"><div class="modal-box" style="max-width:420px" onclick="event.stopPropagation()">
    <div class="modal-title">📦 ${a.code} — ${getName(a)}</div>
    <table style="width:100%;font-size:12px;border-collapse:collapse">
      <tr><td style="padding:4px 0;color:var(--grey);width:45%">${l.th.abc}</td><td>${abcBadge(a.abc)}</td></tr>
      <tr><td style="padding:4px 0;color:var(--grey)">${l.th.stock}</td>
          <td><b style="font-size:16px;color:${getStatus(a)==='rupture'?'var(--red)':getStatus(a)==='order'?'var(--blue2)':'var(--green)'}">${fmt(a.stock)} ${a.unit}</b></td></tr>
      <tr><td style="padding:4px 0;color:var(--grey)">${l.th.pu}</td><td><b style="color:var(--blue2)">${fmt(a.pu)} DA</b></td></tr>
      <tr><td style="padding:4px 0;color:var(--grey)">ROP</td><td>${fmt(rop[a.code]||a.min)} — ${statusBadge(getStatus(a))}</td></tr>
      <tr><td style="padding:4px 0;color:var(--grey)">${l.th.sup}</td><td>${a.supplier}</td></tr>
      <tr><td style="padding:4px 0;color:var(--grey)">${l.th.loc}</td><td><code style="background:#F0EDE6;padding:1px 5px;border-radius:3px">${a.loc}</code></td></tr>
    </table>
    <div style="margin-top:10px;font-size:11px;color:var(--grey)">${curLang==='ar'?'آخر 4 حركات:':'4 derniers mouvements:'}</div>
    <table class="dt" style="margin-top:5px;font-size:11px"><thead><tr>
      <th>${l.th.date}</th><th>${l.th.type}</th><th>${l.th.qty}</th><th>${l.th.ref}</th>
    </tr></thead>
    <tbody>${mvts.slice(-4).reverse().map(m=>`<tr>
      <td style="font-size:10px;font-family:var(--font-fr)">${m.date}</td>
      <td>${typeBadge(m.type)}</td><td><b>${m.qty}</b></td>
      <td style="font-size:10px;font-family:var(--font-fr)">${m.ref}</td>
    </tr>`).join('')}</tbody></table>
    <div class="modal-btns" style="margin-top:12px">
      <button class="btn bgr" onclick="closeModal()">${l.btn.close}</button>
      <button class="btn bg" onclick="closeModal();navWithPreload('addIn','${a.code}')">${l.btn.in}</button>
      <button class="btn br" onclick="closeModal();navWithPreload('addOut','${a.code}')">${l.btn.out}</button>
    </div>
  </div></div>`;

  document.getElementById('modal').innerHTML = html;
  document.getElementById('modal').style.display = 'block';
}

// NEW: navigate to form AND pre-select the article (skips steps 3 & 4)
function navWithPreload(mod, preloadCode) {
  nav(mod);
  // Wait for form to render, then pre-select category and article
  setTimeout(() => {
    const a = articles.find(x => x.code === preloadCode);
    if (!a) return;
    const catSel = document.getElementById('f-cat');
    const artSel = document.getElementById('f-art');
    if (!catSel || !artSel) return;

    // Find and select the category
    const catKey = Object.keys(cats[curLang]).find(k => (cats[curLang][k] || []).includes(preloadCode));
    if (catKey) {
      catSel.value = catKey;
      filterArticles(); // populate article dropdown
      artSel.value = preloadCode;
      showStockInd(mod === 'addIn' ? 'IN' : 'OUT');

      // Mark steps 3 and 4 as done
      markStep(3);
      markStep(4);

      // Focus the quantity field — where the user actually needs to type
      document.getElementById('f-qty')?.focus();
    }
  }, 80);
}
```

---

## Pillar 3 — Advanced Data Analysis (No External Libraries)

**Pure SVG consumption velocity chart — zero dependencies, embeds directly in the ABC module:**

```javascript
// Add this function and call it at the end of renderABC()
function renderConsumptionSparklines() {
  articles.forEach(a => {
    const container = document.querySelector(`[data-sparkline="${a.code}"]`);
    if (!container) return;

    // Get last 6 months of OUT movements for this article
    const outMovements = movements
      .filter(m => m.code === a.code && m.type === 'OUT')
      .sort((x, y) => x.date.localeCompare(y.date));

    if (outMovements.length < 2) {
      container.innerHTML = '<span style="font-size:10px;color:#AAA">—</span>';
      return;
    }

    // Group by month
    const byMonth = {};
    outMovements.forEach(m => {
      const month = m.date.slice(0, 7);
      byMonth[month] = (byMonth[month] || 0) + m.qty;
    });

    const values = Object.values(byMonth).slice(-6);
    const max = Math.max(...values, 1);
    const W = 80, H = 28;
    const pts = values.map((v, i) => {
      const x = (i / (values.length - 1)) * (W - 4) + 2;
      const y = H - 2 - ((v / max) * (H - 6));
      return `${x},${y}`;
    }).join(' ');

    // Color by trend
    const trend = values[values.length - 1] - values[values.length - 2];
    const strokeColor = trend > 0 ? '#1F6B2E' : trend < 0 ? '#8B1A1A' : '#185FA5';
    const trendIcon = trend > 0 ? '↑' : trend < 0 ? '↓' : '→';

    container.innerHTML = `
      <div style="display:flex;align-items:center;gap:4px">
        <svg width="${W}" height="${H}" style="overflow:visible">
          <polyline points="${pts}"
            fill="none" stroke="${strokeColor}" stroke-width="1.5"
            stroke-linecap="round" stroke-linejoin="round"/>
          <circle cx="${pts.split(' ').pop().split(',')[0]}"
                  cy="${pts.split(' ').pop().split(',')[1]}"
                  r="2.5" fill="${strokeColor}"/>
        </svg>
        <span style="font-size:11px;font-weight:700;color:${strokeColor}">${trendIcon} ${values[values.length-1]}</span>
      </div>`;
  });
}

// Modify renderABC() — add data-sparkline attribute to each article row:
// In the tbody row, replace:
//   <td>${fmt(a.stock)}</td>
// with:
//   <td>${fmt(a.stock)} <span data-sparkline="${a.code}"></span></td>
// Then call renderConsumptionSparklines() at the end of renderABC()
```

**Predictive stockout projection — add to the Dashboard KPI row:**

```javascript
// Add this function
function calcStockoutProjection(artCode) {
  const a = articles.find(x => x.code === artCode);
  if (!a || a.stock === 0) return 0;

  const recentOuts = movements
    .filter(m => m.code === artCode && m.type === 'OUT')
    .sort((x, y) => y.date.localeCompare(x.date))
    .slice(0, 10); // last 10 exits

  if (!recentOuts.length) return null;

  // Get date range of recent movements
  const oldest = recentOuts[recentOuts.length - 1].date;
  const newest = recentOuts[0].date;
  const daySpan = Math.max(1, (new Date(newest) - new Date(oldest)) / 86400000 + 1);
  const totalQty = recentOuts.reduce((s, m) => s + m.qty, 0);
  const dailyRate = totalQty / daySpan;

  if (dailyRate <= 0) return null;
  return Math.floor((a.stock - (rop[artCode] || a.min)) / dailyRate);
}

// Call this inside renderDashboard() to add a projection column
// In the table header, add: <th>أيام حتى ROP</th>
// In each row: <td>${(() => { const d = calcStockoutProjection(a.code); return d === null ? '—' : d <= 0 ? '<span style="color:var(--red);font-weight:700">⚠ الآن</span>' : d <= 7 ? `<span style="color:var(--orange);font-weight:700">${d} يوم</span>` : `<span style="color:var(--grey)">${d} يوم</span>`; })()}</td>
```

---

## Pillar 4 — Pragmatic Offline "AI" Features

**Feature A: Fuzzy search to prevent duplicate articles** (Levenshtein distance — prevents entering "Rame A4" when "Rame papier A4" already exists):

```javascript
// Levenshtein distance — pure JS, no libraries
function levenshtein(a, b) {
  const m = a.length, n = b.length;
  const dp = Array.from({ length: m + 1 }, (_, i) => Array.from({ length: n + 1 }, (_, j) => i === 0 ? j : j === 0 ? i : 0));
  for (let i = 1; i <= m; i++) {
    for (let j = 1; j <= n; j++) {
      dp[i][j] = a[i-1] === b[j-1]
        ? dp[i-1][j-1]
        : 1 + Math.min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]);
    }
  }
  return dp[m][n];
}

// Find similar articles — returns matches with similarity score
function findSimilarArticles(inputName, threshold = 4) {
  if (!inputName || inputName.length < 3) return [];
  const lower = inputName.toLowerCase();
  return articles
    .map(a => {
      const nameAr = (a.name_ar || '').toLowerCase();
      const nameFr = (a.name_fr || '').toLowerCase();
      const dist = Math.min(levenshtein(lower, nameAr), levenshtein(lower, nameFr));
      // Also check substring containment
      const contains = nameAr.includes(lower) || nameFr.includes(lower) || lower.includes(nameAr.slice(0, 5));
      return { article: a, dist, contains };
    })
    .filter(x => x.dist <= threshold || x.contains)
    .sort((x, y) => x.dist - y.dist)
    .slice(0, 3);
}

// Hook this into showAddArticleModal() — add a live duplicate warning:
// After the modal renders, add this listener:
function initDuplicateCheck() {
  const nameInput = document.getElementById('na-name-ar');
  const warnEl = document.getElementById('na-err');
  if (!nameInput || !warnEl) return;

  nameInput.addEventListener('input', function () {
    if (this.value.length < 4) { warnEl.style.display = 'none'; return; }
    const similar = findSimilarArticles(this.value);
    if (similar.length) {
      warnEl.innerHTML = `⚠ مواد مشابهة موجودة — تأكد أن هذه مادة جديدة فعلاً:<br>` +
        similar.map(s => `&nbsp;• <b>${s.article.code}</b> — ${s.article.name_ar}`).join('<br>');
      warnEl.style.display = 'block';
      warnEl.style.color = 'var(--orange)';
    } else {
      warnEl.style.display = 'none';
    }
  });
}
// Call initDuplicateCheck() at the end of showAddArticleModal()
```

**Feature B: Auto-categorization by keyword** (reduces user error on new article entry):

```javascript
const autoCategRules = {
  'ar': {
    'لوازم مكتبية': ['ورق', 'رزمة', 'طباعة', 'A4', 'A3', 'فاكس'],
    'مستهلكات إعلام آلي': ['حبر', 'تونر', 'طابعة', 'toner', 'G030', 'خرطوشة'],
    'أرشيف وتخزين': ['ملف', 'أرشيف', 'chemise', 'علبة'],
    'أدوات الكتابة': ['قلم', 'تحديد', 'marqueur', 'stylo'],
    'أدوات مكتبية': ['دباسة', 'ختم', 'حبر الختم', 'مقص'],
    'سجلات إدارية': ['سجل', 'دفتر', 'registre'],
  }
};

function autoDetectCategory(nameAr, nameFr) {
  const combined = (nameAr + ' ' + nameFr).toLowerCase();
  const rules = autoCategRules['ar'];
  for (const [cat, keywords] of Object.entries(rules)) {
    if (keywords.some(kw => combined.includes(kw.toLowerCase()))) {
      return cat;
    }
  }
  return null;
}

// Hook into showAddArticleModal():
// After rendering, add listeners to both name inputs:
function initAutoCateg() {
  ['na-name-ar', 'na-name-fr'].forEach(id => {
    const el = document.getElementById(id);
    if (!el) return;
    el.addEventListener('input', () => {
      const nameAr = document.getElementById('na-name-ar')?.value || '';
      const nameFr = document.getElementById('na-name-fr')?.value || '';
      const detected = autoDetectCategory(nameAr, nameFr);
      const catSel = document.getElementById('na-cat');
      if (detected && catSel) {
        catSel.value = detected;
        catSel.style.borderColor = 'var(--green)';
        catSel.title = `تصنيف تلقائي: ${detected}`;
      }
    });
  });
}
// Call initAutoCateg() at the end of showAddArticleModal()
```

**Feature C: Consumption velocity banner** — a single line added to the dashboard that acts as an operational intelligence summary:

```javascript
function renderVelocityBanner() {
  const criticals = articles
    .filter(a => a.stock > 0)
    .map(a => ({ a, days: calcStockoutProjection(a.code) }))
    .filter(x => x.days !== null && x.days <= 14 && x.days >= 0)
    .sort((x, y) => x.days - y.days);

  if (!criticals.length) return '';

  return `<div style="background:linear-gradient(90deg,var(--orange-l),#fff);border:1px solid var(--orange);border-radius:5px;padding:7px 12px;margin-bottom:10px;font-size:11.5px;color:var(--orange)">
    📊 <b>${curLang==='ar'?'تحذير الاستهلاك':'Alerte consommation'}</b> —
    ${criticals.map(x => `<b>${x.a.code}</b>: ${x.days} ${curLang==='ar'?'يوم':'j'}`).join(' | ')}
    ${curLang==='ar'?' قبل الوصول إلى نقطة إعادة الطلب':' avant ROP'}
  </div>`;
}
// Call inside renderDashboard() and insert before the KPI row
```

---

## Summary Priority Matrix

| Priority | Change | Impact | Effort |
|---|---|---|---|
| 🔴 Critical | Replace `printBon()` with new compact function | Fixes unusable PDFs | 10 min |
| 🔴 Critical | `@media print` main CSS block | Fixes list/dashboard prints | 5 min |
| 🟠 High | `navWithPreload()` + `initRefMasking()` | Cuts 3 clicks per transaction | 15 min |
| 🟠 High | Levenshtein duplicate check | Data integrity | 20 min |
| 🟡 Medium | SVG sparklines in ABC | Jury "wow" factor | 25 min |
| 🟡 Medium | Velocity banner + projection column | Real operational value | 20 min |
| 🟢 Nice | Auto-categorization | Minor UX polish | 10 min |

**Next logical step:** The print fix is your most critical remaining gap before defense — that PDF sample would cost points with a jury. Implement Pillar 1 first, generate a test print, and confirm the two-bon-per-page layout renders correctly before moving to the other pillars.





---
Powered by [Claude Exporter](https://www.ai-chat-exporter.net)