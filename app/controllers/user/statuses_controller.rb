class User::StatusesController < UserBaseController

  layout 'app'

  def index
    if !params[:status_id].blank? and !params[:reply_to].blank?
      @reply_to = User.find(params[:reply_to])
      @status = Status.find(:first, :conditions => {:id => params[:status_id], :verified => [0,1]})
      params[:page] = @user.statuses.index(@status) / 10 + 1 if @status
    end

    @statuses = @user.statuses.paginate :page => params[:page], :per_page => 10, :include => [{:first_comment => [:commentable, :poster]}, {:last_comment => [:commentable, :poster]}, {:poster => :profile}]
  end

  def friends
    @statuses = current_user.friend_statuses.paginate :page => params[:page], :per_page => 10
  end

  def create
    @status = current_user.statuses.build((params[:status] || {}).merge({:poster_id => current_user.id}))
    unless @status.save
			render :update do |page|
				page << "error(保存时发生错误)"
			end
		end
  end

  def destroy
    if @status.destroy
      render :update do |page|
        page << "facebox.close();$('status_#{@status.id}').remove();"
      end
    else
      render :update do |page|
        page << "error('发生错误');"
      end
    end
  end

protected

  def setup
    if ["index"].include? params[:action]
      @user = User.find(params[:uid])
      require_friend_or_owner @user      
    elsif ["destroy"].include? params[:action]
      @status = Status.find(params[:id])
      require_owner @status.poster
    end
  end

end
