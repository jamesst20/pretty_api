# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 20_240_531_052_651) do
  create_table "company_cars", force: :cascade do |t|
    t.integer "organization_id"
    t.string "brand"
    t.index ["organization_id"], name: "index_company_cars_on_organization_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.index ["user_id"], name: "index_organizations_on_user_id"
  end

  create_table "phones", force: :cascade do |t|
    t.integer "service_id", null: false
    t.string "number"
    t.index ["service_id"], name: "index_phones_on_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.string "name"
    t.index ["organization_id"], name: "index_services_on_organization_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.integer "parent_id"
    t.index ["parent_id"], name: "index_users_on_parent_id"
  end

  add_foreign_key "organizations", "users"
  add_foreign_key "phones", "services"
  add_foreign_key "services", "organizations"
  add_foreign_key "users", "users", column: "parent_id"
end
