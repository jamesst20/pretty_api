class OrganizationsController
  include PrettyApi::Helpers

  def put(params)
    organization = Organization.find(params[:organization][:id])

    result = record_params(organization, params.with_indifferent_access)
    organization.assign_attributes(result)
    organization.save!
  end

  private

  def record_params(record, params)
    pretty_nested_attributes(record, params[:organization])
  end
end
