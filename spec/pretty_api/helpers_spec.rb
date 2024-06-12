require "spec_helper"

RSpec.describe PrettyApi::Helpers do
  subject(:klass) { Class.new { include PrettyApi::Helpers } }

  let(:helper) { klass.new.method(:pretty_nested_attributes) }
  let(:record) { build_stubbed :organization }

  describe "#pretty_nested_attributes" do
    context "with method aliases" do
      let(:instance) { klass.new }

      it { expect(instance.method(:pretty_nested_attributes)).to eq(instance.method(:pretty_attrs)) }
      it { expect(instance.method(:pretty_nested_errors)).to eq(instance.method(:pretty_errors)) }
    end

    context "with request parameters" do
      let(:params) { { services: [] } }

      it "doesn't edit original request parameters" do
        expect(helper.call(record, params)).not_to eq_hash(params)
      end
    end

    context "with default model reflections" do
      context "with typical json format" do
        context "with empty attributes" do
          it { expect(helper.call(record, {})).to eq_hash({}) }
        end

        context "with basic attributes" do
          let(:params) { { name: "Test" } }

          it { expect(helper.call(record, params)).to eq_hash(params) }
        end

        context "with nested attributes" do
          context "with has_many association" do
            context "when adding new item" do
              let(:params) { { name: "Test", services: [{ name: "New service" }] } }
              let(:expected) { { name: "Test", services_attributes: [{ name: "New service" }] } }

              it { expect(helper.call(record, params)).to eq_hash(expected) }
            end

            context "when implicitly removing item" do
              let(:record) { create :organization, :with_service }
              let(:params) { { name: "Test", services: [] } }
              let(:expected) do
                { name: "Test", services_attributes: [{ id: record.services.first.id, _destroy: true }] }
              end

              it { expect(helper.call(record, params)).to eq_hash(expected) }
            end

            context "when explicitly removing item" do
              let(:record) { create :organization, :with_service }
              let(:params) { { name: "Test", services_attributes: [{ id: record.services.first.id, _destroy: true }] } }

              it { expect(helper.call(record, params)).to eq_hash(params) }
            end

            context "when doing nothing" do
              let(:record) { create :organization, :with_service }
              let(:params) { { name: "Test" } }

              it { expect(helper.call(record, params)).to eq_hash(params) }
            end

            context "when implicitly remove items in wrong order" do
              let(:record) do
                create :organization,
                       services: [build(:service, phones: [build(:phone), build(:phone)]),
                                  build(:service, phones: [build(:phone), build(:phone)])]
              end

              let(:params) do
                { services: [{ id: record.services[1].id },
                             { id: record.services[0].id, phones: [{ id: record.services[0].phones[1].id }] }] }
              end

              let(:expected) do
                {
                  services_attributes: [
                    { id: record.services[1].id },
                    { id: record.services[0].id,
                      phones_attributes: [{ id: record.services[0].phones[1].id },
                                          { id: record.services[0].phones[0].id, _destroy: true }] }
                  ]
                }
              end

              it { expect(helper.call(record, params)).to eq_hash(expected) }
            end
          end

          context "with has_one association" do
            context "when adding new item" do
              let(:params) { { name: "Test", company_car: { name: "New car" } } }
              let(:expected) { { name: "Test", company_car_attributes: { name: "New car" } } }

              it { expect(helper.call(record, params)).to eq_hash(expected) }
            end

            context "when implicitly removing item" do
              let(:record) { create :organization, :with_company_car }
              let(:params) { { name: "Test", company_car: nil } }
              let(:expected) { { name: "Test", company_car_attributes: { id: record.company_car.id, _destroy: true } } }

              it { expect(helper.call(record, params)).to eq_hash(expected) }
            end

            context "when explicitly removing item" do
              let(:record) { create :organization, :with_company_car }
              let(:params) { { name: "Test", company_car_attributes: { id: record.company_car, _destroy: true } } }

              it { expect(helper.call(record, params)).to eq_hash(params) }
            end

            context "when doing nothing" do
              let(:record) { create :organization, :with_company_car }
              let(:params) { { name: "Test" } }

              it { expect(helper.call(record, params)).to eq_hash(params) }
            end
          end

          context "with belongs_to association" do
            let(:record) { create :company_car }

            context "when updating an item" do
              let(:params) { { organization: { id: record.organization_id, name: "New name" } } }
              let(:expected) { { organization_attributes: { id: record.organization_id, name: "New name" } } }

              it { expect(helper.call(record, params)).to eq_hash(expected) }
            end

            context "when implicitly removing item" do
              let(:params) { { organization: nil } }
              let(:expected) { { organization_attributes: { id: record.organization_id, _destroy: true } } }

              it { expect(helper.call(record, params)).to eq_hash(expected) }
            end

            context "when explicitly removing item" do
              let(:params) { { organization_attributes: { id: record.organization_id, _destroy: true } } }

              it { expect(helper.call(record, params)).to eq_hash(params) }
            end

            context "when doing nothing" do
              let(:params) { { brand: "Test" } }

              it { expect(helper.call(record, params)).to eq_hash(params) }
            end
          end
        end

        context "with deep nested attributes" do
          context "when adding new item" do
            let(:record) { create :organization, :with_service_and_phone }
            let(:service) { record.services.first }
            let(:phone) { service.phones.first }
            let(:params) { { services: [{ id: service.id, phones: [{ number: "123" }] }] } }
            let(:expected) do
              {
                services_attributes: [
                  { id: service.id, phones_attributes: [{ number: "123" }, { id: phone.id, _destroy: true }] }
                ]
              }
            end

            it { expect(helper.call(record, params)).to eq_hash(expected) }
          end
        end

        context "without associations" do
          let(:record) { create :phone }
          let(:params) { { id: record.id, number: "456" } }
          let(:expected) do
            { id: record.id, number: "456" }
          end

          it { expect(helper.call(record, params)).to eq_hash(expected) }
        end
      end

      context "with hash format (typically form-urlencoded or multipart/form-data)" do
        context "when implicitly removing item and adding items" do
          let(:record) { create :organization, :with_service }
          let(:params) do
            { name: "Test", services: {
              "1234" => { name: "New service 1", phones: { "0" => { number: "123" } } },
              "9876" => { name: "New service 2" }
            } }
          end

          let(:expected) do
            { name: "Test",
              services_attributes: [
                { name: "New service 1", phones_attributes: [{ number: "123" }] },
                { name: "New service 2" },
                { id: record.services.first.id, _destroy: true }
              ] }
          end

          it { expect(helper.call(record, params)).to eq_hash(expected) }
        end
      end
    end
  end

  describe "#pretty_nested_errors" do
    let(:helper) { Class.new { include PrettyApi::Helpers }.new.method(:pretty_nested_errors) }

    context "with deep errors" do
      context "with basic errors" do
        let(:record) { create :organization, :with_service_and_phone, :with_company_car }
        let(:expected) do
          {
            name: ["can't be blank"],
            company_car: { brand: ["can't be blank"] },
            services: {
              0 => {
                name: ["can't be blank"],
                phones: {
                  0 => { number: ["can't be blank"] }
                }
              }
            }
          }
        end

        before do
          record.name = nil
          record.company_car.brand = nil
          record.services.each do |service|
            service.name = nil
            service.phones.each do |phone|
              phone.number = nil
            end
          end
          record.validate
        end

        it { expect(record).not_to be_valid }

        it { expect(helper.call(record)).to eq_hash(expected) }
      end

      context "with complex errors" do
        let(:record) do
          create :organization,
                 :with_company_car,
                 services: [
                   build_list(:service, 4, :with_phone),
                   build(:service, phones: build_list(:phone, 3))
                 ].flatten
        end
        let(:expected) do
          {
            company_car: { brand: ["can't be blank"] },
            services: {
              1 => { name: ["can't be blank"]  },
              2 => { name: ["can't be blank"]  },
              4 => { phones: { 2 => { number: ["can't be blank"] } } }
            }
          }
        end

        before do
          record.company_car.brand = nil
          record.services[1].name = nil
          record.services[2].name = nil
          record.services[4].phones[2].number = nil
          record.validate
        end

        it { expect(record).not_to be_valid }

        it { expect(helper.call(record)).to eq_hash(expected) }
      end

      context "with empty object" do
        let(:record) { create :organization }
        let(:expected) { {} }

        before do
          record.services = []
          record.company_car = nil
        end

        it { expect(helper.call(record)).to eq_hash(expected) }
      end
    end
  end
end
