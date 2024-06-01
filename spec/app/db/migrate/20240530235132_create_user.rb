class CreateUser < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name

      t.references :parent, null: true, foreign_key: { to_table: :users }
    end
  end
end
