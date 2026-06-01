class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :rememberable,
         :omniauthable, omniauth_providers: [ :line ]

  has_many :reminders, dependent: :destroy
  has_many :recommend_lists, dependent: :destroy

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by!(provider: auth.provider, uid: auth.uid) do |user|
      user.name  = auth.info.name
      user.email = User.dummy_email(auth)
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def self.dummy_email(auth)
    "#{auth.uid}@line.example.com"
  end
end
