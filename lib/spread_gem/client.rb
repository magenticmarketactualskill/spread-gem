# frozen_string_literal: true

module SpreadGem
  # Main client class for connecting to SpreadJS server
  class Client
    attr_reader :connection, :store, :url

    # Creates a new SpreadGem client
    #
    # @param url [String] WebSocket server URL (e.g., 'ws://localhost:8080')
    # @param options [Hash] Connection options
    # @option options [Integer] :timeout Connection timeout in seconds (default: 10)
    # @option options [Boolean] :auto_reconnect Auto-reconnect on disconnect (default: true)
    # @option options [Boolean] :request_state Request initial state on connect (default: true)
    #
    # @example
    #   client = SpreadGem::Client.new('ws://localhost:8080')
    #   client.store[:config] = { name: "Peter" }
    def initialize(url, options = {})
      @url = url
      @options = options
      @connection = Connection.new(url, options)
      @store = Store.new(@connection)
      @connected = false

      setup_connection_handlers
      connect_and_initialize
    end

    # Connects to the SpreadJS server
    #
    # @raise [ConnectionError] if connection fails
    def connect
      return if @connected

      @connection.connect
      @connected = true
      request_initial_state if @options.fetch(:request_state, true)
    end

    # Disconnects from the SpreadJS server
    def disconnect
      @connection.close
      @connected = false
    end

    # Checks if client is connected
    #
    # @return [Boolean] true if connected
    def connected?
      @connected && @connection.open?
    end

    # Registers a handler for connection close events
    #
    # @yield [code, reason] Block to handle close event
    def on_disconnect(&block)
      @connection.on_close(&block)
    end

    # Registers a handler for connection errors
    #
    # @yield [error] Block to handle errors
    def on_error(&block)
      @connection.on_error(&block)
    end

    # Sends a ping to the server
    def ping
      @connection.send(Message.ping)
    end

    private

    def setup_connection_handlers
      @connection.on_close do |code, reason|
        @connected = false
        handle_disconnect(code, reason)
      end

      @connection.on_error do |error|
        handle_error(error)
      end
    end

    def connect_and_initialize
      connect
    rescue ConnectionError => e
      raise ConnectionError, "Failed to initialize client: #{e.message}"
    end

    def request_initial_state
      @store.request_state
    end

    def handle_disconnect(code, reason)
      # Default disconnect handler - can be overridden by user
      warn "Disconnected from #{@url}: #{reason} (code: #{code})"
    end

    def handle_error(error)
      # Default error handler - can be overridden by user
      warn "Connection error: #{error.message}"
    end
  end
end
