# SpreadGem

SpreadGem is a Ruby wrapper for [SpreadJS](https://github.com/spreadjs/spread), providing distributed object synchronization across multiple Ruby instances using WebSocket connections. It enables real-time data replication with a clean, Ruby-idiomatic API.

## Features

- **Real-time Synchronization**: Changes are instantly propagated across all connected instances
- **Ruby-Idiomatic API**: Hash-like interface that feels natural to Ruby developers
- **Thread-Safe**: Built with concurrent-ruby for safe multi-threaded access
- **Nested Objects**: Full support for nested hash structures
- **Change Callbacks**: Register handlers to react to data changes
- **Automatic Reconnection**: Handles connection drops gracefully
- **Pure Ruby**: No JavaScript runtime required

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spread-gem'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install spread-gem
```

## Requirements

- Ruby >= 3.3.6
- WebSocket server compatible with SpreadJS protocol

## Quick Start

### Basic Usage

```ruby
require 'spread_gem'

# Connect to SpreadJS server
client = SpreadGem::Client.new('ws://localhost:8080')
store = client.store

# Set values
store[:config] = { name: "Peter", age: 30 }
store[:status] = "online"

# Get values
puts store[:config][:name]  # => "Peter"
puts store[:status]          # => "online"

# Delete values
store.delete(:status)
```

### Using the Convenience Method

```ruby
require 'spread_gem'

# Connect and get store in one call
store = SpreadGem.connect('ws://localhost:8080')

store[:message] = "Hello, World!"
```

### Working with Nested Objects

```ruby
# Set nested values
store.set_in([:config, :database, :host], "localhost")
store.set_in([:config, :database, :port], 5432)

# Get nested values
host = store.get_in([:config, :database, :host])
# => "localhost"

# Delete nested values
store.delete_in([:config, :database, :port])
```

### Listening to Changes

```ruby
# Register a change handler
store.on_change do |operation, key, value|
  puts "#{operation}: #{key} = #{value.inspect}"
end

# Now any changes will trigger the handler
store[:test] = "value"
# Output: set: test = "value"
```

### Hash-like Operations

```ruby
# Check if key exists
store.key?(:config)        # => true
store.has_key?(:missing)   # => false

# Get all keys and values
store.keys                 # => ["config", "status"]
store.values               # => [{name: "Peter"}, "online"]

# Iterate over store
store.each do |key, value|
  puts "#{key}: #{value}"
end

# Convert to hash
hash = store.to_h
```

## Advanced Usage

### Connection Options

```ruby
client = SpreadGem::Client.new('ws://localhost:8080',
  timeout: 10,              # Connection timeout in seconds
  auto_reconnect: true,     # Automatically reconnect on disconnect
  request_state: true       # Request initial state on connect
)
```

### Error Handling

```ruby
begin
  client = SpreadGem::Client.new('ws://invalid:9999')
rescue SpreadGem::ConnectionError => e
  puts "Failed to connect: #{e.message}"
end

# Handle disconnections
client.on_disconnect do |code, reason|
  puts "Disconnected: #{reason}"
end

# Handle errors
client.on_error do |error|
  puts "Error: #{error.message}"
end
```

### Manual State Synchronization

```ruby
# Request current state from other instances
store.request_state

# Get current local state
current_state = store.state
```

### Closing Connections

```ruby
# Disconnect from server
client.disconnect

# Check connection status
client.connected?  # => false
```

## Architecture

SpreadGem consists of four main components:

### Client

The main entry point that manages the connection and provides access to the store.

### Store

A thread-safe, hash-like data structure that automatically synchronizes changes across instances.

### Connection

Manages the WebSocket connection, including reconnection logic and message handling.

### Message

Handles serialization and deserialization of the SpreadJS protocol messages.

## Protocol

SpreadGem implements the SpreadJS wire protocol with the following message types:

- **SET**: Set a value at a path
- **DELETE**: Delete a value at a path
- **REQUEST_STATE**: Request current state from peers
- **STATE**: Send current state to a peer
- **PING/PONG**: Keep-alive messages

## Thread Safety

SpreadGem uses `concurrent-ruby` to provide thread-safe operations. Multiple threads can safely read and write to the store concurrently.

```ruby
threads = 10.times.map do |i|
  Thread.new do
    store[:"key_#{i}"] = "value_#{i}"
  end
end

threads.each(&:join)
```

## Testing

Run the test suite:

```bash
# Run RSpec tests
$ bundle exec rspec

# Run Cucumber features
$ bundle exec cucumber

# Run all tests
$ bundle exec rake test
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/spreadjs/spread-gem.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

SpreadGem is a Ruby wrapper for [SpreadJS](https://github.com/spreadjs/spread), a distributed JavaScript object synchronization library.

## Version

Current version: 0.1.0

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.
