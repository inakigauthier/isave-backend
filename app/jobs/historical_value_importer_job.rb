require 'json'

class HistoricalValueImporterJob < ApplicationJob
  queue_as :default

  def perform

    file = File.read(Rails.root.join("data/level_4/historical_values.json"))
    json_data = JSON.parse(file)
    
    json_data.each do |portfolio_label, values|
      byebug
      portfolio = Portfolio.find_by(label: portfolio_label)
      next unless portfolio
    
      values.each do |entry|
        HistoricalValue.create!(
          portfolio: portfolio,
          date: Date.strptime(entry["date"], '%d-%m-%y'),
          amount: entry["amount"]
        )
      end
    end
  end
end
