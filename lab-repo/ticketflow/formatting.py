from __future__ import annotations

import json
from typing import Any


def to_pretty_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True)


def compact_reasons(reasons: tuple[str, ...], width: int = 48) -> str:
    text = "；".join(reasons)
    return text if len(text) <= width else text[: width - 1] + "…"

