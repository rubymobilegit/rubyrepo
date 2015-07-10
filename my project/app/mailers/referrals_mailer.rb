class ReferralsMailer < ActionMailer::Base
  default :from => "\"MuddleMe Support\" <noreply@#{HOSTNAME_CONFIG['hostname']}>"
  helper 'application'
  helper 'admins/email_contents'

  def invite user, recipients
    @user = user

    @email_content = EmailContent.find_by_name("referrals_invite")

    [
      'emails/user_logo.png',
    ].each do |file|
      attachments.inline[file] = File.read("#{Rails.root.to_s}/app/assets/images/#{file}")
    end

    mail :to => recipients, 
        :subject=> "Check out this new website: muddleme.com. And help #{@user.first_name} #{@user.last_name} increase his worth!"
  end
  
  def send_passive_payment_alert(user)
    @user = user
    mail :to => "sandeep@rubyeffect.com", :subject => "Passive payment notification from Muddleme"
  end
  
end
