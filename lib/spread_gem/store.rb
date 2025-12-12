# frozen_string_literal: true

require "concurrent"

module SpreadGem
  # Represents a synchronized store that replicates across instances
  # Provides a hash-like interface for accessing and modifying data
  class Store
    include Enumerable

    attr_reader :connection

    # Creates a new store
    #
    # @param connection [Connection] WebSocket connection
    def initialize(connection)
      @connection = connection
      @data = Concurrent::Hash.new
      @change_handlers = []
      @mutex = Mutex.new
      setup_message_handler
    end

    # Gets a value from the store
    #
    # @param key [Symbol, String] Key to retrieve
    # @return [Object] Value at key
    def [](key)
      @data[normalize_key(key)]
    end

    # Sets a value in the store and broadcasts to other instances
    #
    # @param key [Symbol, String] Key to set
    # @param value [Object] Value to set
    def []=(key, value)
      normalized_key = normalize_key(key)
      @data[normalized_key] = value
      broadcast_set([normalized_key], value)
      notify_change(:set, normalized_key, value)
      value
    end

    # Deletes a key from the store
    #
    # @param key [Symbol, String] Key to delete
    # @return [Object] Deleted value
    def delete(key)
      normalized_key = normalize_key(key)
      value = @data.delete(normalized_key)
      broadcast_delete([normalized_key])
      notify_change(:delete, normalized_key, value)
      value
    end

    # Gets a nested value using a path
    #
    # @param path [Array<Symbol, String>] Path to the value
    # @return [Object] Value at path
    def get_in(path)
      path.reduce(@data) do |current, key|
        return nil unless current.is_a?(Hash)

        current[normalize_key(key)]
      end
    end

    # Sets a nested value using a path
    #
    # @param path [Array<Symbol, String>] Path to set
    # @param value [Object] Value to set
    def set_in(path, value)
      return self[path.first] = value if path.length == 1

      normalized_path = path.map { |k| normalize_key(k) }
      parent = ensure_path_exists(normalized_path[0...-1])
      parent[normalized_path.last] = value
      broadcast_set(normalized_path, value)
      notify_change(:set, normalized_path, value)
      value
    end

    # Deletes a nested value using a path
    #
    # @param path [Array<Symbol, String>] Path to delete
    # @return [Object] Deleted value
    def delete_in(path)
      return delete(path.first) if path.length == 1

      normalized_path = path.map { |k| normalize_key(k) }
      parent = get_in(normalized_path[0...-1])
      return nil unless parent.is_a?(Hash)

      value = parent.delete(normalized_path.last)
      broadcast_delete(normalized_path)
      notify_change(:delete, normalized_path, value)
      value
    end

    # Checks if key exists
    #
    # @param key [Symbol, String] Key to check
    # @return [Boolean] true if key exists
    def key?(key)
      @data.key?(normalize_key(key))
    end

    alias has_key? key?
    alias include? key?

    # Returns all keys
    #
    # @return [Array<String>] All keys in store
    def keys
      @data.keys
    end

    # Returns all values
    #
    # @return [Array<Object>] All values in store
    def values
      @data.values
    end

    # Returns the number of items in store
    #
    # @return [Integer] Number of items
    def size
      @data.size
    end

    alias length size

    # Checks if store is empty
    #
    # @return [Boolean] true if empty
    def empty?
      @data.empty?
    end

    # Clears all data from store
    def clear
      @data.clear
      # Note: In a full implementation, this would broadcast a clear message
      notify_change(:clear, nil, nil)
    end

    # Iterates over key-value pairs
    #
    # @yield [key, value] Block to execute for each pair
    def each(&block)
      @data.each(&block)
    end

    # Converts store to hash
    #
    # @return [Hash] Store data as hash
    def to_h
      @data.to_h
    end

    alias to_hash to_h

    # Registers a change handler
    #
    # @yield [operation, key, value] Block to handle changes
    # @yieldparam operation [Symbol] Operation type (:set, :delete, :clear)
    # @yieldparam key [String, Array] Key or path that changed
    # @yieldparam value [Object] New value (nil for delete)
    def on_change(&block)
      @change_handlers << block if block_given?
    end

    # Requests current state from other instances
    def request_state
      message = Message.request_state
      @connection.send(message)
    end

    # Returns the current state as a hash
    #
    # @return [Hash] Current state
    def state
      @data.to_h
    end

    private

    def normalize_key(key)
      key.to_s
    end

    def setup_message_handler
      @connection.on_message do |message|
        handle_remote_message(message)
      end
    end

    def handle_remote_message(message)
      case message.type
      when "set"
        apply_remote_set(message.data[:path], message.data[:value])
      when "delete"
        apply_remote_delete(message.data[:path])
      when "state"
        apply_remote_state(message.data[:state])
      when "request_state"
        send_state
      when "ping"
        @connection.send(Message.pong)
      end
    rescue StandardError => e
      # Log error but don't crash
      warn "Error handling message: #{e.message}"
    end

    def apply_remote_set(path, value)
      @mutex.synchronize do
        if path.length == 1
          @data[path.first] = value
        else
          parent = ensure_path_exists(path[0...-1])
          parent[path.last] = value
        end
        notify_change(:set, path, value)
      end
    end

    def apply_remote_delete(path)
      @mutex.synchronize do
        if path.length == 1
          value = @data.delete(path.first)
        else
          parent = get_in(path[0...-1])
          value = parent&.delete(path.last) if parent.is_a?(Hash)
        end
        notify_change(:delete, path, value)
      end
    end

    def apply_remote_state(state)
      @mutex.synchronize do
        @data.clear
        @data.merge!(state)
        notify_change(:state_sync, nil, state)
      end
    end

    def send_state
      message = Message.state(@data.to_h)
      @connection.send(message)
    end

    def broadcast_set(path, value)
      message = Message.set(path, value)
      @connection.send(message)
    rescue StandardError => e
      raise SynchronizationError, "Failed to broadcast set: #{e.message}"
    end

    def broadcast_delete(path)
      message = Message.delete(path)
      @connection.send(message)
    rescue StandardError => e
      raise SynchronizationError, "Failed to broadcast delete: #{e.message}"
    end

    def ensure_path_exists(path)
      current = @data
      path.each do |key|
        current[key] = {} unless current[key].is_a?(Hash)
        current = current[key]
      end
      current
    end

    def notify_change(operation, key, value)
      @change_handlers.each do |handler|
        handler.call(operation, key, value)
      rescue StandardError => e
        warn "Error in change handler: #{e.message}"
      end
    end
  end
end
