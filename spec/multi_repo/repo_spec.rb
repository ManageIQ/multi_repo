RSpec.describe MultiRepo::Repo do
  let(:repo_name) { "octocat/Hello-World" }
  subject { described_class.new(repo_name) }

  describe ".options" do
    before { clear_repo_options_cache }
    after  { clear_repo_options_cache }

    it "returns a Hash" do
      stub_repo_options_file("repo_options.yml")

      expect(described_class.options).to be_a(Hash)
    end

    it "handles a missing config file" do
      stub_repo_options_file("repo_options_doesnt_exist.yml")

      expect(described_class.options).to eq({})
    end

    it "only allows Hash in the config file" do
      stub_repo_options_file("repo_options_invalid.yml")

      expect { described_class.options }.to raise_error(RuntimeError, "#{described_class.options_file} must contain a Hash")
    end
  end

  it "#name" do
    expect(subject.name).to eq(repo_name)
  end

  describe "#options" do
    it "with no options" do
      expect(subject.options).to be_a(OpenStruct)
      expect(subject.options.to_h).to eq({})
    end

    context "with options" do
      before { stub_repo_options_file("repo_options.yml") }
      after  { clear_repo_options_cache }

      it "has options" do
        expect(subject.options).to be_a(OpenStruct)
        expect(subject.options.to_h).to eq({:clone_source => "https://github.com/octocat/Hello-World.git"})
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
end
