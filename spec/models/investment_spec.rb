# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Investment, type: :model do
  describe 'validations' do
    it 'is valid with all required attributes' do
      investment = Investment.new(
        isin: 'FR0011223344',
        investment_types: 'Bond',
        label: 'Government Bond',
        price: 100.0,
        sri: 2
      )
      expect(investment).to be_valid
    end

    it 'is invalid without an isin' do
      investment = Investment.new(isin: nil, investment_types: 'Bond', label: 'Bond', price: 100.0, sri: 2)
      expect(investment).not_to be_valid
      expect(investment.errors[:isin]).to include("can't be blank")
    end

    it 'is invalid without a label' do
      investment = Investment.new(isin: 'FR0011223344', investment_types: 'Bond', label: nil, price: 100.0, sri: 2)
      expect(investment).not_to be_valid
      expect(investment.errors[:label]).to include("can't be blank")
    end

    it 'is invalid without a price' do
      investment = Investment.new(isin: 'FR0011223344', investment_types: 'Bond', label: 'Bond', price: nil, sri: 2)
      expect(investment).not_to be_valid
      expect(investment.errors[:price]).to include("can't be blank")
    end

    it 'is invalid without a sri' do
      investment = Investment.new(isin: 'FR0011223344', investment_types: 'Bond', label: 'Bond', price: 100.0, sri: nil)
      expect(investment).not_to be_valid
      expect(investment.errors[:sri]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'can be linked to many portfolios through portfolio investments' do
      investment = Investment.create!(
        isin: 'FR0011223344',
        investment_types: 'ETF',
        label: 'S&P 500 ETF',
        price: 350.0,
        sri: 3
      )

      customer = Customer.create!(name: 'GAUTHIER')
      portfolio1 = customer.portfolios.create!(label: 'Balanced', portfolio_type: 'Balanced', total_amount: 50_000)
      portfolio2 = customer.portfolios.create!(label: 'Risky', portfolio_type: 'Risky', total_amount: 80_000)

      PortfolioInvestment.create!(portfolio: portfolio1, investment: investment, amount_invested: 10_000)
      PortfolioInvestment.create!(portfolio: portfolio2, investment: investment, amount_invested: 20_000)

      expect(investment.portfolios.count).to eq(2)
    end
  end
end
