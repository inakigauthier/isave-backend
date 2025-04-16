class RenameTypeToPortfolioTypeInPortfolios < ActiveRecord::Migration[7.1]
  def change
    rename_column :portfolios, :type, :portfolio_type
  end
end
