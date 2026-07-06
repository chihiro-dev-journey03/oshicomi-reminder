class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!

  def line
    auth = request.env["omniauth.auth"]
    @user = User.find_or_create_from_omniauth(auth)

    if @user.persisted?
      sign_in @user, event: :authentication
      set_flash_message(:notice, :success, kind: "LINE") if is_navigational_format?
      if @user.previously_new_record?
        redirect_to edit_profile_path, notice: "メールアドレスを登録してメール通知を受け取りましょう。"
      else
        redirect_to after_sign_in_path_for(@user)
      end
    else
      session["devise.line_data"] = auth.except(:extra)
      redirect_to root_url, alert: "ログインに失敗しました。"
    end
  end

  def failure
    redirect_to root_url, alert: "LINEログインがキャンセルされました。"
  end
end
