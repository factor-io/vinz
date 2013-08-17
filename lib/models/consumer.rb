class Consumer < ActiveRecord::Base
  # Associations
  belongs_to :organization
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :config_items

  # Validations
  validates :name, presence: true

  # Callbacks
  before_create :generate_token

  protected

  def generate_token
    self.token = "consumer_#{id}"
  end
end
