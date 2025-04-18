# frozen_string_literal: true

module FindablePortfolio
  extend ActiveSupport::Concern

  included do
    before_action :set_customer
    before_action :set_portfolio
  end

  private

  def set_customer
    @customer = Customer.find(params[:customer_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Customer not found' }, status: :not_found
    nil
  end

  def set_portfolio
    @portfolio = @customer.portfolios.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Portfolio not found' }, status: :not_found
    nil
  end

  def allowed_portfolio_type?(portfolio)
    %w[CTO PEA].include?(portfolio.portfolio_type.upcase)
  end
end
