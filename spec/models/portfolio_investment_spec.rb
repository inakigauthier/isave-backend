require 'rails_helper'

RSpec.describe PortfolioInvestment, type: :model do
  let(:customer) { Customer.create!(name: 'Gauthier') }
  let(:prudent_portfolio) { Portfolio.create!(label: 'Prudent Portfolio', portfolio_type: 'Prudent', total_amount: 200_000, customer: customer) }
  let(:bond) { Investment.create!(isin: 'US1234567890', investment_types: 'Bond', label: 'Government Bond', price: 100, sri: 3) }
  let(:etf) { Investment.create!(isin: 'US9876543210', investment_types: 'ETF', label: 'Global Stock ETF', price: 50, sri: 4) }


  describe "validations" do
    it "is valid with valid attributes" do
      pi = PortfolioInvestment.new(portfolio: prudent_portfolio, investment: bond, amount_invested: 30000)
      expect(pi).to be_valid
    end

    it "is invalid with 0 amount_invested" do
      pi = PortfolioInvestment.new(portfolio: prudent_portfolio, investment: bond, amount_invested: 0)
      expect(pi).not_to be_valid
      expect(pi.errors[:amount_invested]).to include("must be greater than 0")
    end
  
    it "should allow one investment per portfolio" do
      PortfolioInvestment.create!(portfolio: prudent_portfolio, investment: bond, amount_invested: 40_000)

      expect {
        PortfolioInvestment.create!(portfolio: prudent_portfolio, investment: bond, amount_invested: 40_000)
      }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Portfolio can only invest once in the same investment")
    end

    it "should allow multiple investments of different types in a portfolio" do
      PortfolioInvestment.create!(portfolio: prudent_portfolio, investment: bond, amount_invested: 40_000)

      expect {
        PortfolioInvestment.create!(portfolio: prudent_portfolio, investment: etf, amount_invested: 10_000)
      }.not_to raise_error
    end
  end
end

