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

  private def invoice_row
    CSV.parse(response.body).find { |row| row[1] == '請求書' }
  end
end
