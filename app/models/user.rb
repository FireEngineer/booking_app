class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :tasks
  has_one :config
  serialize :google_api_token, Hash

  after_create :create_config

  private
    def create_config
      Config.create(user_id: self.id)
    end
end
