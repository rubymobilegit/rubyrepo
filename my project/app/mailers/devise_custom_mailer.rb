class DeviseCustomMailer < Devise::Mailer
  if self.included_modules.include?(AbstractController::Callbacks)
    raise "You've already included AbstractController::Callbacks, remove this line."
  else
    include AbstractController::Callbacks
  end

  helper 'application'
  helper 'admins/email_contents'


  def confirmation_instructions(record)
    if record.class == User
      @email_content = EmailContent.find_by_name("confirmation_instructions_user")
      for_vendor = false
    elsif record.class == Vendor
      @email_content = EmailContent.find_by_name("confirmation_instructions_vendor")
      for_vendor = true
    end

    [
        "emails/#{for_vendor ? 'vendor' : 'user'}_logo.png"
    ].each do |file|
      attachments.inline[file] = File.read("#{Rails.root.to_s}/app/assets/images/#{file}")
    end

    super
  end

  def reset_password_instructions(record)
    if record.class == User
      @email_content = EmailContent.find_by_name("reset_password_instructions_user")
      for_vendor = false
    elsif record.class == Vendor
      @email_content = EmailContent.find_by_name("reset_password_instructions_vendor")
      for_vendor = true
    end

    [
        "emails/#{for_vendor ? 'vendor' : 'user'}_logo.png"
    ].each do |file|
      attachments.inline[file] = File.read("#{Rails.root.to_s}/app/assets/images/#{file}")
    end

    super
  end

  def unlock_instructions(record)
    super
  end

end
