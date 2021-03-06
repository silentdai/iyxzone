#
# 头像新鲜事和照片新鲜事不同
# 头像一次只能上传一张，所以用after_create这个callback就够了
# 一般的照片一次上传多张，很难用after_create解决
#
class AvatarObserver < ActiveRecord::Observer

  def before_create avatar
    return unless avatar.thumbnail.blank?

    # verify
    avatar.needs_verify # 总是需要验证的

    # inherit some attributes from album
    album = avatar.album
    avatar.poster_id = album.poster_id
    avatar.privilege = album.privilege
    avatar.game_id = nil
  end

	def after_create avatar
    return unless avatar.thumbnail.blank?

		# set cover
		avatar.album.update_attributes(:cover_id => avatar.id)
    avatar.album.update_attributes(:uploaded_at => Time.now)
    avatar.poster.update_attributes(:avatar_id => avatar.id) 

    # increment counter
    avatar.album.raw_increment :photos_count

    # issue avatar feeds if necessary 
    if avatar.poster.application_setting.emit_photo_feed?
		  avatar.deliver_feeds
    end
	end

  def before_update avatar
    return unless avatar.thumbnail.blank?

    avatar.auto_verify 
  end
 
  def after_update avatar
    return unless avatar.thumbnail.blank?

    # verify
    if avatar.recently_recovered?
      avatar.album.raw_increment :photos_count
      # 就不恢复了，因为头像可能已经是别的了
    elsif avatar.recently_rejected?
      avatar.album.raw_decrement :photos_count
      avatar.destroy_feeds
    end

    # change cover if necessary
    if avatar.cover
      if avatar.album.cover_id != avatar.id
        avatar.album.update_attribute('cover_id', avatar.id)
        avatar.poster.update_attribute('avatar_id', avatar.id)
      end
    else
      # 不存在这种情况, 必须有一个头像
    end
  end 
 
  def after_destroy avatar
    return unless avatar.thumbnail.blank?

    # decrement counter
    if !avatar.rejected?
      avatar.album.raw_decrement :photos_count
    end
  end   

end
