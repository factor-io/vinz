class Consumer < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :config_items

  # Validations
  validates :name, presence: true

  # Callbacks
  after_create :generate_token

  protected

  def generate_token
    self.update_attributes token: "consumer_#{id}"
  end
end
