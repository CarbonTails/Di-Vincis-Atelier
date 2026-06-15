# All Space Corporate style guide (PowerPoint)

## Theme source (canonical)

**File:** `themes/AllSpace.thmx`

Workspace copy: `c:\Users\linds\.cursor\projects\Inkwell v1\AllSpace.thmx`

This is the correct file type for All Space branding. A `.thmx` file is PowerPoint's native **theme** format. It packages:

- Color scheme (ALLSPACE COMMERCIAL THEME)
- Font scheme (F37 Ginger / F37 Ginger Light)
- **Two slide masters** (dark and light families)
- **42 slide layouts** (title, TOC, dividers, multi-column, image gallery, end slide, and more)

It does **not** contain finished slides — only masters, layouts, and theme definitions.

## Dark vs light: ask first

The theme includes both dark and light layout families (for example layouts named with `Black_Bg` vs `White_Bg`).

**Before building a deck, ask the user:**

> Do you want the **dark** or **light** All Space theme for this presentation?

Do **not** pick dark or light on your own unless the user already stated a preference in the same request.

| Variant | Typical use |
|---------|-------------|
| **Dark** | Title slides, section dividers, closing slides, premium/defence tone |
| **Light** | Dense content slides, tables, multi-column text |
| **Mixed** | Dark for title + section openers; light for body content (common corporate pattern) |

If the user chooses **mixed**, say which slide types get which variant when you plan the deck.

## Color palette

From `AllSpace.thmx` theme:

| Role | Hex | Usage |
|------|-----|--------|
| Background (dark) | `#141432` | Primary dark slide background |
| Background (white) | `#FFFFFF` | Light content slides |
| Primary accent | `#4659E6` | Headlines, icons, diagram highlights |
| Secondary accent | `#B5BDF5` | Soft fills |
| Deep navy panel | `#141450` | Accent panels |
| Muted text | `#A1A1B9` | Captions on dark backgrounds |
| Teal highlight | `#1EE1C8` | Callouts, positive indicators |
| Mint soft | `#A5F3E9` | Light teal fills |

## Typography

| Role | Font |
|------|------|
| Headings / titles | F37 Ginger |
| Body / subtitles | F37 Ginger Light |

Language default: `en-GB`.

## Required footer

Every content slide includes:

```
©{YEAR} ALL.SPACE NETWORKS Ltd. Proprietary and Confidential Information.
```

Update `{YEAR}` to the presentation year.

## Layout library

Pick layouts from the theme — do not repeat one bullet layout for every slide. Layout names in the theme include patterns like:

- `Title Slide`
- `Title, Content Left and Text Right`
- `9Image_Gallery_Black_Bg` / `9Image_Gallery_White_Bg`
- `End Slide`

Use **dark-family layouts** when the user chose dark (or for dividers in a mixed deck). Use **light-family layouts** when the user chose light (or for body slides in a mixed deck).

## Theme vs starter deck

| File | Purpose |
|------|---------|
| `themes/AllSpace.thmx` | Brand source: colors, fonts, masters, layouts |
| `templates/all-space-corporate.pptx` | **Starter deck** for the XML editing pipeline (duplicate slides, replace text, pack) |

The agent editing tools (`unpack.py`, `add_slide.py`, `pack.py`) work on **`.pptx`**, not `.thmx` directly.

**Workflow:**

1. Ask dark / light / mixed.
2. Start from `templates/all-space-corporate.pptx` (must have `AllSpace.thmx` applied and sample slides per layout).
3. If no starter deck exists yet, create one in PowerPoint: **New presentation → Design → Browse themes → AllSpace.thmx → save as `templates/all-space-corporate.pptx`** with one sample slide per key layout.

Do not recreate brand colors or fonts from scratch when the theme file is available.
