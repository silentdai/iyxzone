class User::EventsController < UserBaseController

  layout 'app'

  PER_PAGE = 10

  PREFETCH = [:guild, {:poster => :profile}, {:game_server => [:game, :area]}, {:album => :cover}]

  def index
    @events = @user.events.nonblocked.paginate :page => params[:page], :per_page => PER_PAGE, :include => PREFETCH
  end

	def hot
    @events = Event.hot.nonblocked.match(user_game_conds).paginate :page => params[:page], :per_page => PER_PAGE, :include => PREFETCH
  end

  def recent
    @events = Event.recent.nonblocked.match(user_game_conds).paginate :page => params[:page], :per_page => PER_PAGE, :include => PREFETCH
	end

  def upcoming
    @events = @user.upcoming_events.nonblocked.paginate :page => params[:page], :per_page => PER_PAGE, :include => PREFETCH
  end

  def participated
    @events = @user.participated_events.nonblocked.paginate :page => params[:page], :per_page => PER_PAGE, :include => PREFETCH
  end

  def friends
    @event_ids = Participation.authorized.by(current_user.friend_ids).map(&:event_id).uniq
    @events = Event.nonblocked.match(:id => @event_ids).paginate :page => params[:page], :per_page => PER_PAGE, :include => PREFETCH
  end

  def show
    @maybe_characters = @event.maybe_characters.limit(6).prefetch([{:user => :profile}])
    @invite_characters = @event.invite_characters.limit(6).prefetch([{:user => :profile}])
    @request_characters = @event.request_characters.limit(6).prefetch([{:user => :profile}])
    @confirmed_characters = @event.confirmed_characters.limit(6).prefetch([{:user => :profile}])
    @user = @event.poster
    @album = @event.album
    @photos = @album.latest_photos.nonblocked
		@reply_to = User.find(params[:reply_to]) unless params[:reply_to].blank?
    @participations = @event.participations.prefetch([:character]).by(current_user.id)
    @messages = @event.comments.nonblocked.paginate :page => params[:page], :per_page => PER_PAGE, :include => [:commentable, {:poster => :profile}]
    @remote = {:update => 'comments', :url => {:controller => 'user/wall_messages', :action => 'index', :wall_id => @event.id, :wall_type => 'event'}}
		render :action => 'show', :layout => 'app2'
  end

  def new
    @event = Event.new
    @characters = @guild.president_and_veteran_characters.by(current_user.id) if !@guild.blank?
  end

  def create
    @event = current_user.events.build(params[:event] || {})

    if @event.save
      redirect_to new_event_invitation_url(@event)
    else
      # guild_id可能是nil
      render :action => 'new', :guild_id => @event.guild_id
    end
  end

  def edit
    render :action => 'edit'
  end

  def update
    if @event.update_attributes(params[:event] || {})
      redirect_to event_url(@event)
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @event.destroy
      render :update do |page|
        page.redirect_to events_url(:uid => current_user.id)
      end
    else
      render_js_error
    end
  end  

  #
  # 这个方法在目前的页面用不上
  #
  def search
    case params[:type].to_i
    when 0
      @events = current_user.upcoming_events.nonblocked.search(params[:key]).paginate :page => params[:page], :per_page => PER_PAGE
    when 1
      @events = Event.hot.nonblocked.search(params[:key]).paginate :page => params[:page], :per_page => PER_PAGE
    when 2
      @events = Event.recent.nonblocked.search(params[:key]).paginate :page => params[:page], :per_page => PER_PAGE
    when 3
      @events = current_user.past_events.nonblocked.search(params[:key]).paginate :page => params[:page], :per_page => PER_PAGE
    end
    @remote = {:update => 'events', :url => {:action => 'search', :controller => 'user/events', :type => params[:type], :key => params[:key]}}
    render :partial => 'user/event/events', :object => @events
  end

protected

  def setup
    if ['new'].include? params[:action]
      @guild = current_user.privileged_guilds.nonblocked.find(params[:guild_id]) if !params[:guild_id].blank?
    elsif ['show'].include? params[:action]
      @event = Event.find(params[:id], :include => [:game, :game_server, :game_area, {:comments => [{:poster => :profile}]}, :guild])
      require_verified @event
    elsif ['edit', 'update', 'destroy'].include? params[:action]
      @event = Event.find(params[:id])
      require_verified @event 
      require_owner @event.poster
      require_event_not_expired @event
    elsif ['index', 'upcoming', 'participated'].include? params[:action]
      @user = User.find(params[:uid])
      require_friend_or_owner @user
    end
  end

  def require_event_not_expired event
    if event.expired?
      respond_to do |format|
        format.js   { render_js_tip '该活动已经过期'}
        format.html { render_not_found }
      end
    end
  end
  
end

