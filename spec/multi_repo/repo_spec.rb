RSpec.describe MultiRepo::Repo do
  let(:repo_name) { "octocat/Hello-World" }
  subject { described_class.new(repo_name) }

  it "#name" do
    expect(subject.name).to eq(repo_name)
  end

  it "#path" do
    expect(subject.path).to eq(REPOS_DIR.join(repo_name))
  end

  it "#short_name" do
    expect(subject.short_name).to eq("Hello-World")
  end

  it "#chdir" do
    path = nil
    subject.chdir { path = Dir.pwd }

    expect(path).to eq(REPOS_DIR.join(repo_name).to_s)
  end
end
