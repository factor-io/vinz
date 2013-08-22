class ConfigItem < ActiveRecord::Base
  # Associations
  belongs_to :organization, dependent: :destroy

  # Encrypted fields
  crypt_keeper :value, encryptor: :aes, key: ENV['ENCRYPTION_KEY']

  # Validations
  validates_presence_of :organization_id, :name
  validates_associated :organization

end
