# frozen_string_literal: true

class PortfolioInvestment < ApplicationRecord
  belongs_to :portfolio
  belongs_to :investment

  validates :amount_invested, numericality: { greater_than: 0, message: 'must be greater than 0' }
  validates :portfolio_id, uniqueness: { scope: :investment_id, message: 'can only invest once in the same investment' }
end
