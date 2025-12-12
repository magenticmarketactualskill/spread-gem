# frozen_string_literal: true

RSpec.describe "SpreadGem errors" do
  describe SpreadGem::Error do
    it "is a StandardError" do
      expect(described_class).to be < StandardError
    end
  end

  describe SpreadGem::ConnectionError do
    it "inherits from SpreadGem::Error" do
      expect(described_class).to be < SpreadGem::Error
    end

    it "can be raised with a message" do
      expect {
        raise SpreadGem::ConnectionError, "Connection failed"
      }.to raise_error(SpreadGem::ConnectionError, "Connection failed")
    end
  end

  describe SpreadGem::ConnectionClosedError do
    it "inherits from SpreadGem::Error" do
      expect(described_class).to be < SpreadGem::Error
    end
  end

  describe SpreadGem::InvalidMessageError do
    it "inherits from SpreadGem::Error" do
      expect(described_class).to be < SpreadGem::Error
    end
  end

  describe SpreadGem::TimeoutError do
    it "inherits from SpreadGem::Error" do
      expect(described_class).to be < SpreadGem::Error
    end
  end

  describe SpreadGem::ClosedConnectionError do
    it "inherits from SpreadGem::Error" do
      expect(described_class).to be < SpreadGem::Error
    end
  end

  describe SpreadGem::SynchronizationError do
    it "inherits from SpreadGem::Error" do
      expect(described_class).to be < SpreadGem::Error
    end
  end
end
