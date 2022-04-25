require "google/cloud/storage"

class SponsorshipAssetFile < ApplicationRecord
  REGION = ENV['S3_FILES_REGION']
  BUCKET = ENV['S3_FILES_BUCKET']
  PREFIX = ENV['S3_FILES_PREFIX']

  ROLE = ENV['S3_FILES_ROLE']

  belongs_to :sponsorship, optional: true
  validates :handle, presence: true

  validate :validate_ownership_not_changed

  before_validation do
    self.handle ||= SecureRandom.urlsafe_base64(32)
  end

  def copy_to!(conference)
    dst = self.class.create!(prefix: "c-#{conference.id}/", extension: self.extension)
    client = Google::Cloud::Storage.new
    file = client.bucket(BUCKET).file(object_key, skip_lookup: true)
    file.copy(dst.object_key)
    dst
  end

  def object_key
    raise unless self.persisted?
    "#{PREFIX}#{prefix}#{handle}--#{id}.#{extension}"
  end

  def make_session
    Session.new(self).as_json
  end

  def filename
    "S#{id}_#{sponsorship&.slug}.#{extension}"
  end

  def download_url
    client = Google::Cloud::Storage.new
    client.bucket(BUCKET).file(object_key, skip_lookup: true).signed_url(method: "GET", expires: 300, version: :v4)
  end

  private def validate_ownership_not_changed
    if sponsorship_id_changed? && !sponsorship_id_was.nil?
      errors.add :sponsorship_id, "cannot be changed"
    end
  end

  class Session
    def initialize(file)
      @file = file
    end

    attr_reader :file

    def signed_url
      client ||= Google::Cloud::Storage.new
      client.bucket(BUCKET).signed_url(file.object_key, version: :v4, expires: 3600, method: 'PUT')
    end

    def as_json
      {
        id: file.id.to_s,
        signed_url: signed_url
      }
    end
  end
end
