# frozen_string_literal: true

require "json"

module SpreadGem
  # Handles message serialization and deserialization for SpreadJS protocol
  class Message
    TYPES = {
      set: "set",
      delete: "delete",
      request_state: "request_state",
      state: "state",
      ping: "ping",
      pong: "pong"
    }.freeze

    attr_reader :type, :data

    # Creates a new message
    #
    # @param type [Symbol, String] Message type
    # @param data [Hash] Message data
    def initialize(type, data = {})
      @type = type.to_s
      @data = data
    end

    # Serializes message to JSON
    #
    # @return [String] JSON string
    def to_json(*_args)
      { type: @type, data: @data }.to_json
    end

    # Parses a JSON message
    #
    # @param json_string [String] JSON message string
    # @return [Message] Parsed message
    # @raise [InvalidMessageError] if message format is invalid
    def self.parse(json_string)
      parsed = JSON.parse(json_string, symbolize_names: true)
      raise InvalidMessageError, "Missing type field" unless parsed[:type]

      new(parsed[:type], parsed[:data] || {})
    rescue JSON::ParserError => e
      raise InvalidMessageError, "Invalid JSON: #{e.message}"
    end

    # Creates a SET message for setting a value
    #
    # @param path [Array<String, Symbol>] Path to the value
    # @param value [Object] Value to set
    # @return [Message] SET message
    def self.set(path, value)
      new(:set, { path: path, value: value })
    end

    # Creates a DELETE message for deleting a value
    #
    # @param path [Array<String, Symbol>] Path to delete
    # @return [Message] DELETE message
    def self.delete(path)
      new(:delete, { path: path })
    end

    # Creates a REQUEST_STATE message
    #
    # @return [Message] REQUEST_STATE message
    def self.request_state
      new(:request_state)
    end

    # Creates a STATE message with full state
    #
    # @param state [Hash] Current state
    # @return [Message] STATE message
    def self.state(state)
      new(:state, { state: state })
    end

    # Creates a PING message
    #
    # @return [Message] PING message
    def self.ping
      new(:ping)
    end

    # Creates a PONG message
    #
    # @return [Message] PONG message
    def self.pong
      new(:pong)
    end
  end
end
