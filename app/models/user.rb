class User < ApplicationRecord
  include Encryptor
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :calendars
  serialize :google_api_token, Hash

  before_update :encrypt_collumns

  def encrypt_collumns
    self.client_id = encrypt(self.client_id)
    self.client_secret = encrypt(self.client_secret)
  end
end
