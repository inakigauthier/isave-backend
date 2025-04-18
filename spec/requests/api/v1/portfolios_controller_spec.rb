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
        expect(json['contracts']).to be_an(Array)
        expect(json['contracts'].first['label']).to eq(portfolio.label)
        expect(json['contracts'].first['amount']).to eq(portfolio.total_amount.to_f)
      end

      it 'includes investments and their details' do
        json = JSON.parse(response.body)
        portfolio_data = json['contracts'].first
        investment_data = portfolio_data['lines'].first

        expect(investment_data['label']).to eq(investment.label)
        expect(investment_data['amount']).to eq(portfolio_investment.amount_invested.to_f)
        expect(investment_data['share']).to eq((portfolio_investment.amount_invested.to_f / portfolio.total_amount.to_f))
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


  describe 'POST /api/v1/customers/:customer_id/portfolios/:id/withdraw' do
    context "with valid withdrawal" do
      it "reduces the amount invested and portfolio total amount" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/withdraw", params: {
          investment_id: investment.id,
          amount: 5000
        }
  
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
  
        expect(json["investment"]["amount_invested"].to_i).to eq(5000)
        expect(json["total_portfolio_amount"].to_i).to eq(95000)
      end
    end
  
    context "with invalid withdrawal amount" do
      it "returns an error if amount is too high" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/withdraw", params: {
          investment_id: investment.id,
          amount: 20_000
        }
  
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not enough funds in this investment.")
      end
    end
  end

  describe 'POST /api/v1/customers/:customer_id/portfolios/:id/arbitrate' do
    let!(:customer) { Customer.create!(name: "Gauthier") }
    let!(:portfolio) { Portfolio.create!(label: "CTO Portfolio", portfolio_type: "CTO", total_amount: 100_000, customer: customer) }
  
    let!(:investment_a) { Investment.create!(isin: "FR0000000001", investment_types: "ETF", label: "A", price: 100, sri: 3) }
    let!(:investment_b) { Investment.create!(isin: "FR0000000002", investment_types: "ETF", label: "B", price: 100, sri: 4) }
  
    let!(:pi_a) { PortfolioInvestment.create!(portfolio: portfolio, investment: investment_a, amount_invested: 10_000) }
    let!(:pi_b) { PortfolioInvestment.create!(portfolio: portfolio, investment: investment_b, amount_invested: 5_000) }
  
    context "with valid parameters" do
      it "moves funds between investments" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/arbitrate", params: {
          from_investment_id: investment_a.id,
          to_investment_id: investment_b.id,
          amount: 3000
        }
  
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Arbitrage completed successfully.")
  
        expect(pi_a.reload.amount_invested).to eq(7000)
        expect(pi_b.reload.amount_invested).to eq(8000)
      end
    end
  
    context "when from investment doesn't exist in portfolio" do
      it "returns 404" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/arbitrate", params: {
          from_investment_id: 999,
          to_investment_id: investment_b.id,
          amount: 1000
        }
  
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("From investment not found in portfolio")
      end
    end
  
    context "when to investment doesn't exist in portfolio" do
      it "returns 404" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/arbitrate", params: {
          from_investment_id: investment_a.id,
          to_investment_id: 999,
          amount: 1000
        }
  
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Destination investment not found in portfolio")
      end
    end
  
    context "when amount is more than available" do
      it "returns 422" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/arbitrate", params: {
          from_investment_id: investment_a.id,
          to_investment_id: investment_b.id,
          amount: 20_000
        }
  
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not enough funds")
      end
    end
  
    context "when portfolio type is not allowed" do
      let!(:restricted_portfolio) { Portfolio.create!(label: "PER Portfolio", portfolio_type: "PER", total_amount: 50_000, customer: customer) }
      let!(:pi1) { PortfolioInvestment.create!(portfolio: restricted_portfolio, investment: investment_a, amount_invested: 10_000) }
      let!(:pi2) { PortfolioInvestment.create!(portfolio: restricted_portfolio, investment: investment_b, amount_invested: 10_000) }
  
      it "returns 403 Forbidden" do
        post "/api/v1/customers/#{customer.id}/portfolios/#{restricted_portfolio.id}/arbitrate", params: {
          from_investment_id: investment_a.id,
          to_investment_id: investment_b.id,
          amount: 1000
        }
  
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Arbitration only allowed on CTO or PEA")
      end
    end
  end
  

end



