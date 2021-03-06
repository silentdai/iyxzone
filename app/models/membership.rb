class Membership < ActiveRecord::Base

  Invitation      = 0
  Request         = 1
  President       = 2
  Veteran         = 3
  Member          = 4

  named_scope :by, lambda {|user_ids| {:conditions => {:user_id => user_ids}}}

  named_scope :authorized, :conditions => {:status => [President, Veteran, Member]}

  belongs_to :user

  belongs_to :character, :class_name => 'GameCharacter'

  belongs_to :guild

	acts_as_resource_feeds :recipients => lambda {|membership| 
    user = membership.user
    guild = membership.guild 
    friends = membership.user.friends.find_all{|f| f.application_setting.recv_guild_feed?}
    [user.profile, guild.game] + friends + (user.is_idol ? user.fans : []) - [guild.president] 
  }

  # user_id, guild_id, character_id 不能被修改
  attr_readonly :user_id, :guild_id, :character_id

  validates_presence_of :user_id, :message => "不能为空", :on => :create

  validates_presence_of :guild_id, :message => "不能为空", :on => :create

  validates_presence_of :character_id, :message => "不能为空", :on => :create

  validates_inclusion_of :status, :in => [Invitation, Request, President, Veteran, Member], :message => "只能是0,1,2,3,4"

  validate_on_create :guild_is_valid

  validate_on_create :character_is_valid

  validate_on_create :user_is_valid

  validate_on_update :status_is_valid

  def to_s
    if is_president?
      "会长"
    elsif is_veteran?
      "长老"
    elsif is_member?
      "会员"
    end
  end

  def is_invitation?
    status == Invitation
  end

  def was_invitation?
    status_was == Invitation
  end

  def is_request?
    status == Request
  end

  def was_request?
    status_was == Request
  end

  def is_president?
    status == President
  end

  def was_president?
    status_was == President
  end

  def is_veteran?
    status == Veteran
  end

  def is_member?
    status == Member
  end

  def is_authorized?
    status == Member or status == Veteran
  end

  def was_authorized?
    status_was == Member or status_was == Veteran
  end  

  attr_accessor :recently_change_role

  attr_accessor :recently_evicted

  attr_accessor :recently_accept_invitation

  attr_accessor :recently_decline_invitation

  attr_accessor :recently_accept_request

  attr_accessor :recently_decline_request

  def change_role status
    if self.status != status
      self.recently_change_role = true
      self.update_attributes(:status => status)
    end
  end

  def evict
    if self.is_authorized?
      self.recently_evicted = true
      self.destroy
    end
  end

  def accept_invitation
    if self.is_invitation?
      self.recently_accept_invitation = true
      self.update_attributes(:status => Member)
    end
  end

  def decline_invitation
    if self.is_invitation?
      self.recently_decline_invitation = true
      self.destroy
    end
  end

  def accept_request
    if self.is_request?
      self.recently_accept_request = true
      self.update_attributes(:status => Member)
    end
  end

  def decline_request
    if self.is_request?
      self.recently_decline_request = true
      self.destroy
    end
  end

protected

  def guild_is_valid
    return if guild_id.blank?
    errors.add(:guild_id, "工会不存在") unless Guild.exists? guild_id
  end

  def character_is_valid
    return if character_id.blank?
    
    if character.blank?
      errors.add(:character_id, "不存在")
    elsif guild and (character.game_id != guild.game_id or character.area_id != guild.game_area_id or character.server_id != guild.game_server_id)
      errors.add(:character_id, "不属于相应服务器")
    end
  end
  
  def user_is_valid
    return if character.blank? or user.blank? or guild.blank?
 
    membership = guild.membership_for user, character
    
    if membership.blank?
      if is_invitation?
        errors.add(:user_id, '不能邀请非好友') if !guild.president.has_friend?(user_id)
      elsif is_request?
      elsif is_authorized? or is_president?
      end
    else
      if membership.is_invitation?
        errors.add(:user_id, '已经被邀请了')
      elsif membership.is_request?
        errors.add(:user_id, '已经发送请求了')
      elsif membership.is_authorized? or membership.is_president?
        errors.add(:user_id, '已经加入了该工会')
      end
		end
  end

  def status_is_valid
    return if status.blank? 
    
    if is_invitation?
      errors.add(:status, '不能从请求变成邀请') if was_request?
      errors.add(:status, '不能从参加变成邀请') if was_authorized? or was_president?
    elsif is_request?
      errors.add(:status, '不能从邀请变成请求') if was_invitation?
      errors.add(:status, '不能从参加变成请求') if was_authorized? or was_president?
    elsif is_president?
      errors.add(:status, '不能变成会长')
    end
  end

end
