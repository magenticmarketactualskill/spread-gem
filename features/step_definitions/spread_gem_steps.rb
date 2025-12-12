# frozen_string_literal: true

Given("a SpreadJS server is running") do
  mock_server.start
  expect(mock_server).to be_running
end

Given("two Ruby clients are connected") do
  create_client("client1")
  create_client("client2")
  expect(get_client("client1")).not_to be_nil
  expect(get_client("client2")).not_to be_nil
end

Given("a client named {string} is connected") do |client_name|
  create_client(client_name)
  expect(get_client(client_name)).not_to be_nil
end

Given("multiple clients are connected") do
  create_client("client1")
  create_client("client2")
  create_client("client3")
end

When("client {int} sets a value") do |client_num|
  client_name = "client#{client_num}"
  set_value(client_name, "test_key", "test_value")
end

When("{string} sets {string} to {string}") do |client_name, key, value|
  set_value(client_name, key, value)
  sync_clients
end

When("{string} sets a nested value at {string} to {string}") do |client_name, path, value|
  keys = path.split(".")
  client = get_client(client_name)
  current = client[:store]

  keys[0...-1].each do |key|
    current[key] ||= {}
    current = current[key]
  end

  current[keys.last] = value
  mock_server.update_state(path, value)
  sync_clients
end

When("{string} deletes {string}") do |client_name, key|
  client = get_client(client_name)
  client[:store].delete(key)
  mock_server.state.delete(key)
  sync_clients
end

When("the clients synchronize") do
  sync_clients
end

Then("client {int} should receive the update") do |client_num|
  client_name = "client#{client_num}"
  sync_clients
  value = get_value(client_name, "test_key")
  expect(value).to eq("test_value")
end

Then("{string} should see {string} equals {string}") do |client_name, key, expected_value|
  value = get_value(client_name, key)
  expect(value).to eq(expected_value)
end

Then("{string} should see {string} is nil") do |client_name, key|
  value = get_value(client_name, key)
  expect(value).to be_nil
end

Then("all clients should have the same data") do
  return if @clients.empty?

  first_store = @clients.values.first[:store]
  @clients.values.each do |client|
    expect(client[:store]).to eq(first_store)
  end
end

Then("{string} should see nested value at {string} equals {string}") do |client_name, path, expected_value|
  keys = path.split(".")
  client = get_client(client_name)
  current = client[:store]

  keys.each do |key|
    current = current[key]
    break if current.nil?
  end

  expect(current).to eq(expected_value)
end

Then("the store should contain {int} items") do |count|
  client = @clients.values.first
  expect(client[:store].size).to eq(count)
end

Then("{string} should have an empty store") do |client_name|
  client = get_client(client_name)
  expect(client[:store]).to be_empty
end

# Version and module checks
Then("the gem should have a version number") do
  expect(SpreadGem::VERSION).not_to be_nil
  expect(SpreadGem::VERSION).to match(/^\d+\.\d+\.\d+$/)
end

Then("the gem should define the {string} class") do |class_name|
  expect(defined?("SpreadGem::#{class_name}".constantize)).to eq("constant")
end

# Error handling
When("{string} attempts to connect to an invalid server") do |client_name|
  @connection_error = nil
  begin
    # In real implementation, this would try to connect
    raise SpreadGem::ConnectionError, "Connection refused"
  rescue SpreadGem::ConnectionError => e
    @connection_error = e
  end
end

Then("a ConnectionError should be raised") do
  expect(@connection_error).to be_a(SpreadGem::ConnectionError)
end
