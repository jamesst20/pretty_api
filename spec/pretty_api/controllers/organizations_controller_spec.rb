require "spec_helper"

RSpec.describe OrganizationsController do
  subject(:controller) { described_class.new }

  let(:organization) do
    create :organization, services: [
      build(:service, phones: [build(:phone), build(:phone)])
    ]
  end

  let(:put!) do
    controller.put(params)
    organization.reload
  end

  before { organization }

  context "with nested params" do
    context "when organization and service exists" do
      context "with empty service array" do
        let(:params) do
          {
            organization: {
              id: organization.id,
              name: "Test org 1",
              services: []
            }
          }
        end

        it { expect { put! }.to change(organization, :name).to("Test org 1") }
        it { expect { put! }.to change { organization.services.count }.from(1).to(0) }
        it { expect { put! }.to change(Phone, :count).from(2).to(0) }
      end

      context "without service array" do
        let(:params) do
          {
            organization: {
              id: organization.id,
              name: "Test org 1"
            }
          }
        end

        it { expect { put! }.to change(organization, :name).to("Test org 1") }
        it { expect { put! }.not_to(change { organization.services.count }) }
        it { expect { put! }.not_to change(Phone, :count) }
      end

      context "when updating a service" do
        context "without phone array" do
          let(:params) do
            {
              organization: {
                id: organization.id,
                name: "Test org 1",
                services: organization.services.map do |service|
                  { id: service.id, name: "New name" }
                end
              }
            }
          end

          it { expect { put! }.to change(organization, :name).to("Test org 1") }
          it { expect { put! }.to change { organization.services.first.name }.to("New name") }
          it { expect { put! }.not_to(change { organization.services.first.phones.count }) }
        end

        context "with partial phone array" do
          let(:params) do
            {
              organization: {
                id: organization.id,
                name: "Test org 1",
                services: organization.services.map do |service|
                  {
                    id: service.id,
                    name: "New name",
                    phones: [{ id: service.phones.first.id }]
                  }
                end
              }
            }
          end

          it { expect { put! }.to change(organization, :name).to("Test org 1") }
          it { expect { put! }.to change { organization.services.first.name }.to("New name") }
          it { expect { put! }.to change { organization.services.first.phones.count }.from(2).to(1) }
          it { expect { put! }.not_to(change { organization.services.first.phones.first.id }) }
          it { expect { put! }.to(change { organization.services.first.phones.last.id }) }
        end
      end
    end

    context "when service doesn't exist" do
      let(:organization) do
        create :organization, services: []
      end

      let(:params) do
        {
          organization: {
            id: organization.id,
            name: "Test org 1",
            services: [
              {
                name: "New name",
                phones: [{ number: "1234" }]
              }
            ]
          }
        }
      end

      it { expect { put! }.to change(Service, :count).by(1) }
      it { expect { put! }.to change(Phone, :count).by(1) }
    end
  end
end
