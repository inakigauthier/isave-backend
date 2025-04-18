# frozen_string_literal: true

module Api
  module V1
    class HistoricalValuesController < ApplicationController
      include FindablePortfolio
      def index
        history = @portfolio.historical_values.order(:date)

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
  end
end
