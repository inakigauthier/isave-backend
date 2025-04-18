# frozen_string_literal: true

# spec/requests/api/v1/insights_spec.rb

require 'rails_helper'

RSpec.describe 'Insights API', type: :request do
  describe 'GET /api/v1/customers/:id/insights' do
    let(:customer) { Customer.create!(name: 'Gauthier') }

    let(:investment_etf) do
      Investment.create!(isin: 'FR0000000001', investment_types: 'ETF Monde', label: 'Amundi', sri: 3,
                         investment_types: 'ETF', price: 100.0)
    end
    let(:investment_stock) do
      Investment.create!(isin: 'FR0000000002', investment_types: 'Action Tech', sri: 6, label: 'Amundi',
                         investment_types: 'Stock', price: 100.0)
    end

    let(:portfolio1) do
      Portfolio.create!(label: 'Portefeuille A', total_amount: 30_000, customer: customer, portfolio_type: 'CTO')
    end
    let(:portfolio2) do
      Portfolio.create!(label: 'Portefeuille B', total_amount: 20_000, customer: customer, portfolio_type: 'CTO')
    end

    before do
      PortfolioInvestment.create!(portfolio: portfolio1, investment: investment_etf, amount_invested: 10_000)
      PortfolioInvestment.create!(portfolio: portfolio1, investment: investment_stock, amount_invested: 20_000)

      PortfolioInvestment.create!(portfolio: portfolio2, investment: investment_etf, amount_invested: 20_000)
    end

    it 'returns investment indicators for the customer' do
      get "/api/v1/customers/#{customer.id}/insights"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json['portfolios'].size).to eq(2)

      # Vérification du premier portefeuille
      portfolio_a = json['portfolios'].find { |p| p['label'] == 'Portefeuille A' }
      expect(portfolio_a['risk']).to eq(5.0)
      expect(portfolio_a['allocation_by_type']).to eq({
                                                        'ETF' => 33.33,
                                                        'Stock' => 66.67
                                                      })

      # Vérification du second portefeuille
      portfolio_b = json['portfolios'].find { |p| p['label'] == 'Portefeuille B' }
      expect(portfolio_b['risk']).to eq(3.0)
      expect(portfolio_b['allocation_by_type']).to eq({
                                                        'ETF' => 100.0
                                                      })

      # Vérification globaux
      expect(json['global_risk']).to eq(4.2)
      expect(json['global_allocation_by_type']).to eq({
                                                        'ETF' => 60.0,
                                                        'Stock' => 40.0
                                                      })
    end

    it 'returns an error if the customer does not exist' do
      get '/api/v1/customers/9999/insights'

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Customer not found')
    end
  end
end
