class User < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy
  has_one :api_key, as: :key_owner

  # Validations
  validates_presence_of :organization_id, :username, :password
  validates_associated :organization

  # Callbacks
  before_create :generate_api_key

  def super_admin?
    role == 'super_admin'
  end

  def admin?
    role == 'admin' || role == 'super_admin'
  end

  protected

  def generate_api_key
    self.api_key = ApiKey.create
  end

end
