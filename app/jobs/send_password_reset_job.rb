class SendPasswordResetJob < ApplicationJob
  queue_as :default

  def perform(user_profile)
    GibbonMailer.sendReset(user_profile)
  end
end
