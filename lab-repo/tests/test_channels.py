import unittest

from ticketflow.channels import normalize_email_ticket, normalize_web_ticket


class ChannelTests(unittest.TestCase):
    def test_email_subject_and_body(self) -> None:
        self.assertEqual(
            normalize_email_ticket(" 发票问题 ", " 需要开票 "),
            "发票问题\n\n需要开票",
        )

    def test_web_message_is_compacted(self) -> None:
        self.assertEqual(
            normalize_web_ticket("  登录   失败  ", "settings"),
            "[来源页面: settings] 登录 失败",
        )


if __name__ == "__main__":
    unittest.main()

