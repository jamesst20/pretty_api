class CreatePhone < ActiveRecord::Migration[7.1]
  def change
    create_table :phones do |t|
      t.references :service, null: false, foreign_key: true
      t.string :number
    end
  end
end
