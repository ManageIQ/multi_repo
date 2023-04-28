RSpec.describe MultiRepo::Repo do
  let(:repo_name) { "octocat/Hello-World" }
  subject { described_class.new(repo_name) }

  it "#name" do
    expect(subject.name).to eq(repo_name)
  end

  describe "#config" do
    it "with no config" do
      expect(subject.config).to      be_a(OpenStruct)
      expect(subject.config.to_h).to eq({})
    end

    context "with config" do
      let(:clone_source) { "https://github.com/octocat/Hello-World.git" }
      let(:config) { {:clone_source => clone_source} }
      subject { described_class.new(repo_name, :config => config) }

      it "has config" do
        expect(subject.config).to      be_a(OpenStruct)
        expect(subject.config.to_h).to eq(config)
        expect(subject.config.clone_source).to eq(clone_source)
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
