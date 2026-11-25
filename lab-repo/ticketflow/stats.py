from __future__ import annotations

from collections.abc import Iterable

from .models import Classification, Priority


def escalation_rate(records: Iterable[Classification]) -> float:
    values = list(records)
    if not values:
        return 0.0
    escalated = sum(item.priority >= Priority.HIGH for item in values)
    return escalated / len(values)


def average_confidence(records: Iterable[Classification]) -> float:
    values = list(records)
    if not values:
        return 0.0
    return sum(item.confidence for item in values) / len(values)

