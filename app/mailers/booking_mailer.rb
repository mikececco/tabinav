class UserMailer < ApplicationMailer
  def bookingemail
    @booking = params[:booking] # Instance variable => available in view
    mail(to: @user.email, subject: 'Thanks for your booking')
    # This will render a view in `app/views/user_mailer`!
  end
end
