class MakeCommercialMessageMovieAcceptable < ActiveRecord::Migration[6.1]
  def change
    add_column :conferences, :commercial_message_movie_capacity, :integer, default: 0, null: false
    add_column :sponsorships, :commercial_message_movie_requested, :boolean, default: false, null: false
    add_column :sponsorships, :commercial_message_movie_assigned, :boolean, default: false, null: false
    add_column :form_descriptions, :commercial_message_movie_help, :text
    add_column :form_descriptions, :commercial_message_movie_help_html, :text
    add_column :plans, :commercial_message_movie_eligible, :boolean, default: false, null: false
  end
end
