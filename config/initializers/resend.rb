if Rails.env.production?
  Resend.api_key = ENV.fetch("RESEND_API_KEY")
elsif ENV["RESEND_API_KEY"].present?
  Resend.api_key = ENV["RESEND_API_KEY"]
end
