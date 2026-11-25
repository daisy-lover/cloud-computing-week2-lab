class TicketFlowError(Exception):
    """Base error for expected application failures."""


class ValidationError(TicketFlowError):
    """Input does not satisfy the public data contract."""


class StorageError(TicketFlowError):
    """The ticket repository could not complete an operation."""


class DuplicateTicketError(TicketFlowError):
    """A ticket with the same id already exists."""

