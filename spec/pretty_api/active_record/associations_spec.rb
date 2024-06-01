require "spec_helper"

RSpec.describe PrettyApi::ActiveRecord::Associations do
  subject(:helper) { described_class.method(:nested_attributes_tree) }

  context "when structure is array" do
    let(:structure) { :array }

    context "without circular references" do
      it { expect(helper.call(Service, structure)).to eq [:phones] }
    end

    context "with circular references" do
      context "when organization <--> company car" do
        let(:expected) do
          [{ services: [:phones] }, { company_car: [{ organization: [{ services: [:phones] }] }] }]
        end

        it { expect(helper.call(Organization, structure)).to eq expected }
      end

      context "when company car <--> organization" do
        let(:expected) do
          [{ organization: [{ services: [:phones] }, :company_car] }]
        end

        it { expect(helper.call(CompanyCar, structure)).to eq expected }
      end
    end

    context "with self referencing user <--> user" do
      let(:expected) do
        [
          { organizations: [{ services: [:phones] }, { company_car: [{ organization: [{ services: [:phones] }] }] }] },
          {
            children: [
              {
                organizations: [
                  { services: [:phones] }, { company_car: [{ organization: [{ services: [:phones] }] }] }
                ]
              }
            ]
          }
        ]
      end

      it { expect(helper.call(User, structure)).to eq expected }
    end

    context "without associations" do
      it { expect(helper.call(Phone, structure)).to eq [] }
    end
  end

  context "when structure is hash" do
    let(:structure) { :hash }

    context "without circular references" do
      it { expect(helper.call(Service, structure)).to eq_hash({ phones: {} }) }
    end

    context "with circular references" do
      context "when organization <--> company car" do
        let(:expected) do
          { company_car: { organization: { services: { phones: {} } } }, services: { phones: {} } }
        end

        it { expect(helper.call(Organization, structure)).to eq_hash expected }
      end

      context "when company car <--> organization" do
        let(:expected) do
          { organization: { company_car: {}, services: { phones: {} } } }
        end

        it { expect(helper.call(CompanyCar, structure)).to eq_hash expected }
      end
    end

    context "with self referencing user <--> user" do
      let(:expected) do
        {
          organizations: { services: { phones: {} }, company_car: { organization: { services: { phones: {} } } } },
          children: {
            organizations: { services: { phones: {} }, company_car: { organization: { services: { phones: {} } } } }
          }
        }
      end

      it { expect(helper.call(User, structure)).to eq expected }
    end

    context "without associations" do
      it { expect(helper.call(Phone, structure)).to eq_hash({}) }
    end
  end
end
