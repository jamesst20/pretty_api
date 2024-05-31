class CreateCompanyCar < ActiveRecord::Migration[7.1]
  def change
    create_table :company_cars do |t|
      t.references :organization

      t.string :brand
    end
  end
end
