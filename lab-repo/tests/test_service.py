import tempfile
import unittest
from pathlib import Path

from ticketflow.models import Category, Priority, Ticket
from ticketflow.repository import JsonlTicketRepository
from ticketflow.service import TicketService


class ServiceTests(unittest.TestCase):
    def test_create_and_summarize(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repository = JsonlTicketRepository(Path(temp_dir) / "tickets.jsonl")
            service = TicketService(repository)
            service.create(Ticket("t-1", "退款什么时候到账", "web"))
            service.create(Ticket("t-2", "客户端闪退", "cli"))
            summary = service.summary()
            self.assertEqual(summary.total, 2)
            self.assertEqual(summary.by_category["billing"], 1)
            self.assertEqual(summary.by_category["product"], 1)

    def test_missing_ticket_returns_none(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            service = TicketService(
                JsonlTicketRepository(Path(temp_dir) / "tickets.jsonl")
            )
            self.assertIsNone(service.classify_saved("missing"))

    def test_high_priority_is_not_normal(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            service = TicketService(
                JsonlTicketRepository(Path(temp_dir) / "tickets.jsonl")
            )
            result = service.create(Ticket("t-3", "线路严重故障，影响业务", "cli"))
            self.assertIn(result.category, {Category.PRODUCT, Category.OTHER})
            self.assertEqual(result.priority, Priority.HIGH)


if __name__ == "__main__":
    unittest.main()

