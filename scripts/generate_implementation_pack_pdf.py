#!/usr/bin/env python3
"""
Generate board-ready PDFs for WCS Agentic:
  - WCS_Agentic_Operations_Manual.pdf
  - WCS_Implementation_Pack.pdf (manual + Swift/Vapor starter sources)

Requires: .venv-pdf with reportlab (see docs/pdf/README.md)
"""

from __future__ import annotations

import copy
import re
import textwrap
from datetime import date
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    PageBreak,
    Paragraph,
    Preformatted,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "pdf"
MANUAL_MD_DIR = ROOT / "docs" / "production-operating-manual"
PLAYBOOK_DIR = ROOT / "docs" / "playbook"
IMPL_DIR = ROOT / "implementation-pack"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def collect_manual_markdown() -> str:
    parts = [
        read(MANUAL_MD_DIR / "README.md"),
        read(MANUAL_MD_DIR / "01-case-study-operating-model.md"),
        read(MANUAL_MD_DIR / "02-universal-control-stack.md"),
        read(MANUAL_MD_DIR / "03-production-architecture.md"),
        read(MANUAL_MD_DIR / "04-rollout-maturity-model.md"),
        read(MANUAL_MD_DIR / "workflows" / "01-participant-onboarding.md"),
        read(MANUAL_MD_DIR / "workflows" / "02-learning-path-concierge.md"),
        read(MANUAL_MD_DIR / "workflows" / "03-certificate-operations.md"),
        read(MANUAL_MD_DIR / "workflows" / "04-research-and-campaign.md"),
        read(PLAYBOOK_DIR / "governance.md"),
        read(PLAYBOOK_DIR / "raci-and-metrics.md"),
        read(PLAYBOOK_DIR / "architecture-patterns.md"),
    ]
    extra = EXECUTIVE_AND_CHECKLISTS.format(today=date.today().isoformat())
    return extra + "\n\n---\n\n".join(p for p in parts if p.strip())


EXECUTIVE_AND_CHECKLISTS = """# Executive operating model

World Class Scholars adopts a **Swift-first, supervised agentic platform**: bounded automation, explicit workflow state, policy-gated sensitive actions, and full audit trails. Agents coordinate through a central orchestrator; humans approve identity verification, certificate issuance, and external publishing.

**Core principles (from case-study literature)**

1. Coordination must be **constrained**, not merely automated.
2. Every agent has defined scope, fallback path, and audit trail.
3. Sensitive actions (identity, issuance, policy) remain gated until trust and performance thresholds are met.
4. Production systems use explicit state, bounded action spaces, and supervised transitions.

## Swift-first architecture recommendation

| Layer | Technology | Role |
|-------|------------|------|
| iOS client | SwiftUI + SwiftData | Participant & operator UX |
| Domain API | Vapor 4 + Fluent + async/await | System of record, workflows |
| Orchestration | Node/TypeScript (platform/) | Sessions, budgets, handoffs |
| Workers | Python (platform/agents/) | OCR, classification, reasoning |
| Policy | OPA/Rego | Pre/post invocation |
| Data | PostgreSQL + encrypted object store | Participants, audit, documents |

Server-side Swift (Vapor) owns canonical business logic; the orchestrator owns session graphs and does not persist PII long-term.

## Production readiness checklist

| # | Item | Owner | Status |
|---|------|-------|--------|
| 1 | DPIA for onboarding + ID documents | Legal | ☐ |
| 2 | OPA policies in CI with deny tests | Engineering | ☐ |
| 3 | Kill-switch tested in staging | Ops | ☐ |
| 4 | Dual-control certificate issuance enforced | Ops + Eng | ☐ |
| 5 | Audit log retention policy (≥ 1 year) | Security | ☐ |
| 6 | On-call runbook + incident playbook | Ops | ☐ |
| 7 | SAST/DAST in release pipeline | DevSecOps | ☐ |
| 8 | Token budgets per workflow configured | Engineering | ☐ |
| 9 | Human reviewer SLA defined (&lt; 4h business) | Program | ☐ |
| 10 | Pilot KPIs baselined (time-to-ready, precision) | Program | ☐ |
| 11 | Red-team policy bypass exercise | Security | ☐ |
| 12 | Rollback tested (model + policy bundle) | Engineering | ☐ |

## SaaS scaling roadmap

| Phase | Scope | Deliverable |
|-------|-------|-------------|
| 1 | WCS pilot | Onboarding + approval UI |
| 2 | Supervised production | Certificate prep, support triage |
| 3 | Multi-tenant SaaS | Tenant isolation, KMS per tenant, config packs |
| 4 | Partner orgs | Self-serve sandbox, usage billing, SOC2 path |

Generated: {today}
"""


def swift_source_files() -> list[tuple[str, str]]:
    paths = [
        IMPL_DIR / "Package.swift",
        IMPL_DIR / "Dockerfile",
        IMPL_DIR / "docker-compose.yml",
        IMPL_DIR / "README.md",
        IMPL_DIR / "Sources" / "App" / "entrypoint.swift",
        IMPL_DIR / "Sources" / "App" / "configure.swift",
        IMPL_DIR / "Sources" / "App" / "routes.swift",
        IMPL_DIR / "Sources" / "App" / "WCSModels.swift",
        IMPL_DIR / "Sources" / "App" / "Migrations.swift",
    ]
    return [(str(p.relative_to(ROOT)), read(p)) for p in paths if p.exists()]


def format_inline(raw: str) -> str:
    text = escape_xml(raw)
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"`([^`]+)`", r'<font name="Courier" size="8">\1</font>', text)
    # soften links for PDF
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)
    return text


def escape_xml(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def build_styles():
    base = getSampleStyleSheet()
    styles = {
        "title": ParagraphStyle(
            "WCSTitle",
            parent=base["Title"],
            fontSize=22,
            spaceAfter=20,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#0B2545"),
        ),
        "h1": ParagraphStyle(
            "WCSH1",
            parent=base["Heading1"],
            fontSize=16,
            spaceBefore=14,
            spaceAfter=8,
            textColor=colors.HexColor("#0B2545"),
        ),
        "h2": ParagraphStyle(
            "WCSH2",
            parent=base["Heading2"],
            fontSize=13,
            spaceBefore=10,
            spaceAfter=6,
            textColor=colors.HexColor("#134074"),
        ),
        "h3": ParagraphStyle(
            "WCSH3",
            parent=base["Heading3"],
            fontSize=11,
            spaceBefore=8,
            spaceAfter=4,
        ),
        "body": ParagraphStyle(
            "WCSBody",
            parent=base["BodyText"],
            fontSize=9.5,
            leading=13,
            spaceAfter=6,
            wordWrap="LTR",
            splitLongWords=True,
        ),
        "code": ParagraphStyle(
            "WCSCode",
            parent=base["Code"],
            fontName="Courier",
            fontSize=7.5,
            leading=9,
            leftIndent=8,
            backColor=colors.HexColor("#F4F6F8"),
        ),
        "meta": ParagraphStyle(
            "WCSMeta",
            parent=base["Normal"],
            fontSize=9,
            alignment=TA_CENTER,
            textColor=colors.grey,
        ),
    }
    return styles


def parse_table(lines: list[str]) -> Table | None:
    if len(lines) < 2 or "|" not in lines[0]:
        return None
    rows = []
    for line in lines:
        if not line.strip().startswith("|"):
            break
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        rows.append(cells)
    if len(rows) < 2:
        return None
    # skip separator row
    data = [rows[0]] + [r for r in rows[2:] if not all(set(c) <= {"-", ":"} for c in r)]
    if not data:
        data = rows
    col_count = max(len(r) for r in data)
    width = (A4[0] - 4 * cm) / col_count
    t = Table(data, colWidths=[width] * col_count, repeatRows=1)
    t.splitByRow = 1
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#0B2545")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                ("FONTSIZE", (0, 0), (-1, -1), 8),
                ("GRID", (0, 0), (-1, -1), 0.25, colors.grey),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFC")]),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    return t


def markdown_to_story(md: str, styles: dict) -> list:
    story = []
    lines = md.splitlines()
    i = 0
    in_code = False
    code_buf: list[str] = []
    table_buf: list[str] = []

    def flush_table():
        nonlocal table_buf
        if table_buf:
            t = parse_table(table_buf)
            if t:
                story.append(Spacer(1, 6))
                story.append(t)
                story.append(Spacer(1, 8))
            table_buf = []

    while i < len(lines):
        line = lines[i]
        if line.strip().startswith("```"):
            flush_table()
            if in_code:
                story.append(
                    Preformatted(
                        "\n".join(code_buf),
                        styles["code"],
                        maxLineLength=100,
                    )
                )
                story.append(Spacer(1, 8))
                code_buf = []
                in_code = False
            else:
                in_code = True
            i += 1
            continue
        if in_code:
            code_buf.append(line[:120])
            i += 1
            continue
        if line.strip().startswith("|"):
            table_buf.append(line)
            i += 1
            continue
        flush_table()
        if line.startswith("# "):
            story.append(Paragraph(escape_xml(line[2:].strip()), styles["h1"]))
        elif line.startswith("## "):
            story.append(Paragraph(escape_xml(line[3:].strip()), styles["h2"]))
        elif line.startswith("### "):
            story.append(Paragraph(escape_xml(line[4:].strip()), styles["h3"]))
        elif line.strip() in ("---", "***"):
            story.append(Spacer(1, 12))
        elif line.strip().startswith("- "):
            raw = line.strip()[2:]
            wrapped = textwrap.wrap(raw, width=95) or [raw]
            for j, chunk in enumerate(wrapped):
                prefix = "• " if j == 0 else "&nbsp;&nbsp;"
                story.append(Paragraph(prefix + format_inline(chunk), styles["body"]))
        elif line.strip():
            story.append(Paragraph(format_inline(line.strip()), styles["body"]))
        i += 1
    flush_table()
    return story


def make_cover(styles: dict, title: str, subtitle: str) -> list:
    return [
        Spacer(1, 3 * cm),
        Paragraph(title, styles["title"]),
        Spacer(1, 0.5 * cm),
        Paragraph(subtitle, styles["meta"]),
        Spacer(1, 0.3 * cm),
        Paragraph(f"Version 1.0 · {date.today().strftime('%B %Y')}", styles["meta"]),
        Spacer(1, 1 * cm),
        Paragraph(
            "World Class Scholars · Swift-first agentic operations",
            styles["meta"],
        ),
        PageBreak(),
    ]


def build_pdf(path: Path, title: str, subtitle: str, story_parts: list) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    styles = build_styles()
    doc = SimpleDocTemplate(
        str(path),
        pagesize=A4,
        leftMargin=2 * cm,
        rightMargin=2 * cm,
        topMargin=2 * cm,
        bottomMargin=2 * cm,
        title=title,
        author="World Class Scholars",
    )
    story = make_cover(styles, title, subtitle)
    story.extend(story_parts)
    doc.build(story)
    print(f"Wrote {path} ({path.stat().st_size // 1024} KB)")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    manual_md = collect_manual_markdown()
    consolidated_md = OUT_DIR / "wcs_agentic_operations_manual.md"
    consolidated_md.write_text(manual_md, encoding="utf-8")
    print(f"Wrote {consolidated_md}")

    styles = build_styles()
    manual_story = markdown_to_story(manual_md, styles)

    ops_pdf = OUT_DIR / "WCS_Agentic_Operations_Manual.pdf"
    build_pdf(
        ops_pdf,
        "WCS Agentic Operations Manual",
        "Production workflows · Governance · Swift-first architecture",
        manual_story,
    )

    impl_story = markdown_to_story(manual_md, styles)
    impl_story.append(PageBreak())
    impl_story.append(Paragraph("Swift / Vapor implementation pack", styles["h1"]))
    impl_story.append(
        Paragraph(
            "Starter SaaS backend (Vapor 4, Fluent, PostgreSQL). Copy into implementation-pack/.",
            styles["body"],
        )
    )
    for rel, content in swift_source_files():
        impl_story.append(Spacer(1, 10))
        impl_story.append(Paragraph(escape_xml(rel), styles["h2"]))
        impl_story.append(
            Preformatted(
                content[:12000] + ("\n… truncated …" if len(content) > 12000 else ""),
                styles["code"],
                maxLineLength=110,
            )
        )

    pack_pdf = OUT_DIR / "WCS_Implementation_Pack.pdf"
    build_pdf(
        pack_pdf,
        "WCS Implementation Pack",
        "Operations manual + Swift Vapor starter sources",
        impl_story,
    )

    desktop_ops = Path.home() / "Desktop" / ops_pdf.name
    desktop_pack = Path.home() / "Desktop" / pack_pdf.name
    desktop_ops.write_bytes(ops_pdf.read_bytes())
    desktop_pack.write_bytes(pack_pdf.read_bytes())
    print(f"Copied to Desktop: {desktop_ops.name}, {desktop_pack.name}")


if __name__ == "__main__":
    main()
