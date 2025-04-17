require 'rails_helper'

RSpec.describe Portfolio, type: :model do
  let(:customer) { Customer.create(name: "GAUTHIER") }

  it "is invalid without a label" do
    portfolio = Portfolio.new(
      label: nil,
      portfolio_type: "long_term",
      total_amount: 1000,
      customer: customer
    )
    expect(portfolio).not_to be_valid
    expect(portfolio.errors[:label]).to include("can't be blank")
  end

  it "is invalid without a portfolio_type" do
    portfolio = Portfolio.new(
      label: "Tech Portfolio",
      portfolio_type: nil,
      total_amount: 1000,
      customer: customer
    )
    expect(portfolio).not_to be_valid
    expect(portfolio.errors[:portfolio_type]).to include("can't be blank")
  end
end

