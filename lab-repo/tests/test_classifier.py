import unittest

from ticketflow.classifier import TicketClassifier
from ticketflow.models import Category, Priority, Ticket


class ClassifierTests(unittest.TestCase):
    def setUp(self) -> None:
        self.classifier = TicketClassifier()

    def test_delivery_category_and_high_priority(self) -> None:
        ticket = Ticket("t-1", "物流一直没有更新，影响业务", "web")
        result = self.classifier.classify(ticket)
        self.assertEqual(result.category, Category.DELIVERY)
        self.assertEqual(result.priority, Priority.HIGH)
        self.assertGreater(result.confidence, 0.5)

    def test_urgent_billing(self) -> None:
        ticket = Ticket("t-2", "重复扣款两次，请紧急退款", "web")
        result = self.classifier.classify(ticket)
        self.assertEqual(result.category, Category.BILLING)
        self.assertEqual(result.priority, Priority.URGENT)

    def test_unknown_text_falls_back_to_other(self) -> None:
        result = self.classifier.classify_text("收到")
        self.assertEqual(result.category, Category.OTHER)
        self.assertEqual(result.priority, Priority.NORMAL)
        self.assertEqual(result.confidence, 0.25)

    def test_reasons_are_explainable(self) -> None:
        result = self.classifier.classify_text("登录验证码收不到")
        self.assertTrue(any("分类命中" in reason for reason in result.reasons))


if __name__ == "__main__":
    unittest.main()

