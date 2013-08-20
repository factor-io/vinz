class Consumer < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy
  has_and_belongs_to_many :groups

  # Validations
  validates_presence_of :organization_id, :name
  validates_associated :organization, :groups

  # Callbacks
  after_create :generate_token

  protected

  def generate_token
    self.update_attributes token: "consumer_#{id}"
  end
end
