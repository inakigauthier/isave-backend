class Api::V1::HistoricalValuesController < ApplicationController
    def index
      customer = Customer.find(params[:customer_id])
      portfolio = customer.portfolios.find(params[:id])
      history = portfolio.historical_values.order(:date)
  
      render json: history.map { |record|
        {
          date: record.date.strftime('%Y-%m-%d'),
          amount: record.amount.to_f
        }
      }
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Customer or Portfolio not found' }, status: :not_found
    end
  end  