class Group < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy
  has_and_belongs_to_many :consumers
  has_and_belongs_to_many :config_items

  # Validations
  validates_presence_of :organization_id, :name
  validates_associated :organization
end
