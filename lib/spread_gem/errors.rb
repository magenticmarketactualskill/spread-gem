# frozen_string_literal: true

module SpreadGem
  # Base error class for all SpreadGem errors
  class Error < StandardError; end

  # Raised when connection to WebSocket server fails
  class ConnectionError < Error; end

  # Raised when WebSocket connection is closed unexpectedly
  class ConnectionClosedError < Error; end

  # Raised when message format is invalid
  class InvalidMessageError < Error; end

  # Raised when operation times out
  class TimeoutError < Error; end

  # Raised when attempting to use a closed connection
  class ClosedConnectionError < Error; end

  # Raised when synchronization fails
  class SynchronizationError < Error; end
end
