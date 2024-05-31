class CreateOrganization < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name
    end
  end
end
