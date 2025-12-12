# frozen_string_literal: true

require "websocket-client-simple"
require "concurrent"

module SpreadGem
  # Manages WebSocket connection to SpreadJS server
  class Connection
    attr_reader :url, :connected

    # Creates a new connection
    #
    # @param url [String] WebSocket server URL
    # @param options [Hash] Connection options
    # @option options [Integer] :timeout Connection timeout in seconds (default: 10)
    # @option options [Boolean] :auto_reconnect Auto-reconnect on disconnect (default: true)
    def initialize(url, options = {})
      @url = url
      @options = options
      @timeout = options[:timeout] || 10
      @auto_reconnect = options.fetch(:auto_reconnect, true)
      @connected = false
      @closed = false
      @ws = nil
      @message_handlers = []
      @close_handlers = []
      @error_handlers = []
      @mutex = Mutex.new
    end

    # Establishes connection to WebSocket server
    #
    # @raise [ConnectionError] if connection fails
    def connect
      @mutex.synchronize do
        return if @connected

        begin
          @ws = WebSocket::Client::Simple.connect(@url)
          setup_handlers
          wait_for_connection
          @connected = true
        rescue StandardError => e
          raise ConnectionError, "Failed to connect to #{@url}: #{e.message}"
        end
      end
    end

    # Sends a message through the WebSocket
    #
    # @param message [Message, String] Message to send
    # @raise [ClosedConnectionError] if connection is closed
    def send(message)
      raise ClosedConnectionError, "Connection is closed" if @closed
      raise ConnectionError, "Not connected" unless @connected

      json = message.is_a?(Message) ? message.to_json : message
      @ws.send(json)
    end

    # Registers a handler for incoming messages
    #
    # @yield [message] Block to handle messages
    # @yieldparam message [Message] Received message
    def on_message(&block)
      @message_handlers << block if block_given?
    end

    # Registers a handler for connection close
    #
    # @yield [code, reason] Block to handle close event
    # @yieldparam code [Integer] Close code
    # @yieldparam reason [String] Close reason
    def on_close(&block)
      @close_handlers << block if block_given?
    end

    # Registers a handler for errors
    #
    # @yield [error] Block to handle errors
    # @yieldparam error [Exception] Error that occurred
    def on_error(&block)
      @error_handlers << block if block_given?
    end

    # Closes the WebSocket connection
    def close
      @mutex.synchronize do
        return if @closed

        @closed = true
        @connected = false
        @ws&.close
        @ws = nil
      end
    end

    # Checks if connection is open
    #
    # @return [Boolean] true if connected and not closed
    def open?
      @connected && !@closed
    end

    private

    def setup_handlers
      @ws.on :message do |msg|
        handle_message(msg.data)
      end

      @ws.on :close do |e|
        handle_close(e)
      end

      @ws.on :error do |e|
        handle_error(e)
      end
    end

    def handle_message(data)
      message = Message.parse(data)
      @message_handlers.each { |handler| handler.call(message) }
    rescue StandardError => e
      handle_error(e)
    end

    def handle_close(event)
      @connected = false
      code = event.respond_to?(:code) ? event.code : 1000
      reason = event.respond_to?(:reason) ? event.reason : "Connection closed"

      @close_handlers.each { |handler| handler.call(code, reason) }

      attempt_reconnect if @auto_reconnect && !@closed
    end

    def handle_error(error)
      @error_handlers.each { |handler| handler.call(error) }
    end

    def attempt_reconnect
      return if @closed

      sleep(1)
      connect
    rescue ConnectionError
      # Reconnection failed, will try again on next close event
    end

    def wait_for_connection
      start_time = Time.now
      until @ws.open?
        raise TimeoutError, "Connection timeout" if Time.now - start_time > @timeout

        sleep(0.1)
      end
    end
  end
end
