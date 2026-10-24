# frozen_string_literal: true

class SponsorshipInvoice
  TAX_RATE = BigDecimal('0.1')

  attr_reader :sponsorship

  def initialize(sponsorship:)
    @sponsorship = sponsorship
  end

  def plan_amount
    amount_in_yen(sponsorship.plan.price)
  end

  def booth_amount
    return 0 unless sponsorship.booth_assigned

    amount_in_yen(sponsorship.plan.price_booth)
  end

  def approved_expense_amount
    report = sponsorship.expense_report
    return 0 unless sponsorship.customization && report&.status == 'approved'

    amount_in_yen(report.total_amount || 0)
  end

  def subtotal
    plan_amount + booth_amount - approved_expense_amount
  end

  def tax
    (subtotal * TAX_RATE).floor
  end

  def total
    subtotal + tax
  end

  def exportable?
    subtotal >= 0
  end

  private def amount_in_yen(amount)
    amount.to_d.round(0, BigDecimal::ROUND_HALF_UP).to_i
  end
end
