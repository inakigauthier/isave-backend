# frozen_string_literal: true

class CreateHistoricalValues < ActiveRecord::Migration[7.1]
  def change
    create_table :historical_values do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.decimal :amount
      t.date :date

      t.timestamps
    end
  end
end
