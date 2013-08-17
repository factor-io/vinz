class Group < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy
  has_and_belongs_to_many :consumers
  has_and_belongs_to_many :config_items

  # Validations
  validates :name, presence: true
end
