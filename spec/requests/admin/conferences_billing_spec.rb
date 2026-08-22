# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin Conference Billing", type: :request do
  let(:conference) { FactoryBot.create(:conference) }
  let(:plan) { FactoryBot.create(:plan, conference:, price: 300_000, price_text: '30万円') }
  let(:staff) { FactoryBot.create(:staff) }
  let(:session_token) { FactoryBot.create(:session_token, staff:) }

  before do
    FactoryBot.create(:sponsorship, conference:, plan:, accepted_at: Time.current)
    get claim_user_session_path(session_token.handle)
  end

  it 'uses the corporate honorific for the customer' do
    get billing_conference_path(conference, format: :csv)

    expect(invoice_row.fetch(13)).to eq('御中')
  end

  it 'leaves the customer address fields blank' do
    get billing_conference_path(conference, format: :csv)

    expect(invoice_row.values_at(15, 16, 17)).to eq([nil, nil, nil])
  end

  it 'uses the booth price configured on the plan' do
    plan.update!(price_booth: 50_000)
    FactoryBot.create(:sponsorship, conference:, plan:, booth_assigned: true, accepted_at: Time.current)

    get billing_conference_path(conference, format: :csv)

    booth_item = CSV.parse(response.body).find { |row| row[29]&.include?('ブース出展') }
    expect(booth_item.values_at(31, 36)).to eq(%w[50000 50000])
  end

  it 'rounds item amounts to whole yen before calculating invoice tax' do
    plan.update!(price: BigDecimal('300000.5'))

    get billing_conference_path(conference, format: :csv)

    plan_item = CSV.parse(response.body).find { |row| row[1] == '品目' }
    expect(invoice_row.values_at(10, 11, 12)).to eq(%w[300001 30000 330001])
    expect(plan_item.values_at(31, 36)).to eq(%w[300001 300001])
  end

  private def invoice_row
    CSV.parse(response.body).find { |row| row[1] == '請求書' }
  end
end
