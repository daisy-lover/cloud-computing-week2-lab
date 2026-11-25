from __future__ import annotations

from .models import Category, Priority

CATEGORY_KEYWORDS: dict[Category, tuple[str, ...]] = {
    Category.BILLING: (
        "退款",
        "扣款",
        "发票",
        "支付",
        "账单",
        "续费",
    ),
    Category.DELIVERY: (
        "物流",
        "发货",
        "配送",
        "快递",
        "收货",
    ),
    Category.ACCOUNT: (
        "登录",
        "密码",
        "验证码",
        "账号",
        "注销",
        "实名",
    ),
    Category.PRODUCT: (
        "功能",
        "报错",
        "闪退",
        "升级",
        "兼容",
        "接口",
    ),
}

URGENT_KEYWORDS = ("紧急", "立刻", "无法使用", "数据丢失", "全线故障")
HIGH_KEYWORDS = ("多次", "一直没有", "严重", "影响业务", "重复扣款")
LOW_KEYWORDS = ("建议", "咨询", "希望", "能否", "了解一下")


def match_category(text: str) -> tuple[Category, tuple[str, ...]]:
    normalized = text.lower()
    scores: list[tuple[int, Category, list[str]]] = []
    for category, keywords in CATEGORY_KEYWORDS.items():
        hits = [word for word in keywords if word.lower() in normalized]
        scores.append((len(hits), category, hits))

    score, category, hits = max(scores, key=lambda item: item[0])
    if score == 0:
        return Category.OTHER, ()
    return category, tuple(hits)


def match_priority(text: str) -> tuple[Priority, tuple[str, ...]]:
    if hits := tuple(word for word in URGENT_KEYWORDS if word in text):
        return Priority.URGENT, hits
    if hits := tuple(word for word in HIGH_KEYWORDS if word in text):
        return Priority.HIGH, hits
    if hits := tuple(word for word in LOW_KEYWORDS if word in text):
        return Priority.LOW, hits
    return Priority.NORMAL, ()

