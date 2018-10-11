class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_profile)
    GibbonMailer.sendWelcome(user_profile)
  end
end
