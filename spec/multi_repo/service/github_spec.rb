RSpec.describe MultiRepo::Service::Github do
  describe ".parse_prs" do
    it "with a URL" do
      prs = "https://github.com/SomeOrg/some_repo/pull/123"
      expect(described_class.parse_prs(prs)).to eq([
        ["SomeOrg/some_repo", 123]
      ])
    end

    it "with org/repo#pr" do
      prs = "SomeOrg/some_repo#123"
      expect(described_class.parse_prs(prs)).to eq([
        ["SomeOrg/some_repo", 123]
      ])
    end

    it "with a mix of URL and org/repo#pr" do
      prs = ["SomeOrg/some_repo#123", "https://github.com/SomeOrg/some_repo/pull/234"]
      expect(described_class.parse_prs(prs)).to eq([
        ["SomeOrg/some_repo", 123],
        ["SomeOrg/some_repo", 234]
      ])
    end

    it "with a entries across multiple orgs and repos" do
      prs = ["SomeOrg/some_repo#123", "SomeOrg/some_repo#234", "SomeOrg/some_other_repo#345", "AnotherOrg/another_repo#456"]
      expect(described_class.parse_prs(prs)).to eq([
        ["SomeOrg/some_repo", 123],
        ["SomeOrg/some_repo", 234],
        ["SomeOrg/some_other_repo", 345],
        ["AnotherOrg/another_repo", 456]
      ])
    end

    it "with invalid entries" do
      prs = ["SomeOrg/some_repo#123", "SomeOrg/some_repo@234", "SomeOrg/some_repo#345"]
      expect { described_class.parse_prs(prs) }.to raise_error(ArgumentError, "Invalid PR 'SomeOrg/some_repo@234'. PR must be a GitHub URL or in org/repo#pr format.")
    end
  end
end
