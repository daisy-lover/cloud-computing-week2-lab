from __future__ import annotations

from .models import Category, Classification, Priority, Ticket
from .rules import match_category, match_priority


class TicketClassifier:
    """Explainable keyword classifier used by the classroom service."""

    def classify(self, ticket: Ticket) -> Classification:
        category, category_hits = match_category(ticket.text)
        priority, priority_hits = match_priority(ticket.text)

        reasons: list[str] = []
        if category_hits:
            reasons.append(f"分类命中: {', '.join(category_hits)}")
        else:
            reasons.append("未命中分类关键词，归入 other")
        if priority_hits:
            reasons.append(f"优先级命中: {', '.join(priority_hits)}")
        else:
            reasons.append("未命中升降级关键词，使用 normal")

        confidence = self._confidence(category, category_hits, priority_hits)
        return Classification(
            ticket_id=ticket.ticket_id,
            category=category,
            priority=priority,
            confidence=confidence,
            reasons=tuple(reasons),
        )

    def classify_text(
        self, text: str, ticket_id: str = "preview", channel: str = "cli"
    ) -> Classification:
        return self.classify(Ticket(ticket_id, text, channel))

    @staticmethod
    def _confidence(
        category: Category,
        category_hits: tuple[str, ...],
        priority_hits: tuple[str, ...],
    ) -> float:
        if category is Category.OTHER:
            return 0.25
        base = min(0.55 + 0.1 * len(category_hits), 0.9)
        return min(base + 0.03 * len(priority_hits), 0.96)

    @staticmethod
    def priority_label(priority: Priority) -> str:
        return {
            Priority.LOW: "低",
            Priority.NORMAL: "普通",
            Priority.HIGH: "高",
            Priority.URGENT: "紧急",
        }[priority]

