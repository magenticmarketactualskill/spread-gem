#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Basic usage of SpreadGem
#
# This example demonstrates the basic features of SpreadGem including
# connecting to a server, setting/getting values, and handling changes.

require "spread_gem"

# Connect to SpreadJS server
# Note: Make sure a SpreadJS server is running at ws://localhost:8080
puts "Connecting to SpreadJS server..."

begin
  client = SpreadGem::Client.new("ws://localhost:8080")
  store = client.store

  puts "Connected successfully!"
  puts

  # Set simple values
  puts "Setting simple values..."
  store[:username] = "alice"
  store[:status] = "online"
  store[:score] = 100

  # Get values
  puts "Username: #{store[:username]}"
  puts "Status: #{store[:status]}"
  puts "Score: #{store[:score]}"
  puts

  # Set nested values
  puts "Setting nested values..."
  store[:config] = {
    database: {
      host: "localhost",
      port: 5432
    },
    cache: {
      enabled: true,
      ttl: 3600
    }
  }

  # Access nested values
  puts "Database host: #{store[:config][:database][:host]}"
  puts "Cache enabled: #{store[:config][:cache][:enabled]}"
  puts

  # Use set_in for nested paths
  puts "Using set_in for deep nesting..."
  store.set_in([:app, :settings, :theme], "dark")
  store.set_in([:app, :settings, :language], "en")

  theme = store.get_in([:app, :settings, :theme])
  puts "Theme: #{theme}"
  puts

  # Register change handler
  puts "Registering change handler..."
  store.on_change do |operation, key, value|
    puts "  [CHANGE] #{operation}: #{key} = #{value.inspect}"
  end

  # Make some changes
  puts "Making changes (watch for notifications)..."
  store[:counter] = 1
  store[:counter] = 2
  store[:counter] = 3
  puts

  # Delete values
  puts "Deleting values..."
  store.delete(:status)
  puts "Status after delete: #{store[:status].inspect}"
  puts

  # Show all keys
  puts "All keys in store:"
  store.keys.each { |key| puts "  - #{key}" }
  puts

  # Iterate over store
  puts "All key-value pairs:"
  store.each do |key, value|
    puts "  #{key}: #{value.inspect}"
  end
  puts

  # Convert to hash
  puts "Store as hash:"
  puts store.to_h.inspect
  puts

  # Check connection status
  puts "Connected: #{client.connected?}"

  # Disconnect
  puts "Disconnecting..."
  client.disconnect
  puts "Connected: #{client.connected?}"

rescue SpreadGem::ConnectionError => e
  puts "Failed to connect: #{e.message}"
  puts
  puts "Make sure a SpreadJS server is running at ws://localhost:8080"
  puts "You can start one using the spread-server package from npm:"
  puts "  npm install -g spreadjs-server"
  puts "  spread-server"
end
