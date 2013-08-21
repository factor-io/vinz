require 'securerandom'

class ApiKey < ActiveRecord::Base

  # Associations
  belongs_to :key_owner, polymorphic: true

  # Callbacks
  before_create :generate_key
  
  private
  
  def generate_key
    enc = Encoding.find('UTF-8')
    begin
      # Encode is to compensate for issue with securerandom setting
      # a binary encoding
      self.key = SecureRandom.hex.encode(enc)
    end while self.class.exists?(key: key)
  end

end
