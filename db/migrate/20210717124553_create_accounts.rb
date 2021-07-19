class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :currency, limit: 10
      t.decimal :amount, default: 0

      t.timestamps
    end
  end
end
