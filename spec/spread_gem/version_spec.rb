# frozen_string_literal: true

RSpec.describe SpreadGem do
  describe "VERSION" do
    it "has a version number" do
      expect(SpreadGem::VERSION).not_to be nil
    end

    it "follows semantic versioning" do
      expect(SpreadGem::VERSION).to match(/^\d+\.\d+\.\d+$/)
    end

    it "returns version via module method" do
      expect(SpreadGem.version).to eq(SpreadGem::VERSION)
    end
  end
end
