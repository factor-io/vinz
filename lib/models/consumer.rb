class Consumer < ActiveRecord::Base
  # Associations
  belongs_to :organization
  has_one :api_key, as: :key_owner, dependent: :destroy

  # Validations
  validates_presence_of :organization_id, :name
  validates_associated :organization

  # Callbacks
  before_create :generate_api_key

  # Override as_json
  def as_json(options = {})
    hash = serializable_hash(options)
    hash[:api_key] = api_key.key
    hash = {consumer: hash} if options[:root] == true
    hash
  end

  protected

  def generate_api_key
    self.api_key = ApiKey.create
  end
end
