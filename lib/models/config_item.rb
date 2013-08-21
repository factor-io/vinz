class ConfigItem < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy
  has_and_belongs_to_many :groups
  has_many :consumers, through: :groups

  # Validations
  validates_presence_of :organization_id, :name
  validates_associated :organization, :groups
end
