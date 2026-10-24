# frozen_string_literal: true

class InvoiceSponsorshipFilter
  CUSTOMIZATION_VALUES = %w[all with without].freeze

  attr_reader :locales, :plans, :selected_locales, :selected_plan_ids, :customization_filter

  def initialize(conference:, filters:, locales:, plan_ids:, customization_filter:)
    @base_scope = conference.sponsorships.active
    @locales = base_scope.reorder(nil).distinct.order(:locale).pluck(:locale)
    @plans = conference.plans.order(:rank, :id).to_a
    @selected_locales = selected_values(filters, locales, @locales)
    @selected_plan_ids = selected_values(filters, plan_ids, plans.map { |plan| plan.id.to_s })
    @customization_filter = CUSTOMIZATION_VALUES.include?(customization_filter) ? customization_filter : 'all'
  end

  def sponsorships
    @sponsorships ||= filter_by_customization(
      base_scope.where(locale: selected_locales, plan_id: selected_plan_ids),
    ).includes_contacts.includes(:plan, :expense_report).order(:plan_id, :id)
  end

  private attr_reader :base_scope

  private def selected_values(filters, values, default_values)
    return default_values if filters.blank?

    Array(values) & default_values
  end

  private def filter_by_customization(scope)
    case customization_filter
    when 'with' then scope.where(customization: true)
    when 'without' then scope.where(customization: false)
    else scope
    end
  end
end
