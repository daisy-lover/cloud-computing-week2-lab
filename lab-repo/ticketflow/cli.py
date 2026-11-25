from __future__ import annotations

import argparse
import json
import uuid
from pathlib import Path

from .classifier import TicketClassifier
from .errors import TicketFlowError
from .models import Ticket
from .repository import JsonlTicketRepository
from .service import TicketService


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="ticketflow",
        description="课堂用客服工单分类服务",
    )
    parser.add_argument(
        "--data",
        default="data/tickets.jsonl",
        type=Path,
        help="JSONL 数据文件，默认 data/tickets.jsonl",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    add_parser = subparsers.add_parser("add", help="创建一张工单")
    add_parser.add_argument("text", help="工单正文")
    add_parser.add_argument("--channel", default="cli")

    classify_parser = subparsers.add_parser("classify", help="试分类，不落盘")
    classify_parser.add_argument("text", help="工单正文")
    classify_parser.add_argument("--channel", default="cli")

    subparsers.add_parser("summary", help="统计已保存工单")

    serve_parser = subparsers.add_parser("serve", help="批量输出分类结果")
    serve_parser.add_argument("--limit", type=int, default=20)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    repository = JsonlTicketRepository(args.data)
    service = TicketService(repository)

    try:
        if args.command == "classify":
            result = TicketClassifier().classify_text(args.text, channel=args.channel)
            print(json.dumps(result.to_dict(), ensure_ascii=False, indent=2))
            return 0

        if args.command == "add":
            ticket = Ticket(
                ticket_id=uuid.uuid4().hex,
                text=args.text,
                channel=args.channel,
            )
            result = service.create(ticket)
            print(json.dumps(result.to_dict(), ensure_ascii=False, indent=2))
            return 0

        if args.command == "summary":
            summary = service.summary()
            print(
                json.dumps(
                    {
                        "total": summary.total,
                        "by_category": summary.by_category,
                        "by_priority": {str(k): v for k, v in summary.by_priority.items()},
                    },
                    ensure_ascii=False,
                    indent=2,
                )
            )
            return 0

        if args.command == "serve":
            for record in service.classify_all()[: args.limit]:
                print(json.dumps(record.to_dict(), ensure_ascii=False))
            return 0

        return 2
    except TicketFlowError as exc:
        print(f"ticketflow: {exc}")
        return 1

