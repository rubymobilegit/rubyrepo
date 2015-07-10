#ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => "gmail.com",
    :user_name            => "kevin.m.brothers@gmail.com",
    :password             => "brothers4simon",
    :authentication       => 'plain',
    :enable_starttls_auto => true
}