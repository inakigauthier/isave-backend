require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      customer = Customer.new(name: "GAUTHIER")
      expect(customer).to be_valid
    end

    it "is not valid without a name" do
      customer = Customer.new(name: nil)
      expect(customer).not_to be_valid
      expect(customer.errors[:name]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "can have many portfolios" do
      customer = Customer.create!(name: "GAUTHIER")
      customer.portfolios.create!(label: "Prudent", portfolio_type: "Prudent", total_amount: 100_000)
      customer.portfolios.create!(label: "Balanced", portfolio_type: "Balanced", total_amount: 150_000)

      expect(customer.portfolios.count).to eq(2)
    end
  end
end

