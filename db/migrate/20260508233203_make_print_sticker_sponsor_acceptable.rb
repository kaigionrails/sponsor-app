# frozen_string_literal: true

class MakePrintStickerSponsorAcceptable < ActiveRecord::Migration[8.1]
  def change
    add_column :conferences, :print_sticker_sponsor_capacity, :integer, default: 0, null: false
    add_column :sponsorships, :print_sticker_sponsor_requested, :boolean, default: false, null: false
    add_column :sponsorships, :print_sticker_sponsor_assigned, :boolean, default: false, null: false
    add_column :form_descriptions, :print_sticker_sponsor_help, :text
    add_column :form_descriptions, :print_sticker_sponsor_help_html, :text
    add_column :plans, :print_sticker_sponsor_eligible, :boolean, default: false, null: false
  end
end
