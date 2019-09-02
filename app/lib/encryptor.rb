module Encryptor
  CIPHER = "aes-256-cbc"
  def encrypt(password)
    secure = Rails.application.credentials.encrypt_secure_key
    crypt = ActiveSupport::MessageEncryptor.new(secure, CIPHER)
    crypt.encrypt_and_sign(password)
  end

  def decrypt(password)
    secure = Rails.application.credentials.encrypt_secure_key
    crypt = ActiveSupport::MessageEncryptor.new(secure, CIPHER)
    crypt.decrypt_and_verify(password)
  end
end