class ConfigItem < ActiveRecord::Base
  # Associations
  has_and_belongs_to_many :groups

  # Validations
  validates :name, presence: true
end
