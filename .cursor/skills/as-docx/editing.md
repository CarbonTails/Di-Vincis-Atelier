# Editing All Space Word documents

## Template path

| Style | Template |
|-------|----------|
| All Space Corporate | `templates/all-space-corporate.docx` |

Read [styles/all-space-corporate.md](styles/all-space-corporate.md) for fonts, footer fields, structure, and style IDs.

---

## Template-based workflow (default)

When the user invokes **`/as-docx`** or asks for a corporate Word document:

1. **Copy the template** to the workspace:
   ```
   copy templates/all-space-corporate.docx → {output-name}.docx
   ```

2. **Analyze the copy**:
   ```bash
   python -m markitdown working-copy.docx
   ```
   Identify placeholder sections to replace (cover title, document information, body chapters, footer metadata).

3. **Unpack**:
   ```bash
   python scripts/office/unpack.py working-copy.docx unpacked/
   ```
   Keep a **pristine reference unpack** of an unmodified template copy (`ref-unpack/`) for footer/header restoration.

4. **Plan content mapping** — map user content to template sections:
   - Cover title → `Title` style paragraph in cover SDT
   - Metadata → Document Information table
   - Sections → `Heading1` / `Heading2` / `Heading3` hierarchy
   - Tables → existing table patterns with `Tableheader` / `Tabletext`
   - Notes → copy admonition table blocks from template
   - Figures → `Caption` style with Figure SEQ field (only if figures exist)
   - Captioned body tables → `Caption` style with Table SEQ field (only if captioned tables exist)

5. **Edit XML** in `unpacked/word/document.xml` (and headers/footers if metadata changes):
   - Replace placeholder text using the Edit tool (string replacement) for small edits
   - For large body replacements, a build script is acceptable when it preserves template XML structure
   - Preserve `<w:pStyle>`, `<w:tbl>`, and field codes for TOC/page numbers
   - Update footer metadata using the footer restore pattern (below)
   - Use smart-quote XML entities for new text (`&#x2019;`, `&#x201C;`, etc.)

6. **Pack**:
   ```bash
   python scripts/office/pack.py unpacked/ output.docx --original working-copy.docx
   ```
   On Windows, if pack crashes on Unicode output: `$env:PYTHONIOENCODING='utf-8'`

7. **Validate**:
   ```bash
   python scripts/office/validate.py output.docx
   ```

8. **Content QA** — grep extracted text for leftover placeholders:
   ```bash
   python -m markitdown output.docx | findstr /i "Hydra Max ASICD-000001 lorem xxxx Template"
   ```
   Confirm Information Type is not still `Template` unless the document is actually a template.

---

## Corporate build checklist

Complete these steps in order when building a full document from the template.

### 1. Metadata and cover

| Field | Where | Notes |
|-------|-------|-------|
| Document title | Cover SDT + footer left column | Short name in footer |
| URN | Document Information table + footer right column | Always `ASNI-` + six digits, e.g. `ASNI-000001` |
| Information Type | Document Information table (+ optional `docProps/core.xml`) | Match document purpose; never leave template placeholder `Template` |
| Keywords | Document Information table | Comma-separated |
| Date | Footer right column | UK format: `14th June 2026` |
| Revision | Footer right column | e.g. `Rev 1.0` |

### 2. Footer restore (critical)

**Do not** use broad regex to replace footer text. That breaks the two-column table layout.

1. Copy `footer2.xml` and `footer3.xml` from the pristine reference unpack.
2. Update only known cells by **paraId** or targeted string replace:
   - Document title (left column)
   - URN prefix run: replace `<w:t>ASICD</w:t>` with `<w:t>ASNI</w:t>` (footer splits prefix and number across runs)
   - URN in Document Information table: replace full string e.g. `ASICD-000001` → `ASNI-000001`
   - Date paraIds in reference template: `2407A6C7` (footer2), `19610AFB` (footer3)
3. Keep `Proprietary`, page number field, and `UNCONTROLLED WHEN DISTRIBUTED` intact.

### 3. Table of Contents

The template ships with stale cached TOC entries (Hydra sample content). Rebuild the main TOC field:

- Front matter entries: Document Information, Review History, Review & Approval (with PAGEREF bookmarks)
- Body headings: all `Heading1`–`Heading3` with matching bookmarks
- **First TOC entry** must be a hyperlink **inside** the existing TOC field paragraph (sibling to `fldChar separate`)
- **Additional entries** are separate `<w:p>` blocks after the field paragraph
- Clear cached hyperlinks between `fldChar separate` and `fldChar end`

Use `rfind("<w:p ", 0, end)` when locating paragraph boundaries — **not** `rfind("<w:p")`, which matches `<w:pPr>`.

### 4. Index of Figures (conditional)

**Include** the Index of Figures section only when the document body contains captioned figures:

- `Caption` style paragraphs with `SEQ Figure` fields, or
- `w:drawing` elements paired with figure captions in the body (after front matter)

**When figures exist:**

- Keep the Index of Figures heading and TOC field (`TOC \h \z \c "Figure"`)
- Clear stale cached hyperlinks inside the field (template Hydra figure entries)
- Word refreshes entries when the user updates fields (Ctrl+A, F9)

**When no figures exist:**

- Remove the entire Index of Figures block (heading through field-end paragraph, paraId `15F405DB`)

### 5. Index of Tables (conditional)

**Include** the Index of Tables section only when the document body contains **captioned tables**:

- `Caption` style paragraphs with `SEQ Table` fields in the body

**Do not count** front-matter metadata tables (Document Information, Review History, Review & Approval).

**When captioned body tables exist:**

- Keep the Index of Tables heading and TOC field (`TOC \h \z \c "Table"`)
- Clear stale cached hyperlinks inside the field

**When no captioned body tables exist:**

- Remove the entire Index of Tables block (heading through field-end paragraph, paraId `534C7460`)

### 6. Body content

- Replace body from **About This Document** (paraId `235B305E`) through the end-of-document block
- Use template styles: `Heading1` with `numId 1` / `ilvl 0` for numbered sections, `Heading2` with `numId 1` / `ilvl 1` for subsections
- Add **bookmark** anchors on headings for TOC PAGEREF fields (`_Toc{unique}`)
- Use **blank spacer paragraphs** (`w:spacing w:after="0"`, no text) between body blocks for visual separation — the template does not rely on paragraph `w:after` spacing alone
- **Restart bullet lists** between sections: the template uses `numId 2` (`abstractNumId 0`) for body bullets. Reusing the same `numId` across separate lists makes numbering continue (section 15 picks up at 6 after section 11). Allocate a **new `numId`** in `numbering.xml` (same abstract definition) for each new bullet list after the first

### 7. End of Document (required)

**`-End of Document-`** must appear on its **own last page**, **centered**.

Structure (match reference template):

1. **Page break** paragraph (`<w:br w:type="page"/>`)
2. **~20 empty spacer paragraphs** (vertical centering on the final page)
3. **Centered end marker** — F37 Ginger, bold, 40pt, text `-End of Document-` (preserve paraId `31CF824B` when possible)
4. **Trailing empty paragraph** before `<w:sectPr>`

Do not append the end marker immediately after the last body paragraph.

### 8. XML safety rules

| Rule | Detail |
|------|--------|
| RSIDs | 8-digit hex only (e.g. `00DE115E`). Never use non-hex like `00AS0001` |
| paraIds | Random 8-char hex, value `< 0x80000000` (max `0x7FFFFFFF`) |
| Paragraph find | Use `rfind("<w:p ", 0, pos)` not `rfind("<w:p")` |
| Field nesting | TOC entries after the first go in separate `<w:p>` blocks, not nested inside the field paragraph |
| Smart quotes | Use XML entities in new text |

---

## What to preserve

- **Section properties** in `document.xml` (`sectPr`, `titlePg`, header/footer references)
- **Header2** — logo and bottom border (body pages)
- **Footer2 / Footer3** — two-column metadata table and page number field (restore from reference, then patch)
- **Style definitions** in `styles.xml` — edit content, not theme/styles, unless user requests branding change
- **Cover page SDT** structure — replace title text and images only as needed
- **TOC field structure** — rebuild entries; do not delete the field itself

---

## What to replace

| Template placeholder | Replace with |
|---------------------|--------------|
| Cover title (`All.Space Word Template`) | User document title |
| URN (`ASICD-000001`) | `ASNI-` + six-digit number (e.g. `ASNI-000001`) in **both** Document Information table and footer |
| Information Type (`Template`) | Purpose-appropriate type from the list below (e.g. `White Paper`, `User Guide`, `ICD`) |
| Hydra Max 2 example sections | User content |
| Footer document title | Short document name |
| Footer date / Rev | Current date and revision |
| Review History / Approval rows | User-supplied or leave template rows empty |
| Index of Figures / Tables | Keep only when figures/captioned tables exist; otherwise remove |
| `-End of Document-` | Keep on dedicated last page, centered (always) |

---

## Creating vs editing

| Scenario | Approach |
|----------|----------|
| New corporate document | Copy template → replace body content → update footer metadata → conditional indices → end page |
| Edit existing ALL.SPACE doc | Unpack user's file if already on-brand; otherwise copy template and migrate content |
| User insists on docx-js | Not recommended; template fidelity is poor. Warn user and prefer template path |

---

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/office/unpack.py` | Extract and pretty-print DOCX XML |
| `scripts/office/pack.py` | Repack with validation and auto-repair |
| `scripts/office/validate.py` | Validate output DOCX |
| `scripts/comment.py` | Add review comments |
| `scripts/accept_changes.py` | Accept tracked changes (LibreOffice) |

All script paths are relative to the `as-docx` skill root when invoked from skill documentation.

For complex multi-section builds, a workspace build script that follows this checklist is acceptable. Prefer the Edit tool for targeted fixes after the initial build.
