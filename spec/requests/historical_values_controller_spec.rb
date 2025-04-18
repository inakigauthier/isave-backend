# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::HistoricalValues', type: :request do
  let!(:customer) { Customer.create!(name: 'Test Customer') }

  let!(:portfolio) do
    Portfolio.create!(
      label: 'Test Portfolio',
      portfolio_type: 'CTO',
      total_amount: 10_000,
      customer: customer
    )
  end

  let!(:historical_value_one) do
    HistoricalValue.create!(
      portfolio: portfolio,
      date: Date.new(2023, 1, 1),
      amount: 9000
    )
  end

  let!(:historical_value_two) do
    HistoricalValue.create!(
      portfolio: portfolio,
      date: Date.new(2023, 2, 1),
      amount: 9500
    )
  end

  describe 'GET /api/v1/customers/:customer_id/portfolios/:id/historical_values' do
    context 'when the customer and portfolio exist' do
      it 'returns the historical values ordered by date' do
        get "/api/v1/customers/#{customer.id}/portfolios/#{portfolio.id}/historical_values"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json.size).to eq(2)
        expect(json.first['date']).to eq('2023-01-01')
        expect(json.first['amount']).to eq(9000.0)
        expect(json.last['date']).to eq('2023-02-01')
        expect(json.last['amount']).to eq(9500.0)
      end
    end

    context 'when the customer or portfolio does not exist' do
      it 'returns a 404 error' do
        get '/api/v1/customers/9999/portfolios/9999/historical_values'

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Customer not found')
      end
    end
  end
end
