require 'rails_helper'

RSpec.describe HistoricalValueImporterJob, type: :job do
  let!(:portfolio) { Portfolio.create!(label: "Test Portfolio", portfolio_type: "CTO", total_amount: 10000, customer: Customer.create!(name: "Test")) }

  let(:json_data) do
    {
      "Test Portfolio" => [
        { "date" => "01-01-23", "amount" => 1000 },
        { "date" => "08-01-23", "amount" => 1100 }
      ]
    }.to_json
  end

  before do
    allow(File).to receive(:read).and_return(json_data)
  end

  it "imports historical values from JSON file" do
    expect {
      described_class.perform_now
    }.to change { HistoricalValue.count }.by(2)

    record = HistoricalValue.first
    expect(record.portfolio.label).to eq("Test Portfolio")
    expect(record.date).to eq(Date.new(2023, 1, 1))
    expect(record.amount).to eq(1000)
  end
end
