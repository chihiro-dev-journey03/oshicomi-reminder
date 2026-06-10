module Internal
  class RemindersController < ActionController::Base
    skip_before_action :verify_authenticity_token
    before_action :authenticate_cron_secret!

    def send_due
      result = Reminders::SendDueService.new.call
      render json: result
    end

    private

    def authenticate_cron_secret!
      expected = ENV["CRON_SECRET"]
      provided = request.headers["Authorization"]&.split(" ", 2)&.last

      return head :unauthorized if expected.blank? || provided.blank?
      return head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(provided, expected)
    end
  end
end
