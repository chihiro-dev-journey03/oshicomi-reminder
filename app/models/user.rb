class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :rememberable,
         :omniauthable, omniauth_providers: [ :line, :google_oauth2 ]

  has_many :reminders, dependent: :destroy
  has_many :recommend_lists, dependent: :destroy

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: "は正しい形式で入力してください" },
                    allow_blank: true
  validates :email, uniqueness: { case_sensitive: false, message: "はすでに使用されています" }

  def email_registered?
    email.present? && !email.end_with?("@line.example.com")
  end

  def self.find_or_create_from_omniauth(auth)
    find_or_create_by!(provider: auth.provider, uid: auth.uid) do |user|
      user.name  = auth.info.name
      user.email = User.dummy_email(auth)
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def self.find_or_create_from_google_omniauth(auth)
    # 既存のGoogle連携ユーザーを検索
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # メールアドレスで既存ユーザーを検索してGoogle連携を紐付け
    user = find_by(email: auth.info.email)
    if user
      user.update!(provider: auth.provider, uid: auth.uid)
      return user
    end

    # 新規ユーザーを作成
    create!(
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20]
    )
  end

  def self.dummy_email(auth)
    "#{auth.uid}@line.example.com"
  end
end
