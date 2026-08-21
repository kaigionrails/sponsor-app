# frozen_string_literal: true

module Admin
  class InvoicesController < Admin::ApplicationController
    before_action :set_conference

    # https://biz.moneyforward.com/support/invoice/faq/invoice/invoice002.html
    def index
      billing_day = params[:billing_day].present? ? Date.parse(params[:billing_day]) : Time.zone.today
      sponsorships = @conference.sponsorships.active.includes_contacts.includes(:plan).order(:plan_id, :id)
      invoice_csv = MoneyForwardInvoiceCsv.new(conference: @conference, sponsorships:, billing_day:)

      respond_to do |format|
        format.html { @invoice_rows = invoice_csv.rows }
        format.csv do
          send_data(invoice_csv.to_csv, filename: "#{@conference.name.underscore.gsub(" ", "_")}_invoices.csv")
        end
      end
    end

    private def set_conference
      @conference = Conference.find_by!(slug: params[:conference_slug])
      check_staff_conference_authorization!(@conference)
    end
  end
end
