# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin Broadcasts", type: :request do
  let(:conference) { FactoryBot.create(:conference) }
  let(:staff) { FactoryBot.create(:staff) }
  let(:session_token) { FactoryBot.create(:session_token, staff:) }

  before do
    get claim_user_session_path(session_token.handle)
  end

  describe "PATCH update" do
    let(:broadcast) { FactoryBot.create(:broadcast, conference:, status:) }
    let(:new_params) { {campaign: 'New campaign', description: 'New description', title: 'New title', body: 'New body'} }

    context "when the broadcast is not sent" do
      let(:status) { :ready }

      it "updates all attributes" do
        patch conference_broadcast_path(conference, broadcast), params: {broadcast: new_params}
        expect(response).to redirect_to(conference_broadcast_path(conference, broadcast))
        expect(broadcast.reload).to have_attributes(new_params)
      end
    end

    context "when the broadcast is sent" do
      let(:status) { :sent }

      it "rejects changes to title and body" do
        expect {
          patch conference_broadcast_path(conference, broadcast), params: {broadcast: new_params}
        }.not_to change { broadcast.reload.attributes }
      end

      it "updates campaign and description" do
        patch conference_broadcast_path(conference, broadcast), params: {broadcast: new_params.slice(:campaign, :description)}
        expect(response).to redirect_to(conference_broadcast_path(conference, broadcast))
        expect(broadcast.reload).to have_attributes(campaign: 'New campaign', description: 'New description')
      end
    end
  end
end
