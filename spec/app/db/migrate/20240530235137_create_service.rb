class CreateService < ActiveRecord::Migration[7.1]
  def change
    create_table :services do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
    end
  end
end
