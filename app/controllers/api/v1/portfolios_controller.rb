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

    def deposit
      customer = Customer.find(params[:customer_id])
      portfolio = customer.portfolios.find(params[:id])
    
      unless %w[CTO PEA].include?(portfolio.portfolio_type)
        return render json: { error: "Deposits are only allowed for CTO or PEA portfolios" }, status: :forbidden
      end
    
      investment = portfolio.investments.find(params[:investment_id])
      amount = params[:amount].to_f
      portfolio_investment = PortfolioInvestment.find_by!(portfolio_id: portfolio.id, investment_id: investment.id)
      portfolio_investment.amount_invested += amount
      portfolio_investment.save!
    
      portfolio.total_amount += amount
      portfolio.save!
    
      render json: {
        message: "Deposit successful",
        investment: {
          id: investment.id,
          amount_invested: portfolio_investment.amount_invested
        },
        total_portfolio_amount: portfolio.total_amount
      }
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Portfolio or Investment not found" }, status: :not_found
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
    
end
