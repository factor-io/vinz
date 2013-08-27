class User < ActiveRecord::Base
  # Associations
  belongs_to :organization
  has_one :api_key, as: :key_owner, dependent: :destroy

  # Encrypted fields
  crypt_keeper :password, encryptor: :aes, key: ENV['ENCRYPTION_KEY']

  # Named scopes
  scope :admins, -> { where(role: 'admin') }

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

  def as_json(options = {})
    hash = serializable_hash(options)
    hash[:api_key] = api_key.key
    hash = {user: hash} if options[:root] == true
    hash
  end

  protected

  def generate_api_key
    self.api_key = ApiKey.create
  end

end
