# WCS Agentic PDF artifacts

Board-ready PDFs generated from the production operating manual, playbook, and Swift implementation pack.

## Files

| File | Description |
|------|-------------|
| [WCS_Agentic_Operations_Manual.pdf](WCS_Agentic_Operations_Manual.pdf) | Full operating manual |
| [WCS_Implementation_Pack.pdf](WCS_Implementation_Pack.pdf) | Manual + Swift/Vapor source listing |
| [wcs_agentic_operations_manual.md](wcs_agentic_operations_manual.md) | Consolidated Markdown source |

## Regenerate

```bash
cd /Applications/WCS-Agentic
python3 -m venv .venv-pdf   # first time only
.venv-pdf/bin/pip install reportlab markdown
.venv-pdf/bin/python scripts/generate_implementation_pack_pdf.py
```

PDFs are also copied to your Desktop.

## Source content

- `docs/production-operating-manual/`
- `docs/playbook/` (governance, RACI, patterns)
- `implementation-pack/` (Swift sources in Implementation Pack PDF only)
