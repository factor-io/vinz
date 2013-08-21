class Organization < ActiveRecord::Base
  # Associations
  has_many :users
  has_many :consumers
  has_many :config_items

  # Validations
  validates_presence_of :name
end
