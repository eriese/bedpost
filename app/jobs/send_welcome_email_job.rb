class SendWelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_profile)
    GibbonMailer.send_welcome(user_profile)
  end
end
