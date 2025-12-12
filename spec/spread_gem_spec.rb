# frozen_string_literal: true

RSpec.describe SpreadGem do
  it "has a version number" do
    expect(SpreadGem::VERSION).not_to be nil
  end

  describe ".version" do
    it "returns the version" do
      expect(SpreadGem.version).to eq(SpreadGem::VERSION)
    end
  end

  describe ".connect" do
    let(:mock_client) { instance_double(SpreadGem::Client) }
    let(:mock_store) { instance_double(SpreadGem::Store) }

    before do
      allow(SpreadGem::Client).to receive(:new).and_return(mock_client)
      allow(mock_client).to receive(:store).and_return(mock_store)
    end

    it "creates a client and returns the store" do
      result = SpreadGem.connect("ws://localhost:8080")
      expect(result).to eq(mock_store)
    end

    it "passes URL to client" do
      expect(SpreadGem::Client).to receive(:new).with("ws://localhost:8080", {})
      SpreadGem.connect("ws://localhost:8080")
    end

    it "passes options to client" do
      options = { timeout: 5 }
      expect(SpreadGem::Client).to receive(:new).with("ws://localhost:8080", options)
      SpreadGem.connect("ws://localhost:8080", options)
    end
  end

  describe "module structure" do
    it "defines Client class" do
      expect(defined?(SpreadGem::Client)).to eq("constant")
    end

    it "defines Store class" do
      expect(defined?(SpreadGem::Store)).to eq("constant")
    end

    it "defines Connection class" do
      expect(defined?(SpreadGem::Connection)).to eq("constant")
    end

    it "defines Message class" do
      expect(defined?(SpreadGem::Message)).to eq("constant")
    end

    it "defines error classes" do
      expect(defined?(SpreadGem::Error)).to eq("constant")
      expect(defined?(SpreadGem::ConnectionError)).to eq("constant")
      expect(defined?(SpreadGem::InvalidMessageError)).to eq("constant")
    end
  end
end
