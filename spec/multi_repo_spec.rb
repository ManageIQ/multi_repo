RSpec.describe MultiRepo do
  describe ".repo_options" do
    before { clear_repo_options_cache }
    after  { clear_repo_options_cache }

    it "returns a Hash" do
      stub_repo_options_file("repo_options.yml")

      expect(described_class.repo_options).to be_a(Hash)
    end

    it "handles a missing config file" do
      stub_repo_options_file("repo_options_doesnt_exist.yml")

      expect(described_class.repo_options).to eq({})
    end

    it "only allows Hash in the config file" do
      stub_repo_options_file("repo_options_invalid.yml")

      expect { described_class.repo_options }.to raise_error(RuntimeError, "repo_options.yml must contain a Hash")
    end
  end
end
