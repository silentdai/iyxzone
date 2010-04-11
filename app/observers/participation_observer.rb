require 'app/mailer/event_mailer'

class ParticipationObserver < ActiveRecord::Observer

	def field status
		if status == Participation::Confirmed
			"confirmed_count"
		elsif status == Participation::Maybe
			"maybe_count"
		end
	end

	def after_create participation
		event = participation.event
		participant = participation.participant
		
    if participation.is_invitation?
			participant.raw_increment :event_invitations_count
			event.raw_increment :invitations_count	
			EventMailer.deliver_invitation event, participation if participant.mail_setting.invite_me_to_event == 1
		elsif participation.is_request?
			event.poster.raw_increment :event_requests_count
			event.raw_increment :requests_count
			EventMailer.deliver_request event, participation if event.poster.mail_setting.request_to_attend_my_event == 1
    elsif participation.is_confirmed?
      event.raw_increment :confirmed_count
		end	
	end


	def after_update participation
    # update user's counter and event's counter
		event = participation.event
		participant = participation.participant
    character = participation.character
 
    if participation.was_invitation? and participation.is_authorized?
			event.raw_decrement :invitations_count
      event.raw_increment field(participation.status)
      participant.raw_decrement :event_invitations_count
      if participation.recently_accept_invitation
			  event.poster.notifications.create(
          :category => Notification::Participation,
          :data => "#{profile_link participant}接受了你的邀请: 同意让游戏角色 #{character.name} 加入活动#{event_link event}")
      end
		elsif participation.was_request? and participation.is_authorized?
			event.raw_decrement :requests_count
      event.raw_increment field(participation.status)
      event.poster.raw_decrement :event_requests_count
      if participation.recently_accept_request
			  participant.notifications.create(
          :category => Notification::Participation, 
          :data => "#{profile_link event.poster} 同意了你让游戏角色 #{character.name} 加入活动 #{event_link event} 的请求")
      end
		elsif participation.was_authorized? and participation.is_authorized?
			event.raw_decrement field(participation.status_was)
      event.raw_increment field(participation.status)
      if eparticipation.recently_change_status
        event.poster.notifications.create(
          :category => Notification::EventStatus,
          :data => "#{profile_link participant} 的游戏角色 #{character.name} 改变了在活动 #{event_link event} 的状态：现在#{participation.to_s}")
      end
		end

    # issue feeds if necessary
    return if participant.application_setting.emit_event_feed == 0
    
    if participation.recently_accept_invitation or participation.recently_accept_request 
      recipients = [participant.profile, character.game]
      if event.is_guild_event?
        recipients.concat [event.guild]
      end
      recipients.concat participant.friends.find_all{|f| f.application_setting.recv_event_feed == 1}
      participation.deliver_feeds :recipients => (recipients - [event.poster])
    end
	end
	
  def after_destroy participation
		event = participation.event
		participant = participation.participant
   
    if participation.is_invitation?
			# invitation is declined
			participant.raw_decrement :event_invitations_count
      event.raw_decrement :invitations_count
      if participation.recently_decline_invitation
        event.poster.notifications.create(
          :category => Notification::Participation,
          :data => "#{profile_link participant} 拒绝让游戏角色 #{participation.character.name} 加入你的活动 #{event_link event}")
      end
		elsif participation.is_request?
			# request is declined
      event.poster.raw_decrement :event_requests_count
      event.raw_decrement :requests_count
      if participation.recently_decline_request
			  participant.notifications.create(
          :category => Notification::Participation,
          :data => "#{profile_link event.poster}拒绝了让你的游戏角色 #{participation.character.name} 加入活动#{event_link event}的请求")
      end
    elsif participation.is_authorized?
      # paricipant is evicted
      event.raw_decrement field(participation.status)
      if participation.recently_evicted
        participant.notifications.create(
          :category => Notification::Participation,
          :data => "你的游戏角色 #{participation.character.name} 被剔除出了活动 #{event_link event}")
      end
    end
	end

end
