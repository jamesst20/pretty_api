require "spec_helper"

RSpec.describe PrettyApi::ActiveRecord::Associations do
  subject(:helper) { described_class.method(:nested_attributes_tree) }

  context "without circular references" do
    let(:expected) do
      { Service => { phones: { model: Phone, allow_destroy: true, type: :has_many } }, Phone => {} }
    end

    it { expect(helper.call(Service)).to eq_hash expected }
  end

  context "with circular references" do
    context "when organization <--> company car" do
      let(:expected) do
        { CompanyCar => { organization: { allow_destroy: true, model: Organization, type: :belongs_to } },
          Organization => { company_car: { allow_destroy: true, model: CompanyCar, type: :has_one },
                            services: { allow_destroy: true, model: Service, type: :has_many } },
          Phone => {},
          Service => { phones: { allow_destroy: true, model: Phone, type: :has_many } } }
      end

      it { expect(helper.call(Organization)).to eq expected }
    end
  end

  context "with self referencing user <--> user" do
    let(:expected) do
      {
        CompanyCar => { organization: { allow_destroy: true, model: Organization, type: :belongs_to } },
        Organization => { company_car: { allow_destroy: true, model: CompanyCar, type: :has_one },
                          services: { allow_destroy: true, model: Service, type: :has_many } },
        Phone => {},
        Service => { phones: { allow_destroy: true, model: Phone, type: :has_many } },
        User => { children: { allow_destroy: true, model: User, type: :has_many },
                  organizations: { allow_destroy: true, model: Organization, type: :has_many } }
      }
    end

    it { expect(helper.call(User)).to eq expected }
  end

  context "without associations" do
    it { expect(helper.call(Phone)).to eq_hash({}) }
  end
end
