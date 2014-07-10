require_dependency 'email/message_builder'

class InviteMailer < ActionMailer::Base
  include Email::BuildEmailHelper

  def send_invite(invite)
    # Find the first topic they were invited to
    first_topic = invite.topics.order(:created_at).first

    # If they were invited to a topic
    if first_topic.present?
      # get invitee name (based on site setting)
      invitee_name = invite.invited_by.username
      if (SiteSetting.enable_names)
        invitee_name = "#{invite.invited_by.name} (#{invite.invited_by.username})"
      end

      # get topic excerpt
      topic_excerpt = ""
      if first_topic.excerpt
        topic_excerpt = first_topic.excerpt.gsub("\n", " ")
      end

      build_email(invite.email,
                  template: 'invite_mailer',
                  invitee_name: invitee_name,
                  site_domain_name: Discourse.current_hostname,
                  invite_link: "#{Discourse.base_url}/invites/#{invite.invite_key}",
                  topic_title: first_topic.try(:title),
                  topic_excerpt: topic_excerpt,
                  site_description: SiteSetting.site_description,
                  site_title: SiteSetting.title)
    else
      build_email(invite.email,
                  template: 'invite_forum_mailer',
                  invitee_name: invite.invited_by.username,
                  invite_link: "#{Discourse.base_url}/invites/#{invite.invite_key}",
                  site_description: SiteSetting.site_description,
                  site_title: SiteSetting.title)
    end

  end

end
