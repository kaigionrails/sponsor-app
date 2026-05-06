# frozen_string_literal: true

class DropCommercialMessageMovieAcceptableColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :conferences, :commercial_message_movie_capacity, :integer, default: 0, null: false
    remove_column :sponsorships, :commercial_message_movie_requested, :boolean, default: false, null: false
    remove_column :sponsorships, :commercial_message_movie_assigned, :boolean, default: false, null: false
    remove_column :form_descriptions, :commercial_message_movie_help, :text
    remove_column :form_descriptions, :commercial_message_movie_help_html, :text
    remove_column :plans, :commercial_message_movie_eligible, :boolean, default: false, null: false
  end
end
