module Api
    module V1
      class InsightsController < ApplicationController
        def show
          customer = Customer.find(params[:id])
          portfolios = customer.portfolios
  
          portfolios_insights = portfolios.map do |portfolio|
            total = portfolio.total_amount.to_f
  
            investment_data = portfolio.portfolio_investments.map do |pi|
              {
                sri: pi.investment.sri,
                amount: pi.amount_invested.to_f,
                type: pi.investment.investment_types
              }
            end
  
            {
              id: portfolio.id,
              label: portfolio.label,
              risk: weighted_risk(investment_data, total),
              allocation_by_type: allocation_by_type(investment_data, total)
            }
          end

          # for all investiments
  
          all_investments = portfolios.flat_map(&:portfolio_investments)
          global_total = portfolios.sum(&:total_amount).to_f
  
          global_data = all_investments.map do |pi|
            {
              sri: pi.investment.sri,
              amount: pi.amount_invested.to_f,
              type: pi.investment.investment_types
            }
          end
  
          render json: {
            portfolios: portfolios_insights,
            global_risk: weighted_risk(global_data, global_total),
            global_allocation_by_type: allocation_by_type(global_data, global_total)
          }
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Customer not found" }, status: :not_found
        end
  
        private
  

        # moyenne pondérée
        def weighted_risk(data, total)
          return 0 if total.zero?
  
          sum = data.sum { |d| d[:sri].to_f * d[:amount] }
          (sum / total).round(2)
        end
  
        def allocation_by_type(data, total)
          return {} if total.zero?
        
          amounts_by_type = {}
        
          data.each do |entry|
            type = entry[:type]
            amount = entry[:amount].to_f


        
            if amounts_by_type.key?(type)
              amounts_by_type[type] += amount
            else
              amounts_by_type[type] = amount
            end
          end
        
          allocation = {}
        
          amounts_by_type.each do |type, amount|
            percentage = (amount / total) * 100
            allocation[type] = percentage.round(2)
          end
        
          allocation
        end
        
      end
    end
  end
  