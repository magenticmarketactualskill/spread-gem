# frozen_string_literal: true

RSpec.describe SpreadGem::Message do
  describe "#initialize" do
    it "creates a message with type and data" do
      message = described_class.new(:set, { key: "value" })
      expect(message.type).to eq("set")
      expect(message.data).to eq({ key: "value" })
    end

    it "converts symbol type to string" do
      message = described_class.new(:set)
      expect(message.type).to be_a(String)
    end

    it "defaults data to empty hash" do
      message = described_class.new(:ping)
      expect(message.data).to eq({})
    end
  end

  describe "#to_json" do
    it "serializes message to JSON" do
      message = described_class.new(:set, { path: ["config"], value: "test" })
      json = message.to_json
      parsed = JSON.parse(json)

      expect(parsed["type"]).to eq("set")
      expect(parsed["data"]["path"]).to eq(["config"])
      expect(parsed["data"]["value"]).to eq("test")
    end
  end

  describe ".parse" do
    it "parses valid JSON message" do
      json = '{"type":"set","data":{"path":["key"],"value":"val"}}'
      message = described_class.parse(json)

      expect(message.type).to eq("set")
      expect(message.data[:path]).to eq(["key"])
      expect(message.data[:value]).to eq("val")
    end

    it "raises InvalidMessageError for invalid JSON" do
      expect {
        described_class.parse("invalid json")
      }.to raise_error(SpreadGem::InvalidMessageError, /Invalid JSON/)
    end

    it "raises InvalidMessageError for missing type" do
      expect {
        described_class.parse('{"data":{}}')
      }.to raise_error(SpreadGem::InvalidMessageError, /Missing type field/)
    end

    it "handles message without data field" do
      json = '{"type":"ping"}'
      message = described_class.parse(json)

      expect(message.type).to eq("ping")
      expect(message.data).to eq({})
    end
  end

  describe ".set" do
    it "creates a SET message" do
      message = described_class.set(["config", "name"], "Peter")

      expect(message.type).to eq("set")
      expect(message.data[:path]).to eq(["config", "name"])
      expect(message.data[:value]).to eq("Peter")
    end
  end

  describe ".delete" do
    it "creates a DELETE message" do
      message = described_class.delete(["config", "name"])

      expect(message.type).to eq("delete")
      expect(message.data[:path]).to eq(["config", "name"])
    end
  end

  describe ".request_state" do
    it "creates a REQUEST_STATE message" do
      message = described_class.request_state

      expect(message.type).to eq("request_state")
      expect(message.data).to eq({})
    end
  end

  describe ".state" do
    it "creates a STATE message" do
      state = { "config" => { "name" => "Peter" } }
      message = described_class.state(state)

      expect(message.type).to eq("state")
      expect(message.data[:state]).to eq(state)
    end
  end

  describe ".ping" do
    it "creates a PING message" do
      message = described_class.ping

      expect(message.type).to eq("ping")
      expect(message.data).to eq({})
    end
  end

  describe ".pong" do
    it "creates a PONG message" do
      message = described_class.pong

      expect(message.type).to eq("pong")
      expect(message.data).to eq({})
    end
  end
end
