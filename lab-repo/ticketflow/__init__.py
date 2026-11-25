"""TicketFlow classroom package."""

from .classifier import TicketClassifier
from .models import Category, Classification, Priority, Ticket
from .service import TicketService

__all__ = [
    "Category",
    "Classification",
    "Priority",
    "Ticket",
    "TicketClassifier",
    "TicketService",
]

__version__ = "0.1.0"

