class ConfigItem < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy
  has_and_belongs_to_many :groups

  # Validations
  validates :name, presence: true
end
