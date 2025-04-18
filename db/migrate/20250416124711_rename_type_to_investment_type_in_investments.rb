# frozen_string_literal: true

class RenameTypeToInvestmentTypeInInvestments < ActiveRecord::Migration[7.1]
  # can't use type as column named because type is for inherance in rails
  def change
    rename_column :investments, :type, :investment_types
  end
end
