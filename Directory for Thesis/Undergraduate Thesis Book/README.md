# Undergraduate Thesis Book

This folder contains the full thesis-book version of the complaint classification research.

## Main files

- `thesis_book.tex` - main LaTeX source
- `thesis_book.pdf` - compiled thesis PDF
- `figures/` - generated/result figures used in the thesis

## Compile command

Use LuaLaTeX so Bengali text renders correctly:

```bash
TEXMFVAR=/tmp/texmf-var TEXMFCACHE=/tmp/texmf-cache lualatex -interaction=nonstopmode thesis_book.tex
TEXMFVAR=/tmp/texmf-var TEXMFCACHE=/tmp/texmf-cache lualatex -interaction=nonstopmode thesis_book.tex
```

The second pass resolves the table of contents, citations, figure references, and table references.
