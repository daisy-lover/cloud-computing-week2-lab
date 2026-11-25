from __future__ import annotations


def normalize_web_ticket(message: str, page: str | None = None) -> str:
    message = " ".join(message.split())
    if page:
        return f"[来源页面: {page}] {message}"
    return message

