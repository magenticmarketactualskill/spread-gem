# frozen_string_literal: true

require_relative "spread_gem/version"
require_relative "spread_gem/errors"
require_relative "spread_gem/connection"
require_relative "spread_gem/message"
require_relative "spread_gem/store"
require_relative "spread_gem/client"

# SpreadGem is a Ruby wrapper for SpreadJS distributed object synchronization.
# It provides real-time object replication across multiple instances using WebSocket connections.
#
# @example Basic usage
#   client = SpreadGem::Client.new('ws://localhost:8080')
#   store = client.store
#   store[:config] = { name: "Peter" }
#   store[:config][:array] = ["one", "two"]
#
# @see https://github.com/spreadjs/spread
module SpreadGem
  class << self
    # Creates a new SpreadGem client and returns its store
    #
    # @param url [String] WebSocket server URL
    # @param options [Hash] Optional configuration
    # @return [SpreadGem::Store] The synchronized store
    def connect(url, options = {})
      client = Client.new(url, options)
      client.store
    end

    # Returns the current version of SpreadGem
    #
    # @return [String] Version number
    def version
      VERSION
    end
  end
end
