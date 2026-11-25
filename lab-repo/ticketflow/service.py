from __future__ import annotations

from collections import Counter
from dataclasses import dataclass

from .classifier import TicketClassifier
from .models import Classification, Ticket
from .repository import JsonlTicketRepository


@dataclass(frozen=True, slots=True)
class ServiceSummary:
    total: int
    by_category: dict[str, int]
    by_priority: dict[int, int]


class TicketService:
    def __init__(
        self,
        repository: JsonlTicketRepository,
        classifier: TicketClassifier | None = None,
    ) -> None:
        self.repository = repository
        self.classifier = classifier or TicketClassifier()

    def create(self, ticket: Ticket) -> Classification:
        self.repository.add(ticket)
        return self.classifier.classify(ticket)

    def classify_saved(self, ticket_id: str) -> Classification | None:
        ticket = self.repository.get(ticket_id)
        return None if ticket is None else self.classifier.classify(ticket)

    def classify_all(self) -> list[Classification]:
        return [
            self.classifier.classify(ticket)
            for ticket in self.repository.list_all()
        ]

    def summary(self) -> ServiceSummary:
        records = self.classify_all()
        categories = Counter(item.category.value for item in records)
        priorities = Counter(item.priority.value for item in records)
        return ServiceSummary(
            total=len(records),
            by_category=dict(sorted(categories.items())),
            by_priority=dict(sorted(priorities.items())),
        )

