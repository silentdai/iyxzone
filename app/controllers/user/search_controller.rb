class User::SearchController < UserBaseController

  layout 'app'

  def user
    @games = Game.find(:all, :order => 'pinyin ASC')
    @users = User.search(params[:key], :include => [:profile, {:characters => [{:server => [:area, :game]}]}]).paginate :page => params[:page], :per_page => 20 
		@key = params[:key]
  end

  def character
    @game = Game.find(params[:game_id]) unless params[:game_id].blank?
    @area = @game.areas.find(params[:area_id]) unless params[:area_id].blank?
    @server = @game.servers.find(params[:server_id]) unless params[:server_id].blank?

    cond = {}
    cond.merge!({:game_id => @game.id}) if !@game.nil? 
    cond.merge!({:area_id => @area.id}) if !@area.nil?
    cond.merge!({:server_id => @server.id}) if !@server.nil?
    
    if @game.nil?
      @areas = []
      @servers = []
    elsif !@game.nil? and !@game.no_areas
      @areas = @game.areas
      @servers = @area.nil? ? [] : @area.servers
    elsif !@game.nil? and @game.no_areas
      @areas = []
      @servers = @game.servers
    end

    @games = Game.find(:all, :order => 'pinyin ASC')
		@total_users = GameCharacter.search(params[:key], :conditions => cond, :include => [{:user => :profile}, {:server => [:area, :game]}]).group_by(&:user_id).to_a
		@key = params[:key]
    @users = @total_users.paginate :page => params[:page], :per_page => 20
  end

end
