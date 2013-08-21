class ConfigItem < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy

  # Validations
  validates_presence_of :organization_id, :name
  validates_associated :organization
end
