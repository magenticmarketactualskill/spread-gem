# frozen_string_literal: true

require "spread_gem"
require "rspec/expectations"

# Mock WebSocket server for testing
class MockSpreadServer
  attr_reader :clients, :state

  def initialize
    @clients = []
    @state = {}
    @running = false
  end

  def start
    @running = true
    @state = {}
  end

  def stop
    @running = false
    @clients.clear
  end

  def running?
    @running
  end

  def add_client(client)
    @clients << client
  end

  def broadcast(message)
    @clients.each { |client| client.receive(message) }
  end

  def update_state(key, value)
    @state[key] = value
  end

  def get_state(key)
    @state[key]
  end
end

# World provides helper methods for Cucumber scenarios
module SpreadGemWorld
  def mock_server
    @mock_server ||= MockSpreadServer.new
  end

  def create_client(name)
    @clients ||= {}
    # In real scenario, this would connect to actual server
    # For testing, we use a mock
    @clients[name] = {
      store: {},
      name: name
    }
  end

  def get_client(name)
    @clients[name]
  end

  def set_value(client_name, key, value)
    client = get_client(client_name)
    client[:store][key] = value
    mock_server.update_state(key, value)
  end

  def get_value(client_name, key)
    client = get_client(client_name)
    client[:store][key]
  end

  def sync_clients
    # Simulate synchronization between clients
    @clients.each do |_name, client|
      mock_server.state.each do |key, value|
        client[:store][key] = value
      end
    end
  end
end

World(SpreadGemWorld)

Before do
  @mock_server = MockSpreadServer.new
  @clients = {}
end

After do
  @mock_server&.stop
  @clients&.clear
end
