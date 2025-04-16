class Api::V1::PortfoliosController < ApplicationController
    def index
        customer = Customer.find(params[:id])
        portfolios = customer.portfolios.includes(:investments, :portfolio_investments)

        render json: portfolios.map { |portfolio|
          total = portfolio.total_amount.to_f
          {
            id: portfolio.id,
            label: portfolio.label,
            type: portfolio.portfolio_type,
            total_amount: total,
            investments: portfolio.portfolio_investments.map { |pi|
              investment = pi.investment
              share = ((pi.amount_invested.to_f / total) * 100)

              {
                id: investment.id,
                label: investment.label,
                isin: investment.isin,
                type: investment.investment_types,
                price: investment.price.to_f,
                sri: investment.sri,
                amount_invested: pi.amount_invested.to_f,
                share: share
              }
            }
          }
        }
    rescue ActiveRecord::RecordNotFound
        render json: { error: "Customer not found" }, status: :not_found
    end
end
