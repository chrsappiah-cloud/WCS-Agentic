#!/usr/bin/env python3
"""Materialize the World Class Scholars founder governance pack.

The source PDF instructs WCS to split the consolidated founder pack into
controlled Markdown files, maintain document control metadata, and enforce
review through code-owner paths. This script keeps that work repeatable.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GOV_ROOT = ROOT / "docs" / "governance"

COMPANY = "World Class Scholars Pty Ltd"
PUBLIC_URL = "https://worldclassscholars.vercel.app"
PRIMARY_CONTACT = "chrsappiah@gmail.com"
ORG_CONTACT = "christopher.appiahthompson@myworldclass.org"
EFFECTIVE_DATE = "29 May 2026"
NEXT_REVIEW_DATE = "29 May 2027"
REPOSITORY = "WCS-Governance"


@dataclass(frozen=True)
class GovernanceDocument:
    doc_id: str
    title: str
    doc_type: str
    folder: str
    owner: str
    approver: str
    confidentiality: str
    sections: list[tuple[str, str]]

    @property
    def filename(self) -> str:
        return f"{self.doc_id} - {self.title}.md"

    @property
    def path(self) -> Path:
        return GOV_ROOT / "docs" / self.folder / self.filename


def cover(doc: GovernanceDocument) -> str:
    return f"""# {COMPANY}

## {doc.title}

**Document ID:** {doc.doc_id}

**Document Type:** {doc.doc_type}

**Version:** v1.0

**Status:** Draft

**Effective Date:** {EFFECTIVE_DATE}

**Next Review Date:** {NEXT_REVIEW_DATE}

**Owner:** {doc.owner}

**Author:** Founder / CEO with AI-assisted drafting support

**Approver(s):** {doc.approver}

**Confidentiality:** {doc.confidentiality}

**Primary Contact:** {PRIMARY_CONTACT}

**Company Contact:** {ORG_CONTACT}

**Website:** {PUBLIC_URL}

> This document is controlled in the `{REPOSITORY}` repository. Printed or downloaded copies are uncontrolled.

## Document Control

| Field | Value |
|---|---|
| Document Title | {doc.title} |
| Document ID | {doc.doc_id} |
| Repository | {REPOSITORY} |
| File Path | docs/{doc.folder}/{doc.filename} |
| Owner | {doc.owner} |
| Author | Founder / CEO with AI-assisted drafting support |
| Approver | {doc.approver} |
| Version | v1.0 |
| Status | Draft |
| Effective Date | {EFFECTIVE_DATE} |
| Last Amended Date | {EFFECTIVE_DATE} |
| Next Review Date | {NEXT_REVIEW_DATE} |

## Version History

| Version | Date | Author | Summary of Changes | Approver | Git Ref |
|---|---|---|---|---|---|
| v0.1 | 2026-05-29 | AI-assisted draft | Initial split from founder documentation pack | - | pending |
| v1.0 | 2026-05-29 | Founder / CEO | Baseline controlled draft | {doc.approver} | pending |

"""


def render(doc: GovernanceDocument) -> str:
    body = cover(doc)
    for heading, text in doc.sections:
        body += f"## {heading}\n\n{text.strip()}\n\n"
    body += """## Review Gate

This draft must be reviewed by the named owner and approver before production use. Legal, tax, privacy, security and accounting content must be reviewed by qualified Australian advisers where applicable.
"""
    return body


DOCS: list[GovernanceDocument] = [
    GovernanceDocument(
        "WCS-GOV-CONSTITUTION",
        "Company Constitution",
        "Charter / Constitutional Draft",
        "charters",
        "Founder / CEO",
        "Board of Directors",
        "Confidential",
        [
            ("Name and Status", "The company is World Class Scholars Pty Ltd, a proprietary company limited by shares registered under the Corporations Act 2001 (Cth)."),
            ("Objects", "The company may develop, operate and commercialise educational technology platforms, digital course products, software services and related activities."),
            ("Share Capital", "The Board maintains member registers and records all share issues, transfers and cancellations. Share terms should align with any shareholder agreement."),
            ("Directors and Board Powers", "The business is managed by or under the direction of the Board. Directors must observe duties of care, diligence, good faith, proper purpose and conflict disclosure."),
            ("Meetings and Records", "General meetings, board meetings, notices, proxies, quorums, circular resolutions, statutory registers and financial records must comply with Australian law."),
        ],
    ),
    GovernanceDocument(
        "WCS-IP-ASSIGN-FOUNDER",
        "IP Assignment Deed Founder to Company",
        "Agreement",
        "contracts",
        "Founder / CEO",
        "Board of Directors",
        "Confidential",
        [
            ("Parties", "The assignor is the founder and the assignee is World Class Scholars Pty Ltd."),
            ("Assigned IP", "Assigned IP covers software source code, object code, repositories, databases, product designs, branding, trade marks, course content, audiovisual assets, domains, documentation, workflows, know-how and improvements."),
            ("Assignment", "All existing right, title and interest in the assigned IP transfers to the company on the effective date. Future IP created for the company is also assigned or held on trust pending formal assignment."),
            ("Warranties and Moral Rights", "The founder warrants ownership, no conflicting grants and no known infringement claims, and gives moral-rights consents to the fullest extent permitted by Australian law."),
            ("Further Assurance", "The founder must assist with registrations, trade marks, domain transfers, diligence requests and enforcement steps."),
        ],
    ),
    GovernanceDocument(
        "WCS-GOV-BOARD-CHARTER",
        "Board Charter",
        "Charter",
        "charters",
        "Board Chair",
        "Board of Directors",
        "Internal",
        [
            ("Purpose", "The Board Charter defines the role and responsibilities of the Board, the relationship between the Board and management, and the expected standard of governance."),
            ("Core Responsibilities", "The Board approves strategy, budgets, risk appetite, major transactions, capital decisions, policies and executive oversight."),
            ("Composition", "The Board should include founder, investor and independent skills as the company scales. The Chair leads the Board and the CEO manages day-to-day operations within delegated limits."),
            ("Meetings and Information Flow", "The Board meets at least quarterly, receives papers in advance, maintains minutes and tracks action registers."),
            ("Conduct and Conflicts", "Directors act in the best interests of the company, disclose conflicts and comply with statutory duties."),
        ],
    ),
    GovernanceDocument(
        "WCS-GOV-DOA-POL",
        "Delegations of Authority Policy",
        "Policy",
        "policies",
        "Founder / CEO",
        "Board of Directors",
        "Internal",
        [
            ("Purpose", "This policy defines authority for expenditure, contract execution and operational approvals."),
            ("Principles", "Authority is role-based, must remain within approved budgets and policies, and must not be split to evade approval thresholds."),
            ("Board Reserved Matters", "Reserved matters include constitutional changes, budgets, share or option issues, financing, large transactions, key policies and material strategic changes."),
            ("Delegation Rules", "The CEO may approve expenditure within approved budgets up to board-approved limits. Non-standard, high-risk or material contracts require legal or board review."),
            ("Audit Trail", "Approvals must preserve decision maker, amount, counterparty, date, evidence and rationale."),
        ],
    ),
    GovernanceDocument(
        "WCS-PRIV-PRIVACY-POL",
        "Privacy Policy",
        "Policy",
        "policies",
        "Privacy Lead",
        "Board of Directors",
        "Public",
        [
            ("Scope", "This policy covers students, parents, guardians, teachers, school administrators, institutional customers, users and website visitors."),
            ("Information Collected", "Collected information may include contact details, account credentials, subscription data, learning data, support interactions, analytics, device metadata and lawful limited sensitive information."),
            ("Use", "Information is used to provide services, personalise learning, support customers, improve functionality, secure the platform and meet legal obligations."),
            ("Disclosure and Security", "The company may use service providers and reasonable safeguards including access controls, encryption, monitoring and vendor review. Absolute security is not guaranteed."),
            ("Rights and Complaints", f"Privacy requests and complaints can be sent to {ORG_CONTACT} or {PRIMARY_CONTACT}. Users may escalate unresolved complaints to the OAIC where applicable."),
        ],
    ),
    GovernanceDocument(
        "WCS-SaaS-TOS",
        "SaaS Terms of Service",
        "Agreement",
        "contracts",
        "Founder / CEO",
        "Board of Directors",
        "Public",
        [
            ("Acceptance", f"Users and customers accept these terms by creating an account, accepting an order form or using {PUBLIC_URL}. A person accepting for an organisation warrants authority to bind it."),
            ("Services", "World Class Scholars provides educational technology services, software access, support and related documentation during the subscription or pilot term."),
            ("User Responsibilities", "Customers are responsible for authorised users, lawful use, credential security, data accuracy and compliance with documentation."),
            ("Acceptable Use", "Unlawful use, infringement, interference, unauthorised access attempts and reverse engineering are prohibited except where law requires otherwise."),
            ("Fees and Termination", "Fees, billing cycles, renewals, suspension rights, cure periods and exit data handling must be set out in order forms or applicable schedules."),
            ("IP and Data", "The company owns the platform. Customers retain customer data subject to the rights needed to provide, secure and improve the service."),
        ],
    ),
    GovernanceDocument(
        "WCS-SEC-INF-SEC-POL",
        "Information Security Policy",
        "Policy",
        "policies",
        "Security Lead",
        "Board of Directors",
        "Internal",
        [
            ("Purpose", "Protect confidentiality, integrity and availability of company information assets across systems, data stores, cloud services and devices."),
            ("Governance", "The Board oversees security risk appetite and management maintains controls, risk assessment and remediation."),
            ("Access Control", "Access follows least privilege and need-to-know principles. Critical systems require unique accounts and MFA."),
            ("Secure Development", "Secure coding, testing, change control, dependency management, logging and monitoring are required for production systems."),
            ("Third Parties and Training", "Vendors handling data require security assessment and contractual controls. Staff and contractors receive security awareness training."),
        ],
    ),
    GovernanceDocument(
        "WCS-PRIV-DATA-RET-POL",
        "Data Retention and Deletion Policy",
        "Policy",
        "policies",
        "Privacy Lead",
        "Board of Directors",
        "Internal",
        [
            ("Purpose", "Retain information only as long as necessary for legal, regulatory, contractual and business reasons, then securely dispose of or anonymise it."),
            ("Retention Schedule", "The schedule covers customer records, student data, coursework, logs, analytics, financial records and HR records. Australian financial and tax records are commonly retained for at least seven years."),
            ("Legal Holds", "Deletion pauses where litigation, investigation, audit or other lawful hold applies."),
            ("Deletion Requests", f"Deletion requests are handled through {ORG_CONTACT} or {PRIMARY_CONTACT}, subject to lawful retention overrides."),
            ("Evidence", "Deletion and anonymisation should be documented and auditable where technically possible."),
        ],
    ),
    GovernanceDocument(
        "WCS-SEC-IR-POL",
        "Incident Response Policy",
        "Policy",
        "policies",
        "Incident Commander",
        "Board of Directors",
        "Internal",
        [
            ("Purpose", "Enable the company to detect, respond to and recover from cyber, privacy and major availability incidents."),
            ("Roles", "The response team includes Incident Commander, Technical Lead, Communications Lead, Legal or Privacy Lead and Scribe."),
            ("Lifecycle", "The response lifecycle is identification, containment, eradication, recovery, notification and post-incident review."),
            ("Severity", "SEV-1, SEV-2 and SEV-3 levels align urgency to business impact."),
            ("Escalation Contacts", f"Initial incident escalation contacts are {ORG_CONTACT} and {PRIMARY_CONTACT}."),
        ],
    ),
    GovernanceDocument(
        "WCS-HR-CONTRACTOR-AGR",
        "Contractor Agreement Template",
        "Agreement Template",
        "contracts",
        "Founder / CEO",
        "Legal Adviser",
        "Confidential",
        [
            ("Engagement", "The agreement identifies the contractor, services, deliverables, milestones, acceptance expectations and term."),
            ("Fees and Status", "The agreement states rates, invoicing, GST treatment, expenses and payment timing, and clarifies independent contractor status."),
            ("IP", "IP created during the engagement vests in or is assigned to the company, subject to express carve-outs for pre-existing contractor IP."),
            ("Confidentiality and Security", "Contractors comply with confidentiality, privacy, security and incident reporting obligations."),
            ("Termination", "Termination may occur for convenience on notice or immediately for material breach or misconduct. Exit requires return or destruction of confidential information."),
        ],
    ),
    GovernanceDocument(
        "WCS-SaaS-PILOT-AGR",
        "Pilot Agreement Template",
        "Agreement Template",
        "contracts",
        "Founder / CEO",
        "Legal Adviser",
        "Confidential",
        [
            ("Scope", "The pilot schedule describes services, users, duration, environments, evaluation objectives and whether the pilot is free, discounted or paid."),
            ("Responsibilities", "WCS handles setup, onboarding and defined support. Customers manage user onboarding, readiness, consent and supervision obligations."),
            ("Data and Privacy", "The agreement identifies processing roles, data categories, deletion, export and end-of-pilot treatment."),
            ("Support", "Pilot support levels are separate from production SLA commitments."),
            ("Outcomes", "The pilot ends in conversion, extension or orderly wind-down with data access and deletion timelines."),
        ],
    ),
    GovernanceDocument(
        "WCS-FIN-BUDGET-12M",
        "12 Month Budget",
        "Finance Model",
        "finance",
        "Finance Manager",
        "Board of Directors",
        "Confidential",
        [
            ("Purpose", "The annual budget is the board-approved baseline for runway, commitments and financing needs."),
            ("Assumptions", "Include revenue assumptions, staffing plans, cloud and software costs, contractor costs, marketing, legal and compliance spend."),
            ("Scenario Analysis", "Maintain base, upside and downside cases with clear assumptions and sensitivity triggers."),
            ("Approvals", "Board approval is required for the baseline and material deviations."),
            ("Automation Hook", "The Finance AI backend should compare actual records and generated reports against this baseline when producing board packs."),
        ],
    ),
    GovernanceDocument(
        "WCS-FIN-CF-13W",
        "13 Week Cashflow Model",
        "Finance Model",
        "finance",
        "Finance Manager",
        "Board of Directors",
        "Confidential",
        [
            ("Purpose", "The rolling 13-week cashflow model monitors liquidity and provides early warning for board intervention."),
            ("Structure", "Track expected receipts and payments by week, including payroll, vendors, taxes and financing inflows."),
            ("Update Cycle", "Refresh weekly and reconcile to bank, invoices, payroll and funding events."),
            ("Triggers", "Escalate to the Board if runway or committed cash coverage falls below approved thresholds."),
            ("Automation Hook", "The Finance AI backend should surface exceptions and board decisions required in generated reports."),
        ],
    ),
]


def write_readme() -> None:
    paths = {
        "Charters": [doc for doc in DOCS if doc.folder == "charters"],
        "Policies": [doc for doc in DOCS if doc.folder == "policies"],
        "Contracts and Templates": [doc for doc in DOCS if doc.folder == "contracts"],
        "Finance": [doc for doc in DOCS if doc.folder == "finance"],
    }
    body = f"""# WCS Governance Repository

This directory is the controlled source for governance documents of {COMPANY}. Printed copies are uncontrolled.

## Live Contacts

| Purpose | Contact |
|---|---|
| Primary founder contact | {PRIMARY_CONTACT} |
| Company operations contact | {ORG_CONTACT} |
| Public website | {PUBLIC_URL} |

## Documents

"""
    for label, docs in paths.items():
        body += f"### {label}\n\n"
        for doc in docs:
            relative = doc.path.relative_to(GOV_ROOT)
            body += f"- [{doc.title}]({relative.as_posix().replace(' ', '%20')})\n"
        body += "\n"
    body += """## Operating Rules

1. Every file uses the WCS document-control header.
2. Changes must be reviewed by the owner and approver named in the file.
3. Legal, tax, privacy, security and accounting content must be reviewed by qualified Australian advisers before production use.
4. Git history is the system of record for line-by-line changes.
5. Generated files can be refreshed with `python3 scripts/materialize_founder_governance_pack.py`.
"""
    (GOV_ROOT / "README.md").write_text(body, encoding="utf-8")


def write_manifest() -> None:
    rows = [
        "# Founder Pack Automation Manifest",
        "",
        "| Document ID | Title | Type | Path | Owner | Approver |",
        "|---|---|---|---|---|---|",
    ]
    for doc in DOCS:
        rows.append(
            f"| {doc.doc_id} | {doc.title} | {doc.doc_type} | docs/{doc.folder}/{doc.filename} | {doc.owner} | {doc.approver} |"
        )
    rows.extend(
        [
            "",
            "## Extracted Implementation Instructions",
            "",
            "- Split the consolidated founder pack into individual Markdown files using the specified document IDs and repository paths.",
            "- Use a standard cover page, document control table and version history for every governance file.",
            "- Maintain a `WCS-Governance` repository structure with `docs/charters`, `docs/policies`, `docs/contracts` and `docs/finance`.",
            "- Use CODEOWNERS and branch protection so governance changes receive owner review before merge.",
            "- Treat the pack as a drafting base, not legal advice; obtain Australian legal, tax, privacy, security and accounting review before production use.",
        ]
    )
    (GOV_ROOT / "FOUNDER_PACK_MANIFEST.md").write_text("\n".join(rows) + "\n", encoding="utf-8")


def write_codeowners() -> None:
    codeowners = f"""# Governance document ownership for World Class Scholars.
# GitHub accepts usernames, teams or emails associated with GitHub accounts.

/docs/governance/                  {ORG_CONTACT} {PRIMARY_CONTACT}
/docs/governance/docs/charters/    {ORG_CONTACT} {PRIMARY_CONTACT}
/docs/governance/docs/policies/    {ORG_CONTACT} {PRIMARY_CONTACT}
/docs/governance/docs/contracts/   {ORG_CONTACT} {PRIMARY_CONTACT}
/docs/governance/docs/finance/     {ORG_CONTACT} {PRIMARY_CONTACT}
"""
    (ROOT / ".github").mkdir(exist_ok=True)
    (ROOT / ".github" / "CODEOWNERS").write_text(codeowners, encoding="utf-8")


def main() -> None:
    for doc in DOCS:
        doc.path.parent.mkdir(parents=True, exist_ok=True)
        doc.path.write_text(render(doc), encoding="utf-8")
    write_readme()
    write_manifest()
    write_codeowners()
    print(f"Materialized {len(DOCS)} governance documents under {GOV_ROOT}")


if __name__ == "__main__":
    main()
