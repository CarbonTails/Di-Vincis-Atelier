# All Space Corporate Word style guide

Official ALL.SPACE technical and commercial Word style. Reference file: `templates/all-space-corporate.docx` (All.Space Word Template).

**Always build from the template.** Copy `templates/all-space-corporate.docx` to your workspace, then replace placeholder content while keeping styles, headers, footers, and section structure. Do not recreate this look from scratch with docx-js unless the user explicitly asks for a lightweight export without the full template.

When building a production document, replace sample titles, URN, dates, revision numbers, and Hydra example content with real content.

---

## Brand identity

- **Company:** ALL.SPACE NETWORKS Ltd.
- **Voice:** Professional, operational, defence/space-sector credible. Direct language; structure and precision over marketing fluff.
- **Document types:** ICDs, user guides, installation manuals, engineering specs, internal templates.
- **Structure pattern:** Cover page → document information → review/approval tables → table of contents → (optional) index of figures/tables → numbered body sections → end marker on its own last page.

---

## Color palette

Primary brand fonts carry most of the visual identity. Accent colors appear in admonition icons, hyperlinks, and table emphasis.

| Role | Hex | Usage |
|------|-----|--------|
| **Text (primary)** | `#000000` | Body and headings |
| **Accent (theme)** | `#156082` | Heading 5+, intense emphasis, quote borders |
| **Hyperlink** | `#467886` | Cross-references, URLs |
| **Followed hyperlink** | `#96607D` | Visited links |
| **Dark secondary** | `#0E2841` | Theme dark 2 |
| **Light secondary** | `#E8E8E8` | Header rule, background accents |
| **Admonition red** | `#C00000` | Used on cover decorative elements |

Match hyperlink and emphasis colors from the template; do not substitute generic blue.

---

## Typography

| Role | Font | Fallback if unavailable |
|------|------|-------------------------|
| **Title / headings** | F37 Ginger | Arial Black, Calibri Bold |
| **Body** | F37 Ginger Light | Calibri, Arial |
| **Table header cells** | Arial Bold | Arial Bold |
| **Table body cells** | Arial | Arial |
| **Footer metadata** | Arial 8pt | Arial |

| Style ID | Word style name | Size | Weight | Use for |
|----------|-----------------|------|--------|---------|
| `Title` | Title | 28pt | Bold | Cover page document title (centered) |
| `Heading1` | heading 1 | 20pt | Bold | Top-level sections (e.g. "About This Document") |
| `Heading2` | heading 2 | 16pt | Bold | Second-level sections (e.g. "Purpose") |
| `Heading3` | heading 3 | 14pt | Bold | Third-level sections |
| `Heading4` | heading 4 | 12pt | Bold Italic | Fourth-level sections |
| `Normal` | Normal | 10pt | Regular | Default body text |
| `Body` | .Body | 10pt | Regular | Paragraph body (Arial variant) |
| `Tableheader` | Table_header | 11pt | Bold | Table header row cells |
| `Tabletext` | Table_text | 11pt | Regular | Table body cells |
| `Caption` | caption | — | — | Figure and table captions |
| `TOCHeading` | TOC Heading | — | Bold | Table of contents heading |

Language default in template: **en-GB**.

---

## Page layout

| Setting | Value |
|---------|-------|
| **Paper** | A4 (11906 × 16838 DXA; 210 × 297 mm) |
| **Margins** | 1" (1440 DXA) all sides |
| **Header distance** | 708 DXA |
| **Footer distance** | 708 DXA |
| **First page** | Different header/footer (`titlePg` enabled) |

Content width with 1" margins: **9026 DXA** (~6.27").

---

## Headers and footers

### First page (cover)

- Minimal header/footer (empty placeholders).
- Cover uses built-in **Cover Pages** gallery content with centered **Title** style and brand imagery.

### Body pages (default header)

- **ALL.SPACE logo** right-aligned in header.
- Light gray bottom border (`#E8E8E8`, single 6pt rule).
- Do not remove or resize the logo relationship; edit surrounding text only if needed.

### Body pages (default footer)

Footer uses a **two-column table** (do not replace with tab stops; match the template structure):

| Left column | Right column |
|-------------|--------------|
| Document title | Document ID (e.g. `ASNI-000001`) |
| *(blank line)* | Date (e.g. `01st May 2026`) |
| `Proprietary` | `Rev 1.0` |
| | `UNCONTROLLED WHEN DISTRIBUTED` |

Below the table: centered **`Page | {n}`** with Word page field.

**Update on every new document:**

- Document title (left column, row 1)
- Document ID / URN (right column, row 1) — **always** starts with `ASNI-` followed by a six-digit number (e.g. `ASNI-000001`)
- Date and revision
- Keep `Proprietary` and `UNCONTROLLED WHEN DISTRIBUTED` unless the user specifies controlled distribution

Footer text: **Arial 8pt** (16 half-points in XML).

**Footer editing rule:** Copy footers from a pristine template unpack, then patch title, URN, date, and revision by targeted replace or known paraIds. Never use broad regex that replaces entire table cells — that breaks the two-column layout.

---

## Document structure

Use this section order unless the user specifies otherwise:

1. **Cover page** — Title style, centered document name, cover imagery
2. **Document Information** — `Heading1` + attribute table (URN, information type, keywords)
3. **Review History** — `Heading2` + revision table (Rev, Date, Comments, Author)
4. **Review & Approval** — `Heading2` + signature table (Author, Reviewer, Approver)
5. **Table of Contents** — Word TOC field (Heading 1–3); rebuild cached entries for new content
6. **Index of Figures** — include **only** when the body contains captioned figures (`Caption` style + Figure SEQ field, or drawings with figure captions). Remove this section when no figures exist.
7. **Index of Tables** — include **only** when the body contains captioned tables (`Caption` style + Table SEQ field). Front-matter metadata tables do **not** count. Remove this section when no captioned body tables exist.
8. **Body sections** — numbered headings, body text, tables, figures; use blank spacer paragraphs between blocks
9. **End marker** — `-End of Document-` on a **dedicated last page**, vertically centered via page break + empty spacers, horizontally centered (F37 Ginger, bold, 40pt)

### Document Information table

| Field | Example |
|-------|---------|
| Unique Reference Number (URN) | `ASNI-000001` (prefix is always `ASNI-`; increment the six-digit suffix per document) |
| Information Type | Set from document purpose; see table below |
| Keywords/Metadata | Comma-separated tags |

**Information Type rule:** Replace the template placeholder `Template` on every build. Choose the type that matches what the document actually is:

| Document purpose | Information Type |
|------------------|------------------|
| Word template or style reference | `Template` |
| Interface / protocol definition | `ICD` |
| End-user operation instructions | `User Guide` |
| Installation or field deployment steps | `Installation Manual` |
| Engineering specification or requirements | `Engineering Specification` |
| Benefits, technology overview, or market-facing analysis | `White Paper` |
| Internal how-to or process description | `Technical Note` |
| Test or sample document built to validate formatting | `Template Test` |

When none of the above fits exactly, pick the closest match and keep the label short (one to three words, title case).

Also update `docProps/core.xml` (`dc:subject`, `cp:category`) when building programmatically so file properties match the Document Information table.

**URN rule:** Every corporate document uses the `ASNI-` prefix. Replace the template placeholder `ASICD-000001` in the Document Information table **and** the footer document ID cell. Do not use other prefixes (`ASICD-`, `ASMAN-`, `ASTST-`, etc.) unless the user explicitly overrides.

### Admonition blocks (notes, warnings)

The template includes icon + label rows for:

- **Danger**, **Warning**, **Caution**, **Important**, **Note**

Copy an existing admonition table from the template when adding new callouts. Do not invent plain-text-only warnings; use the icon table pattern.

### Tables

| Table style ID | Use for |
|----------------|---------|
| `TableGrid` | General bordered tables |
| `TableGrid2`–`TableGrid6` | Variant layouts in template |
| `Tableheader` | Header row paragraph style |
| `Tabletext` | Body row paragraph style |

Use **Table Grid** as default. Apply `Tableheader` to header cells and `Tabletext` to body cells.

### Figures

- Insert images in body; add **Caption** style labels (`Figure N: …`) with Figure SEQ fields.
- When one or more captioned figures exist, keep the **Index of Figures** section and clear stale template entries inside the field.
- When no figures exist, remove the Index of Figures section entirely.

### Captioned tables (body)

- Add **Caption** style labels (`Table N: …`) with Table SEQ fields below body tables that should appear in the index.
- Front-matter tables (Document Information, Review History, Review & Approval) are **not** indexed.
- When one or more captioned body tables exist, keep the **Index of Tables** section and clear stale template entries.
- When no captioned body tables exist, remove the Index of Tables section entirely.

### End of document page

The `-End of Document-` marker is not inline body text. It sits alone on the final page:

1. Page break before the end section
2. ~20 empty spacer paragraphs (vertical centering)
3. Centered `-End of Document-` paragraph
4. Trailing empty paragraph, then `sectPr`

---

## Build workflow

1. Copy `templates/all-space-corporate.docx` to the output workspace.
2. Read content with `python -m markitdown working-copy.docx` (or `pandoc` if available).
3. Follow [editing.md](../editing.md): unpack → replace content → update footer metadata → pack.
4. Validate: `python scripts/office/validate.py output.docx`
5. Check for leftover placeholder text (Hydra Max 2, `ASICD-000001`, sample author names). Confirm URN reads `ASNI-` in the Document Information table **and** the footer. Confirm Information Type is not still `Template` unless the file is a template.

---

## Do / don't

**Do**

- Start from `templates/all-space-corporate.docx` for every `/as-docx` request
- Use built-in Word styles (`Heading1`, `Heading2`, `Normal`, `Tableheader`, etc.)
- Keep footer document ID, date, and revision current — URN prefix is always `ASNI-`
- Use admonition table patterns for notes and warnings
- Preserve header logo and footer table structure
- Rebuild the Table of Contents for new headings (clear stale Hydra sample entries)
- Include Index of Figures only when captioned figures exist in the body
- Include Index of Tables only when captioned body tables exist
- Put `-End of Document-` on its own last page with page break and spacer paragraphs
- Use blank spacer paragraphs between body content blocks

**Don't**

- Build corporate documents from scratch with docx-js unless explicitly requested
- Change page size to US Letter (template is A4)
- Remove `UNCONTROLLED WHEN DISTRIBUTED` without user instruction
- Replace footer table with simplified text (breaks pagination layout)
- Use unicode bullet characters; use Word list styles / numbering from template
- Reuse `numId 2` for a second bullet list without allocating a new `numId` in `numbering.xml`
- Leave Index of Figures or Index of Tables with Hydra template placeholder entries when the document has no figures or captioned tables
- Append `-End of Document-` immediately after the last body paragraph (it must be on its own page)
- Leave Information Type as `Template` on finished documents
- Use other URN prefixes (`ASICD-`, `ASMAN-`, `ASTST-`, etc.) — corporate documents always use `ASNI-`
- Use non-hex RSIDs or paraIds ≥ `0x80000000` in new XML
