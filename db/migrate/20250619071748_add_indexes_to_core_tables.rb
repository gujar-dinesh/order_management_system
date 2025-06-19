class AddIndexesToCoreTables < ActiveRecord::Migration[7.0]
  def change
    # Index for faster order lookup by user
    # add_index :orders, :user_id

    # Index for filtering orders by status
    add_index :orders, :status

    # Index for item lookup (and enforce uniqueness of names)
    add_index :inventory_items, :name, unique: true

    # Ensure quick user lookups and uniqueness
    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
  end
end