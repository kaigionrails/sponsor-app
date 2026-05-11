# frozen_string_literal: true

class SponsorshipAssetFile < ApplicationRecord
  PREFIX = ENV['S3_FILES_PREFIX']

  include AssetFileUploadable

  ALLOWED_CONTENT_TYPES = %w[
    image/jpeg
    image/png
  ].freeze

  belongs_to :sponsorship, optional: true

  validate :content_type_allowed

  scope :available_for_user, ->(id, session_asset_file_ids: [], available_sponsorship_ids: []) do
    where(id:)
      .merge(
        SponsorshipAssetFile.where(sponsorship_id: available_sponsorship_ids)
          .or(SponsorshipAssetFile.where(sponsorship_id: nil, id: session_asset_file_ids || [])),
      )
  end

  validate :validate_ownership_not_changed

  def self.prepare(conference:)
    record = new
    record.prefix = "c-#{conference.id}/"
    record
  end

  def copy_to!(conference)
    dst = self.class.prepare(conference:)
    dst.extension = extension
    dst.save!
    s3_client.copy_object(
      bucket: self.class.asset_file_bucket,
      copy_source: "#{self.class.asset_file_bucket}/#{object_key}",
      key: dst.object_key,
    )
    dst.update_object_header
    dst
  end

  def object_key
    raise unless self.persisted?
    "#{PREFIX}#{prefix}#{handle}--#{id}.#{extension}"
  end

  def filename
    "S#{id}_#{sponsorship&.slug}.#{extension}"
  end

  private def content_type_allowed
    return if content_type.blank?
    return if content_type.in?(ALLOWED_CONTENT_TYPES)

    errors.add(:content_type, "is not an allowed file type")
  end

  private def validate_ownership_not_changed
    if sponsorship_id_changed? && !sponsorship_id_was.nil?
      errors.add :sponsorship_id, "cannot be changed"
    end
  end
end
