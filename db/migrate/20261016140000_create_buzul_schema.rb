class CreateBuzulSchema < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false
      t.string :role, null: false, default: "analyst"

      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :departments do |t|
      t.string :name, null: false
      t.string :cost_center_code, null: false
      t.references :owner, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :departments, :cost_center_code, unique: true

    create_table :warehouses do |t|
      t.string :name, null: false
      t.string :size, null: false, default: "small"
      t.string :status, null: false, default: "active"
      t.decimal :credit_quota, precision: 12, scale: 2, null: false, default: 1000.0
      t.decimal :credits_used, precision: 12, scale: 2, null: false, default: 0.0
      t.integer :warning_threshold_pct, null: false, default: 80
      t.datetime :sla_target_at
      t.references :department, null: false, foreign_key: true

      t.timestamps
    end
    add_index :warehouses, :status

    create_table :credit_usage_logs do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.decimal :credits_spent, precision: 10, scale: 4, null: false
      t.string :query_signature
      t.datetime :executed_at, null: false

      t.timestamps
    end

    create_table :status_events do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.string :from_status, null: false
      t.string :to_status, null: false
      t.string :reason, null: false
      t.references :triggered_by, foreign_key: { to_table: :users }

      t.timestamps
    end

    create_table :cost_alerts do |t|
      t.references :warehouse, null: false, foreign_key: true
      t.string :alert_type, null: false
      t.boolean :acknowledged, default: false, null: false
      t.references :acknowledged_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
