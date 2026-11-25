import contextlib
import io
import tempfile
import unittest
from pathlib import Path

from ticketflow.cli import build_parser, main


class CliTests(unittest.TestCase):
    def test_parser_has_public_commands(self) -> None:
        help_text = build_parser().format_help()
        for command in ("add", "classify", "summary", "serve"):
            self.assertIn(command, help_text)

    def test_classify_does_not_write_data_file(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            data_path = Path(temp_dir) / "tickets.jsonl"
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                code = main(
                    [
                        "--data",
                        str(data_path),
                        "classify",
                        "退款一直没有到账",
                    ]
                )
            self.assertEqual(code, 0)
            self.assertFalse(data_path.exists())
            self.assertIn('"category": "billing"', output.getvalue())


if __name__ == "__main__":
    unittest.main()

