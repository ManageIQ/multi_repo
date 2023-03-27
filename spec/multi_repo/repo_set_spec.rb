RSpec.describe MultiRepo::RepoSet do
  before { described_class.instance_variable_set(:@all, nil) }
  after  { described_class.instance_variable_set(:@all, nil) }

  describe ".all" do
    it "with a single repo set file" do
      expect(described_class).to receive(:repo_set_files).and_return([SPEC_DATA.join("repo_set_single.yml")])

      repo_sets = described_class.all

      expect(repo_sets.keys).to match_array(["set1", "set2"])
      expect(repo_sets["set1"].size).to    eq(2)
      expect(repo_sets["set1"][0]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set1"][0].name).to eq("Org1/Repo1")
      expect(repo_sets["set1"][1]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set1"][1].name).to eq("Org1/Repo2")
      expect(repo_sets["set2"].size).to    eq(2)
      expect(repo_sets["set2"][0]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set2"][0].name).to eq("Org1/Repo2")
      expect(repo_sets["set2"][1]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set2"][1].name).to eq("Org1/Repo3")
    end

    it "with multiple repo set files" do
      expect(described_class).to receive(:repo_set_files).and_return([SPEC_DATA.join("repo_set_many_1.yml"), SPEC_DATA.join("repo_set_many_2.yml")])

      repo_sets = described_class.all

      expect(repo_sets.keys).to match_array(["set1", "set2"])
      expect(repo_sets["set1"].size).to    eq(2)
      expect(repo_sets["set1"][0]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set1"][0].name).to eq("Org1/Repo1")
      expect(repo_sets["set1"][1]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set1"][1].name).to eq("Org1/Repo2")
      expect(repo_sets["set2"].size).to    eq(2)
      expect(repo_sets["set2"][0]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set2"][0].name).to eq("Org1/Repo2")
      expect(repo_sets["set2"][1]).to      be_a(MultiRepo::Repo)
      expect(repo_sets["set2"][1].name).to eq("Org1/Repo3")
    end
  end

  describe ".[]" do
    it "with a repo set that exists" do
      expect(described_class).to receive(:repo_set_files).and_return([SPEC_DATA.join("repo_set_single.yml")])

      repo_set = described_class.all["set1"]

      expect(repo_set.size).to    eq(2)
      expect(repo_set[0]).to      be_a(MultiRepo::Repo)
      expect(repo_set[0].name).to eq("Org1/Repo1")
      expect(repo_set[1]).to      be_a(MultiRepo::Repo)
      expect(repo_set[1].name).to eq("Org1/Repo2")
    end

    it "with a repo set that does not exist" do
      expect(described_class).to receive(:repo_set_files).and_return([SPEC_DATA.join("repo_set_single.yml")])

      expect(described_class.all["invalid"]).to be_nil
    end
  end
end
