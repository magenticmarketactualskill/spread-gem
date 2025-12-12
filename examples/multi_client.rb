#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Multiple clients synchronizing data
#
# This example demonstrates how multiple SpreadGem clients can synchronize
# data in real-time across different instances.

require "spread_gem"

SERVER_URL = "ws://localhost:8080"

def create_client(name)
  puts "[#{name}] Connecting to server..."
  client = SpreadGem::Client.new(SERVER_URL)
  store = client.store

  # Register change handler
  store.on_change do |operation, key, value|
    puts "[#{name}] Received change: #{operation} #{key} = #{value.inspect}"
  end

  { client: client, store: store, name: name }
rescue SpreadGem::ConnectionError => e
  puts "[#{name}] Failed to connect: #{e.message}"
  nil
end

begin
  puts "Multi-Client Synchronization Example"
  puts "=" * 50
  puts

  # Create multiple clients
  alice = create_client("Alice")
  bob = create_client("Bob")
  charlie = create_client("Charlie")

  unless alice && bob && charlie
    puts "Failed to create all clients. Make sure server is running."
    exit 1
  end

  puts
  puts "All clients connected!"
  puts

  # Alice sets a value
  puts "Alice sets username..."
  alice[:store][:username] = "alice_2025"
  sleep 0.5  # Give time for synchronization

  # Bob sets a value
  puts "Bob sets status..."
  bob[:store][:status] = "online"
  sleep 0.5

  # Charlie sets a value
  puts "Charlie sets score..."
  charlie[:store][:score] = 9000
  sleep 0.5

  puts
  puts "Current state on each client:"
  puts "-" * 50

  puts "\nAlice's view:"
  alice[:store].each { |k, v| puts "  #{k}: #{v}" }

  puts "\nBob's view:"
  bob[:store].each { |k, v| puts "  #{k}: #{v}" }

  puts "\nCharlie's view:"
  charlie[:store].each { |k, v| puts "  #{k}: #{v}" }

  puts
  puts "All clients should have the same data!"
  puts

  # Update a value from different client
  puts "Bob updates username..."
  bob[:store][:username] = "bob_is_here"
  sleep 0.5

  puts "\nAlice sees: username = #{alice[:store][:username]}"
  puts "Charlie sees: username = #{charlie[:store][:username]}"

  puts
  puts "Cleaning up..."
  alice[:client].disconnect
  bob[:client].disconnect
  charlie[:client].disconnect

  puts "Done!"

rescue StandardError => e
  puts "Error: #{e.message}"
  puts e.backtrace.first(5)
end
