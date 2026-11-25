from __future__ import annotations

from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Any

from .errors import ValidationError


class Category(str, Enum):
    BILLING = "billing"
    DELIVERY = "delivery"
    ACCOUNT = "account"
    PRODUCT = "product"
    OTHER = "other"


class Priority(int, Enum):
    LOW = 1
    NORMAL = 2
    HIGH = 3
    URGENT = 4


@dataclass(frozen=True, slots=True)
class Ticket:
    ticket_id: str
    text: str
    channel: str
    created_at: str = field(
        default_factory=lambda: datetime.now(timezone.utc).isoformat()
    )

    def __post_init__(self) -> None:
        if not self.ticket_id.strip():
            raise ValidationError("ticket_id 不能为空")
        if not self.text.strip():
            raise ValidationError("text 不能为空")
        if not self.channel.strip():
            raise ValidationError("channel 不能为空")

    def to_dict(self) -> dict[str, str]:
        return asdict(self)

    @classmethod
    def from_dict(cls, value: dict[str, Any]) -> Ticket:
        try:
            return cls(
                ticket_id=str(value["ticket_id"]),
                text=str(value["text"]),
                channel=str(value["channel"]),
                created_at=str(value["created_at"]),
            )
        except KeyError as exc:
            raise ValidationError(f"工单缺少字段: {exc.args[0]}") from exc


@dataclass(frozen=True, slots=True)
class Classification:
    ticket_id: str
    category: Category
    priority: Priority
    confidence: float
    reasons: tuple[str, ...]

    def to_dict(self) -> dict[str, Any]:
        return {
            "ticket_id": self.ticket_id,
            "category": self.category.value,
            "priority": self.priority.value,
            "confidence": round(self.confidence, 3),
            "reasons": list(self.reasons),
        }

