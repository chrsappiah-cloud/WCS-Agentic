#!/usr/bin/env python3
"""Build WCS_Implementation_Pack.pdf from markdown and scaffold sources."""

from __future__ import annotations

import json
from pathlib import Path

from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.platypus import PageBreak, Paragraph, Preformatted, SimpleDocTemplate, Spacer

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "implementation-pack"
OUT = ROOT / "output"
OUT.mkdir(exist_ok=True)

source_files = [
    SOURCE_DIR / "wcs_agentic_operations_manual.md",
    SOURCE_DIR / "README.md",
    SOURCE_DIR / "Package.swift",
    SOURCE_DIR / "docker-compose.yml",
    SOURCE_DIR / "Dockerfile",
    SOURCE_DIR / "Sources" / "App" / "entrypoint.swift",
    SOURCE_DIR / "Sources" / "App" / "configure.swift",
    SOURCE_DIR / "Sources" / "App" / "routes.swift",
    SOURCE_DIR / "Sources" / "App" / "WCSModels.swift",
    SOURCE_DIR / "Sources" / "App" / "Migrations.swift",
]


def main() -> None:
    story = []
    styles = getSampleStyleSheet()
    styles.add(
        ParagraphStyle(
            name="MonoSmall",
            fontName="Courier",
            fontSize=8,
            leading=10,
            alignment=TA_LEFT,
        )
    )
    styles.add(
        ParagraphStyle(
            name="Heading",
            fontName="Helvetica-Bold",
            fontSize=14,
            leading=18,
            spaceAfter=8,
        )
    )
    styles.add(
        ParagraphStyle(
            name="SubHeading",
            fontName="Helvetica-Bold",
            fontSize=11,
            leading=14,
            spaceAfter=6,
        )
    )

    for i, path in enumerate(source_files):
        rel = path.relative_to(ROOT) if path.is_relative_to(ROOT) else path
        story.append(Paragraph(str(rel), styles["Heading"]))
        if path.exists():
            text = path.read_text(encoding="utf-8", errors="ignore")
            if path.suffix == ".md":
                for block in text.split("\n\n"):
                    block = block.strip("\n")
                    if not block:
                        continue
                    if block.lstrip().startswith("#"):
                        first_line = block.split("\n", 1)[0]
                        title = first_line.lstrip("#").strip()
                        story.append(Paragraph(title, styles["SubHeading"]))
                        rest = block[len(first_line) :].lstrip("\n")
                        if rest:
                            story.append(Preformatted(rest, styles["MonoSmall"]))
                    else:
                        story.append(Preformatted(block, styles["MonoSmall"]))
                    story.append(Spacer(1, 6))
            else:
                story.append(Preformatted(text, styles["MonoSmall"]))
        else:
            story.append(Paragraph("File not found.", styles["MonoSmall"]))
        if i != len(source_files) - 1:
            story.append(PageBreak())

    pdf_path = OUT / "WCS_Implementation_Pack.pdf"
    doc = SimpleDocTemplate(
        str(pdf_path),
        pagesize=A4,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36,
    )
    doc.build(story)
    meta = {
        "caption": "WCS Implementation Pack PDF",
        "description": (
            "Combined PDF containing the operating manual and Swift SaaS starter "
            "files for easy implementation."
        ),
    }
    pdf_path.with_suffix(".pdf.meta.json").write_text(
        json.dumps(meta, indent=2), encoding="utf-8"
    )
    print(pdf_path)


if __name__ == "__main__":
    main()
