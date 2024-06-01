class CreateOrganization < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name
    end
  end
end
