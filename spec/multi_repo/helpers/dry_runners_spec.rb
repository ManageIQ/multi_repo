RSpec.describe MultiRepo::Helpers::DryRunner do
  let(:allowed_methods) { %i[i1 i2 i3] }
  let(:target) { double(:target_service) }
  let(:proxy) { described_class.new(target, "target", allowed_methods) }

  describe "#initialize (allowed_methods)" do
    it "blocks non-allowed methods" do
      expect(target).not_to receive(:m1)
      expect(proxy).to receive(:puts).with("** dry-run: target#m1(\"a1\", \"a2\")".light_black)

      proxy.m1("a1", "a2")
    end

    it "forwards allowed methods" do
      expect(target).to receive(:i1).with(:arg1, :arg2)
      expect(proxy).not_to receive(:puts)

      proxy.i1(:arg1, :arg2)

      expect(target).to receive(:i2).with(:arg1, :arg2)
      expect(proxy).not_to receive(:puts)

      proxy.i2(:arg1, :arg2)
    end
  end
end