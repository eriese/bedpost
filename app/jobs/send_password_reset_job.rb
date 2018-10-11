class SendPasswordResetJob < ApplicationJob
  queue_as :default

  def perform(user_profile)
    GibbonMailer.send_reset(user_profile)
  end
end
