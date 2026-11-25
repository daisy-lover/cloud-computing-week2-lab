from __future__ import annotations

import json
from collections.abc import Iterable
from pathlib import Path

from .errors import DuplicateTicketError, StorageError
from .models import Ticket


class JsonlTicketRepository:
    """Append-only JSONL storage for the classroom demo."""

    def __init__(self, path: str | Path) -> None:
        self.path = Path(path)

    def add(self, ticket: Ticket) -> None:
        if any(item.ticket_id == ticket.ticket_id for item in self.list_all()):
            raise DuplicateTicketError(f"工单已存在: {ticket.ticket_id}")

        try:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            with self.path.open("a", encoding="utf-8", newline="\n") as stream:
                json.dump(ticket.to_dict(), stream, ensure_ascii=False)
                stream.write("\n")
        except OSError as exc:
            raise StorageError(f"无法写入 {self.path}: {exc}") from exc

    def add_many(self, tickets: Iterable[Ticket]) -> int:
        count = 0
        for ticket in tickets:
            self.add(ticket)
            count += 1
        return count

    def list_all(self) -> list[Ticket]:
        if not self.path.exists():
            return []

        try:
            result: list[Ticket] = []
            with self.path.open("r", encoding="utf-8") as stream:
                for line_number, line in enumerate(stream, start=1):
                    if not line.strip():
                        continue
                    try:
                        result.append(Ticket.from_dict(json.loads(line)))
                    except (json.JSONDecodeError, ValueError) as exc:
                        raise StorageError(
                            f"{self.path} 第 {line_number} 行格式错误: {exc}"
                        ) from exc
            return result
        except OSError as exc:
            raise StorageError(f"无法读取 {self.path}: {exc}") from exc

    def get(self, ticket_id: str) -> Ticket | None:
        return next(
            (ticket for ticket in self.list_all() if ticket.ticket_id == ticket_id),
            None,
        )

