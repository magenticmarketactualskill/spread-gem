# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/features/"
end

require "spread_gem"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Shared context for mock WebSocket
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end

# Mock WebSocket for testing
class MockWebSocket
  attr_reader :sent_messages, :open

  def initialize
    @sent_messages = []
    @open = true
    @handlers = {}
  end

  def send(message)
    @sent_messages << message
  end

  def on(event, &block)
    @handlers[event] = block
  end

  def trigger(event, data = nil)
    @handlers[event]&.call(data)
  end

  def open?
    @open
  end

  def close
    @open = false
    trigger(:close, OpenStruct.new(code: 1000, reason: "Normal closure"))
  end

  def simulate_message(data)
    trigger(:message, OpenStruct.new(data: data))
  end

  def simulate_error(error)
    trigger(:error, error)
  end
end

require "ostruct"
