# frozen_string_literal: true

module Admin
  class InvoicesController < Admin::ApplicationController
    TAX_RATE = BigDecimal('0.1')

    before_action :set_conference

    # https://biz.moneyforward.com/support/invoice/faq/invoice/invoice002.html
    def index
      @invoice_rows = []
      @invoice_rows << %w[csv_type(変更不可) 行形式 取引先名称 件名 請求日 お支払期限 請求書番号 売上計上日 メモ タグ 小計 消費税 合計金額 取引先敬称 取引先郵便番号 取引先都道府県 取引先住所1 取引先住所2 取引先部署 取引先担当者役職 取引先担当者氏名 自社担当者氏名 備考 振込先 入金ステータス メール送信ステータス 郵送ステータス ダウンロードステータス 納品日 品名 品目コード 単価 数量 単位 納品書番号 詳細 金額 品目消費税率]

      billing_day = params[:billing_day] ? Date.parse(params[:billing_day]) : Time.zone.today
      sponsorships = @conference.sponsorships.active.includes_contacts.includes(:plan).order(:plan_id, :id)

      sponsorships.each.with_index(1) do |sponsor, i|
        plan_amount = amount_in_yen(sponsor.plan.price)
        booth_amount = sponsor.booth_assigned ? amount_in_yen(sponsor.plan.price_booth) : 0
        subtotal = plan_amount + booth_amount
        tax = (subtotal * TAX_RATE).floor

        @invoice_rows << [40101, '請求書', sponsor.billing_contact.organization, "#{@conference.name} 協賛のご請求", billing_day.strftime('%Y/%m/%d'), (billing_day + 1.month).end_of_month.strftime('%Y/%m/%d'), "#{billing_day.strftime("%Y%m%d")}-#{format("%03<number>d", number: i)}", billing_day.strftime('%Y/%m/%d'), sponsor.plan.name, nil, subtotal, tax, subtotal + tax, '御中', nil, nil, nil, nil, sponsor.billing_contact.unit, '', sponsor.billing_contact.name, nil, '払込手数料は、御社のご負担とさせていただきます。'] + Array.new(12)
        @invoice_rows << [40101, '品目'] + Array.new(27) + ["#{@conference.name} 協賛費用 (#{sponsor.plan.name})", nil, plan_amount, 1, nil, nil, nil, plan_amount, '10%']

        if sponsor.booth_assigned
          @invoice_rows << [40101, '品目'] + Array.new(27) + ["#{@conference.name} 協賛費用 (ブース出展)", nil, booth_amount, 1, nil, nil, nil, booth_amount, '10%']
        end
      end

      respond_to do |format|
        format.html
        format.csv do
          invoice_csv = CSV.generate(row_sep: "\r\n") do |csv|
            @invoice_rows.each { |row| csv << row }
          end

          send_data(invoice_csv, filename: "#{@conference.name.underscore.gsub(" ", "_")}_invoices.csv")
        end
      end
    end

    private def set_conference
      @conference = Conference.find_by!(slug: params[:conference_slug])
      check_staff_conference_authorization!(@conference)
    end

    private def amount_in_yen(amount)
      amount.to_d.round(0, BigDecimal::ROUND_HALF_UP).to_i
    end
  end
end
