class CreateInvestments < ActiveRecord::Migration[7.1]
  def change
    create_table :investments do |t|
      t.string :isin
      t.string :type
      t.string :label
      t.decimal :price
      t.integer :sri

      t.timestamps
    end
  end
end
