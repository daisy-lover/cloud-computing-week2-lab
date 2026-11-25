from __future__ import annotations


def normalize_email_ticket(subject: str, body: str) -> str:
    subject = subject.strip()
    body = body.strip()
    if not subject:
        return body
    if not body:
        return subject
    return f"{subject}\n\n{body}"

