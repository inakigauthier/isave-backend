class CreatePortfolios < ActiveRecord::Migration[7.1]
  def change
    create_table :portfolios do |t|
      t.string :label
      t.string :type
      t.decimal :total_amount
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
