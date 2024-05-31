require "spec_helper"

RSpec.describe PrettyApi::ActiveRecord::Associations do
  subject(:helper) { described_class.method(:nested_attributes_associations) }

  context "without circular references" do
    it { expect(helper.call(Service)).to eq [:phones] }
  end

  context "with circular references" do
    context "when organization <--> company car" do
      it { expect(helper.call(Organization)).to eq [{ services: [:phones] }, { company_car: [] }] }
    end

    context "when company car <--> organization" do
      it { expect(helper.call(CompanyCar)).to eq [{ organization: [{ services: [:phones] }] }] }
    end
  end

  context "without associations" do
    it { expect(helper.call(Phone)).to eq [] }
  end
end
