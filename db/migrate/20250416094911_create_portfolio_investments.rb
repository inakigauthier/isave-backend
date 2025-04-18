class CreatePortfolioInvestments < ActiveRecord::Migration[7.1]
  def change
    create_table :portfolio_investments do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.references :investment, null: false, foreign_key: true
      t.decimal :amount_invested

      t.timestamps
    end
  end
end
