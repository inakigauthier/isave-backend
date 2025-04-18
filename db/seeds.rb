# frozen_string_literal: true

puts 'Resetting database...'
Customer.destroy_all
Portfolio.destroy_all
Investment.destroy_all
PortfolioInvestment.destroy_all

puts 'Seeding database...'
customer = Customer.create!(name: 'Gauthier')

apple = Investment.create!(isin: 'FR0000120172', investment_types: 'stock', label: 'Apple Inc.', price: 150.0, sri: 6)
french_bond = Investment.create!(isin: 'FR0000131104', investment_types: 'bond', label: "Obligation d'État Française",
                                 price: 200.0, sri: 3)
microsoft = Investment.create!(isin: 'FR0004567890', investment_types: 'stock', label: 'Microsoft Corp.', price: 180.0,
                               sri: 6)
enterprise_bond = Investment.create!(isin: 'FR0000456789', investment_types: 'bond',
                                     label: "Obligation d'Entreprise Française", price: 220.0, sri: 4)
amazon = Investment.create!(isin: 'FR0000678910', investment_types: 'stock', label: 'Amazon Inc.', price: 160.0, sri: 6)
facebook = Investment.create!(isin: 'FR0000789012', investment_types: 'stock', label: 'Facebook Inc.', price: 190.0,
                              sri: 6)
municipal_bond = Investment.create!(isin: 'FR0000901234', investment_types: 'bond',
                                    label: 'Obligation Municipale Française', price: 210.0, sri: 4)
etf_world = Investment.create!(isin: 'FR0012345678', investment_types: 'stock', label: 'iShares Core MSCI World ETF',
                               price: 50.0, sri: 6)
vanguard_bond = Investment.create!(isin: 'FR0012345679', investment_types: 'bond',
                                   label: 'Vanguard Total Bond Market ETF', price: 100.0, sri: 5)

cto_portfolio = Portfolio.create!(
  label: "Portefeuille d'actions",
  portfolio_type: 'CTO',
  total_amount: 87_500.0,
  customer: customer
)

pea_portfolio = Portfolio.create!(
  label: 'PEA - Portefeuille Équilibré',
  portfolio_type: 'PEA',
  total_amount: 30_000.0,
  customer: customer
)

life_portfolio = Portfolio.create!(
  label: "Assurance Vie - Plan d'Épargne",
  portfolio_type: 'Assurance Vie',
  total_amount: 100_000.0,
  customer: customer
)

PortfolioInvestment.create!(portfolio: cto_portfolio, investment: apple, amount_invested: 15_000)
PortfolioInvestment.create!(portfolio: cto_portfolio, investment: french_bond, amount_invested: 10_000)
PortfolioInvestment.create!(portfolio: cto_portfolio, investment: microsoft, amount_invested: 12_600)
PortfolioInvestment.create!(portfolio: cto_portfolio, investment: enterprise_bond, amount_invested: 9900)
PortfolioInvestment.create!(portfolio: cto_portfolio, investment: amazon, amount_invested: 14_400)
PortfolioInvestment.create!(portfolio: cto_portfolio, investment: facebook, amount_invested: 11_400)
PortfolioInvestment.create!(portfolio: cto_portfolio, investment: municipal_bond, amount_invested: 11_550)

PortfolioInvestment.create!(portfolio: pea_portfolio, investment: etf_world, amount_invested: 20_000)
PortfolioInvestment.create!(portfolio: pea_portfolio, investment: vanguard_bond, amount_invested: 10_000)

PortfolioInvestment.create!(portfolio: life_portfolio, investment: french_bond, amount_invested: 12_000)
PortfolioInvestment.create!(portfolio: life_portfolio, investment: enterprise_bond, amount_invested: 88_000)

puts 'historical values'

HistoricalValueImporterJob.perform_now

puts 'Import completed.'
puts 'Seeding done!'
