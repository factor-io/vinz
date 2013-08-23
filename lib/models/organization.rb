class Organization < ActiveRecord::Base
  # Associations
  has_many :users, dependent: :destroy
  has_many :consumers, dependent: :destroy
  has_many :config_items, dependent: :destroy

  # Validations
  validates_presence_of :name
end
