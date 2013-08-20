class User < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy

  # Validations
  validates_presence_of :organization_id, :username, :password
  validates_associated :organization

  # Callbacks
  after_create :generate_api_key

  def super_admin?
    role == 'super_admin'
  end

  def admin?
    role == 'admin' || role == 'super_admin'
  end

  protected

  def generate_api_key
    self.update_attributes api_key: "user_#{id}"
  end
end
