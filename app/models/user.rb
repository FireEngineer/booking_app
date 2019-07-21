class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :calendars
  serialize :google_api_token, Hash

  # after_create :create_

  # private
  #   def create_config
  #     Config.create(user_id: self.id)
  #   end
end
