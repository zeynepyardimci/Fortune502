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

ActiveRecord::Schema[8.1].define(version: 2026_10_16_140000) do
  create_table "cost_alerts", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.string "alert_type", null: false
    t.boolean "acknowledged", default: false, null: false
    t.integer "acknowledged_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acknowledged_by_id"], name: "index_cost_alerts_on_acknowledged_by_id"
    t.index ["warehouse_id"], name: "index_cost_alerts_on_warehouse_id"
  end

  create_table "credit_usage_logs", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.decimal "credits_spent", precision: 10, scale: 4, null: false
    t.string "query_signature"
    t.datetime "executed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["warehouse_id"], name: "index_credit_usage_logs_on_warehouse_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.string "cost_center_code", null: false
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cost_center_code"], name: "index_departments_on_cost_center_code", unique: true
    t.index ["owner_id"], name: "index_departments_on_owner_id"
  end

  create_table "status_events", force: :cascade do |t|
    t.integer "warehouse_id", null: false
    t.string "from_status", null: false
    t.string "to_status", null: false
    t.string "reason", null: false
    t.integer "triggered_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["triggered_by_id"], name: "index_status_events_on_triggered_by_id"
    t.index ["warehouse_id"], name: "index_status_events_on_warehouse_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "full_name", null: false
    t.string "role", default: "analyst", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "name", null: false
    t.string "size", default: "small", null: false
    t.string "status", default: "active", null: false
    t.decimal "credit_quota", precision: 12, scale: 2, default: "1000.0", null: false
    t.decimal "credits_used", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "warning_threshold_pct", default: 80, null: false
    t.datetime "sla_target_at"
    t.integer "department_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_warehouses_on_department_id"
    t.index ["status"], name: "index_warehouses_on_status"
  end

  add_foreign_key "cost_alerts", "users", column: "acknowledged_by_id"
  add_foreign_key "cost_alerts", "warehouses"
  add_foreign_key "credit_usage_logs", "warehouses"
  add_foreign_key "departments", "users", column: "owner_id"
  add_foreign_key "status_events", "users", column: "triggered_by_id"
  add_foreign_key "status_events", "warehouses"
  add_foreign_key "warehouses", "departments"
end
