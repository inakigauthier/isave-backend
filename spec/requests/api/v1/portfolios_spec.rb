require 'rails_helper'

RSpec.describe 'Api::V1::Portfolios', type: :request do
  let!(:customer) { Customer.create!(name: "GAUTHIER Inaki") }
  let!(:portfolio) { Portfolio.create!(label: "Prudent Portfolio", portfolio_type: "CTO", total_amount: 100_000, customer: customer) }
  let!(:investment) { Investment.create!(isin: "FR0000000001", investment_types: "ETF", label: "Amundi", price: 100.0, sri: 5) }
  let!(:portfolio_investment) { PortfolioInvestment.create!(portfolio: portfolio, investment: investment, amount_invested: 10_000) }

  describe 'GET /api/v1/customers/:id/portfolios' do
    context 'when the customer exists' do
      before do
        get "/api/v1/customers/#{customer.id}/portfolios"
      end

      it 'returns a list of portfolios' do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to be_an(Array)
        expect(json.first['label']).to eq(portfolio.label)
        expect(json.first['total_amount']).to eq(portfolio.total_amount.to_f)
      end

      it 'includes investments and their details' do
        json = JSON.parse(response.body)
        portfolio_data = json.first
        investment_data = portfolio_data['investments'].first

        expect(investment_data['label']).to eq(investment.label)
        expect(investment_data['amount_invested']).to eq(portfolio_investment.amount_invested.to_f)
        expect(investment_data['share']).to eq((portfolio_investment.amount_invested.to_f / portfolio.total_amount.to_f) * 100)
      end
    end

    context 'when the customer does not exist' do
      it 'returns a 404 not found' do
        get '/api/v1/customers/999999/portfolios'
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Customer not found')
      end
    end
  end

  describe 'POST /api/v1/customers/:customer_id/portfolios/:id/deposit' do
    context "with valid params" do
      it "increases the amount invested and portfolio total amount" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/deposit", params: {
          investment_id: investment.id,
          amount: 5000
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json["investment"]["amount_invested"].to_i).to eq(15_000.0)
        expect(json["total_portfolio_amount"].to_i).to eq(105_000.0)
      end
    end

    context "when portfolio type is not allowed" do
      let!(:portfolio) { Portfolio.create!(label: "Other", portfolio_type: "Other", total_amount: 100_000, customer: customer) }
    
      it "returns a 403 Forbidden" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/deposit", params: {
          investment_id: investment.id,
          amount: 5000
        }
    
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Deposits are only allowed for CTO or PEA portfolios")
      end
    end
  end
  
end
