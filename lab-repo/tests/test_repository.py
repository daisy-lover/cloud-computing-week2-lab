import tempfile
import unittest
from pathlib import Path

from ticketflow.errors import DuplicateTicketError, StorageError
from ticketflow.models import Ticket
from ticketflow.repository import JsonlTicketRepository


class RepositoryTests(unittest.TestCase):
    def test_round_trip(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repository = JsonlTicketRepository(Path(temp_dir) / "tickets.jsonl")
            ticket = Ticket("t-1", "发票抬头错误", "email")
            repository.add(ticket)
            self.assertEqual(repository.list_all(), [ticket])
            self.assertEqual(repository.get("t-1"), ticket)

    def test_duplicate_id_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            repository = JsonlTicketRepository(Path(temp_dir) / "tickets.jsonl")
            ticket = Ticket("same-id", "账号无法登录", "web")
            repository.add(ticket)
            with self.assertRaises(DuplicateTicketError):
                repository.add(ticket)

    def test_malformed_json_is_reported_with_line(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            path = Path(temp_dir) / "tickets.jsonl"
            path.write_text("{this is not json}\n", encoding="utf-8")
            repository = JsonlTicketRepository(path)
            with self.assertRaisesRegex(StorageError, "第 1 行"):
                repository.list_all()


if __name__ == "__main__":
    unittest.main()

