# frozen_string_literal: true

RSpec.describe SpreadGem::Store do
  let(:mock_ws) { MockWebSocket.new }
  let(:connection) do
    conn = instance_double(SpreadGem::Connection)
    allow(conn).to receive(:on_message) { |&block| @message_handler = block }
    allow(conn).to receive(:send)
    conn
  end
  let(:store) { described_class.new(connection) }

  describe "#initialize" do
    it "creates an empty store" do
      expect(store.size).to eq(0)
      expect(store).to be_empty
    end

    it "sets up message handler" do
      expect(connection).to have_received(:on_message)
    end
  end

  describe "#[]= and #[]" do
    it "sets and gets values" do
      store[:name] = "Peter"
      expect(store[:name]).to eq("Peter")
    end

    it "broadcasts set message" do
      expect(connection).to receive(:send) do |message|
        expect(message.type).to eq("set")
        expect(message.data[:path]).to eq(["name"])
        expect(message.data[:value]).to eq("Peter")
      end

      store[:name] = "Peter"
    end

    it "normalizes symbol keys to strings" do
      store[:config] = "value"
      expect(store.keys).to include("config")
    end

    it "handles nested hashes" do
      store[:config] = { name: "Peter", age: 30 }
      expect(store[:config][:name]).to eq("Peter")
      expect(store[:config][:age]).to eq(30)
    end
  end

  describe "#delete" do
    before { store[:name] = "Peter" }

    it "deletes a key" do
      result = store.delete(:name)
      expect(result).to eq("Peter")
      expect(store[:name]).to be_nil
    end

    it "broadcasts delete message" do
      expect(connection).to receive(:send) do |message|
        expect(message.type).to eq("delete")
        expect(message.data[:path]).to eq(["name"])
      end

      store.delete(:name)
    end
  end

  describe "#get_in" do
    before do
      store[:config] = { database: { host: "localhost", port: 5432 } }
    end

    it "gets nested values" do
      expect(store.get_in([:config, :database, :host])).to eq("localhost")
    end

    it "returns nil for non-existent paths" do
      expect(store.get_in([:config, :missing, :key])).to be_nil
    end

    it "returns nil for invalid paths" do
      expect(store.get_in([:config, :database, :host, :invalid])).to be_nil
    end
  end

  describe "#set_in" do
    it "sets nested values" do
      store.set_in([:config, :database, :host], "localhost")
      expect(store.get_in([:config, :database, :host])).to eq("localhost")
    end

    it "creates intermediate hashes" do
      store.set_in([:a, :b, :c], "value")
      expect(store[:a]).to be_a(Hash)
      expect(store[:a][:b]).to be_a(Hash)
      expect(store[:a][:b][:c]).to eq("value")
    end

    it "broadcasts set message with full path" do
      expect(connection).to receive(:send) do |message|
        expect(message.type).to eq("set")
        expect(message.data[:path]).to eq(["config", "name"])
        expect(message.data[:value]).to eq("Peter")
      end

      store.set_in([:config, :name], "Peter")
    end
  end

  describe "#delete_in" do
    before do
      store[:config] = { database: { host: "localhost" } }
    end

    it "deletes nested values" do
      result = store.delete_in([:config, :database, :host])
      expect(result).to eq("localhost")
      expect(store.get_in([:config, :database, :host])).to be_nil
    end

    it "broadcasts delete message with full path" do
      expect(connection).to receive(:send) do |message|
        expect(message.type).to eq("delete")
        expect(message.data[:path]).to eq(["config", "database", "host"])
      end

      store.delete_in([:config, :database, :host])
    end
  end

  describe "#key?" do
    before { store[:name] = "Peter" }

    it "returns true for existing keys" do
      expect(store.key?(:name)).to be true
    end

    it "returns false for non-existent keys" do
      expect(store.key?(:missing)).to be false
    end

    it "has aliases" do
      expect(store.has_key?(:name)).to be true
      expect(store.include?(:name)).to be true
    end
  end

  describe "#keys" do
    it "returns all keys" do
      store[:a] = 1
      store[:b] = 2
      expect(store.keys).to contain_exactly("a", "b")
    end
  end

  describe "#values" do
    it "returns all values" do
      store[:a] = 1
      store[:b] = 2
      expect(store.values).to contain_exactly(1, 2)
    end
  end

  describe "#size" do
    it "returns the number of items" do
      expect(store.size).to eq(0)
      store[:a] = 1
      expect(store.size).to eq(1)
      store[:b] = 2
      expect(store.size).to eq(2)
    end

    it "has length alias" do
      store[:a] = 1
      expect(store.length).to eq(1)
    end
  end

  describe "#empty?" do
    it "returns true when empty" do
      expect(store).to be_empty
    end

    it "returns false when not empty" do
      store[:a] = 1
      expect(store).not_to be_empty
    end
  end

  describe "#clear" do
    before do
      store[:a] = 1
      store[:b] = 2
    end

    it "removes all items" do
      store.clear
      expect(store).to be_empty
    end
  end

  describe "#each" do
    before do
      store[:a] = 1
      store[:b] = 2
    end

    it "iterates over key-value pairs" do
      pairs = []
      store.each { |k, v| pairs << [k, v] }
      expect(pairs).to contain_exactly(["a", 1], ["b", 2])
    end
  end

  describe "#to_h" do
    it "converts to hash" do
      store[:a] = 1
      store[:b] = 2
      expect(store.to_h).to eq({ "a" => 1, "b" => 2 })
    end

    it "has to_hash alias" do
      store[:a] = 1
      expect(store.to_hash).to eq({ "a" => 1 })
    end
  end

  describe "#on_change" do
    it "registers change handlers" do
      changes = []
      store.on_change { |op, key, val| changes << [op, key, val] }

      store[:name] = "Peter"
      expect(changes).to include([:set, "name", "Peter"])
    end

    it "calls multiple handlers" do
      calls1 = []
      calls2 = []

      store.on_change { |op, key, val| calls1 << [op, key, val] }
      store.on_change { |op, key, val| calls2 << [op, key, val] }

      store[:test] = "value"

      expect(calls1).not_to be_empty
      expect(calls2).not_to be_empty
    end
  end

  describe "#request_state" do
    it "sends request_state message" do
      expect(connection).to receive(:send) do |message|
        expect(message.type).to eq("request_state")
      end

      store.request_state
    end
  end

  describe "#state" do
    it "returns current state as hash" do
      store[:a] = 1
      store[:b] = 2
      expect(store.state).to eq({ "a" => 1, "b" => 2 })
    end
  end

  describe "remote message handling" do
    it "applies remote set messages" do
      message = SpreadGem::Message.set(["name"], "Peter")
      @message_handler.call(message)

      expect(store[:name]).to eq("Peter")
    end

    it "applies remote delete messages" do
      store[:name] = "Peter"
      message = SpreadGem::Message.delete(["name"])
      @message_handler.call(message)

      expect(store[:name]).to be_nil
    end

    it "applies remote state messages" do
      state = { "config" => { "name" => "Peter" } }
      message = SpreadGem::Message.state(state)
      @message_handler.call(message)

      expect(store[:config]).to eq({ "name" => "Peter" })
    end

    it "responds to request_state messages" do
      store[:data] = "value"

      expect(connection).to receive(:send) do |message|
        expect(message.type).to eq("state")
        expect(message.data[:state]).to eq({ "data" => "value" })
      end

      message = SpreadGem::Message.request_state
      @message_handler.call(message)
    end

    it "responds to ping messages with pong" do
      expect(connection).to receive(:send) do |message|
        expect(message.type).to eq("pong")
      end

      message = SpreadGem::Message.ping
      @message_handler.call(message)
    end
  end
end
