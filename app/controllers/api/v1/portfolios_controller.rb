# frozen_string_literal: true

module Api
  module V1
    class PortfoliosController < ApplicationController
      def index
        customer = Customer.find(params[:id])
        portfolios = customer.portfolios.includes(:investments, :portfolio_investments)

        render json: {
          contracts: portfolios.map do |portfolio|
            total = portfolio.total_amount.to_f

            {
              label: portfolio.label,
              type: portfolio.portfolio_type,
              amount: total,
              lines: portfolio.portfolio_investments.map do |pi|
                investment = pi.investment
                share = (pi.amount_invested.to_f / total).round(2)

                {
                  type: investment.investment_types.downcase, # important pour matcher le JSON
                  isin: investment.isin,
                  label: investment.label,
                  price: investment.price.to_f,
                  share: share,
                  amount: pi.amount_invested.to_f,
                  srri: investment.sri
                }
              end
            }
          end
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Customer not found' }, status: :not_found
      end

      def deposit
        portfolio = find_portfolio(params)

        unless %w[CTO PEA].include?(portfolio.portfolio_type)
          return render json: { error: 'Deposits are only allowed for CTO or PEA portfolios' }, status: :forbidden
        end

        investment = portfolio.investments.find(params[:investment_id])
        amount = params[:amount].to_f
        portfolio_investment = PortfolioInvestment.find_by!(portfolio_id: portfolio.id, investment_id: investment.id)
        portfolio_investment.amount_invested += amount
        portfolio_investment.save!

        portfolio.total_amount += amount
        portfolio.save!

        render json: {
          message: 'Deposit successful',
          investment: {
            id: investment.id,
            amount_invested: portfolio_investment.amount_invested
          },
          total_portfolio_amount: portfolio.total_amount
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Portfolio or Investment not found' }, status: :not_found
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def withdraw
        portfolio = find_portfolio(params)

        unless %w[CTO PEA].include?(portfolio.portfolio_type.upcase)
          return render json: { error: 'Withdrawals are only allowed for CTO and PEA portfolios.' }, status: :forbidden
        end

        investment = portfolio.investments.find(params[:investment_id])
        portfolio_investment = PortfolioInvestment.find_by!(portfolio: portfolio, investment: investment)

        amount = params[:amount].to_f

        if amount > portfolio_investment.amount_invested
          return render json: { error: 'Not enough funds in this investment.' }, status: :unprocessable_entity
        end

        portfolio_investment.update!(amount_invested: portfolio_investment.amount_invested - amount)
        portfolio.update!(total_amount: portfolio.total_amount - amount)

        render json: {
          message: 'Withdrawal successful.',
          investment: {
            id: investment.id,
            label: investment.label,
            amount_invested: portfolio_investment.amount_invested
          },
          total_portfolio_amount: portfolio.total_amount
        }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Customer or investment not found' }, status: :not_found
      end

      def arbitrate
        portfolio = find_portfolio(params)

        unless %w[CTO PEA].include?(portfolio.portfolio_type.upcase)
          return render json: { error: 'Arbitration only allowed on CTO or PEA' }, status: :forbidden
        end

        from_id = params[:from_investment_id]
        to_id = params[:to_investment_id]
        amount = params[:amount].to_f

        return render json: { error: 'Amount must be positive' }, status: :unprocessable_entity if amount <= 0

        from_portfolio = portfolio.portfolio_investments.find_by(investment_id: from_id)
        to_portfolio = portfolio.portfolio_investments.find_by(investment_id: to_id)

        unless from_portfolio
          return render json: { error: 'From investment not found in portfolio' },
                        status: :not_found
        end

        unless to_portfolio
          return render json: { error: 'Destination investment not found in portfolio' },
                        status: :not_found
        end

        if from_portfolio.amount_invested < amount
          return render json: { error: 'Not enough funds' },
                        status: :unprocessable_entity
        end

        ActiveRecord::Base.transaction do
          from_portfolio.update!(amount_invested: from_portfolio.amount_invested - amount)
          to_portfolio.update!(amount_invested: to_portfolio.amount_invested + amount)
        end

        render json: { message: 'Arbitrage completed successfully.' }, status: :ok
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      private

      def find_portfolio(params)
        customer = Customer.find(params[:customer_id])
        customer.portfolios.find(params[:id])
      end
    end
  end
end
