Customer.destroy_all
Portfolio.destroy_all
Investment.destroy_all
PortfolioInvestment.destroy_all

customer = Customer.create!(name: "Gauthier")

bond = Investment.create!(isin: "FR0000000001", investment_types: "Bond", label: "Government Bond", price: 100, sri: 1)
etf = Investment.create!(isin: "FR0000000002", investment_types: "ETF", label: "Balanced ETF", price: 200, sri: 3)
stock = Investment.create!(isin: "FR0000000003", investment_types: "Stock", label: "Tech Stock", price: 500, sri: 6)
crypto = Investment.create!(isin: "FR0000000004", investment_types: "Crypto", label: "Bitcoin", price: 30000, sri: 7)

# Prudent: low-risk investments
prudent_portfolio = Portfolio.create!(
  label: "Prudent Portfolio",
  portfolio_type: "Life Insurance",
  total_amount: 50000,
  customer: customer
)

# Balanced: medium risk
balanced_portfolio = Portfolio.create!(
  label: "Balanced Portfolio",
  portfolio_type: "PEA",
  total_amount: 70000,
  customer: customer
)

# Aggressive: high-risk investments
aggressive_portfolio = Portfolio.create!(
  label: "Aggressive Portfolio",
  portfolio_type: "CTO",
  total_amount: 90000,
  customer: customer
)


# Prudent Portfolio
PortfolioInvestment.create!(portfolio: prudent_portfolio, investment: bond, amount_invested: 40000)
PortfolioInvestment.create!(portfolio: prudent_portfolio, investment: etf, amount_invested: 10000)

# Balanced Portfolio
PortfolioInvestment.create!(portfolio: balanced_portfolio, investment: bond, amount_invested: 20000)
PortfolioInvestment.create!(portfolio: balanced_portfolio, investment: etf, amount_invested: 30000)
PortfolioInvestment.create!(portfolio: balanced_portfolio, investment: stock, amount_invested: 20000)

# Aggressive Portfolio
PortfolioInvestment.create!(portfolio: aggressive_portfolio, investment: stock, amount_invested: 40000)
PortfolioInvestment.create!(portfolio: aggressive_portfolio, investment: crypto, amount_invested: 50000)
