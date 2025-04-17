class Portfolio < ApplicationRecord
  belongs_to :customer
  has_many :portfolio_investments, dependent: :destroy
  has_many :investments, through: :portfolio_investments

  validates :label, :portfolio_type, presence: true
end
