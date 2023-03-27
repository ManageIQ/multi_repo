RSpec.describe MultiRepo::Repo do
  let(:repo_name) { "octocat/Hello-World" }
  subject { described_class.new(repo_name) }

  describe ".config" do
    before { clear_repo_config_cache }
    after  { clear_repo_config_cache }

    it "returns a Hash" do
      stub_repo_config_file("repo_config.yml")

      expect(described_class.config).to be_a(Hash)
    end

    it "handles a missing config file" do
      stub_repo_config_file("repo_config_doesnt_exist.yml")

      expect(described_class.config).to eq({})
    end

    it "only allows Hash in the config file" do
      stub_repo_config_file("repo_config_invalid.yml")

      expect { described_class.config }.to raise_error(RuntimeError, "#{described_class.config_file} must contain a Hash")
    end
  end

  it "#name" do
    expect(subject.name).to eq(repo_name)
  end

  describe "#config" do
    it "with no config" do
      expect(subject.config).to be_a(OpenStruct)
      expect(subject.config.to_h).to eq({})
    end

    context "with config" do
      before { stub_repo_config_file("repo_config.yml") }
      after  { clear_repo_config_cache }

      it "has config" do
        expect(subject.config).to be_a(OpenStruct)
        expect(subject.config.to_h).to eq({:clone_source => "https://github.com/octocat/Hello-World.git"})
      end
    end
  end

  it "#path" do
    expect(subject.path).to eq(MultiRepo.repos_dir.join(repo_name))
  end

  it "#short_name" do
    expect(subject.short_name).to eq("Hello-World")
  end

  it "#chdir" do
    path = nil
    subject.chdir { path = Dir.pwd }

    expect(path).to eq(MultiRepo.repos_dir.join(repo_name).to_s)
  end

  def clear_repo_config_cache
    described_class.instance_variable_set(:@config, nil)
  end

  def stub_repo_config_file(file)
    clear_repo_config_cache
    expect(described_class).to receive(:config_file).at_least(:once).and_return(SPEC_DATA.join(file))
  end
end
