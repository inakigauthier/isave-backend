class Investment < ApplicationRecord
    has_many :portfolio_investments, dependent: :destroy
    has_many :portfolios, through: :portfolio_investments

    validates :isin, :investment_types, :label, :price, :sri, presence: true
end
