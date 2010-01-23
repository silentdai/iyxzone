class User::Guilds::MembershipsController < UserBaseController

  layout 'app'

  def index
		if params[:type].to_i == 0
			@memberships = @guild.memberships.find(:all, :conditions => {:status => [Membership::Veteran, Membership::Member]}).paginate :page => params[:page], :per_page => 10
    elsif params[:type].to_i == 1
      @memberships = @guild.invitations.paginate :page => params[:page], :per_page => 10
      logger.error "多少 ：#{@memberships.count}"
    elsif params[:type].to_i == 2
			@memberships = @guild.requests.paginate :page => params[:page], :per_page => 10
		end
  end

  def edit
    render :action => 'edit', :layout => false  
  end
  
  def update
    old_status = @membership.status
    if @membership.update_attributes(:status => params[:status])
      render :update do |page|
        page << "facebox.close();"
        if old_status != @membership.status
          page << "$('membership_#{@membership.id}').remove();"
        end
      end
    else
      render :update do |page|
        page << "$('error').innerHTML = '错误'"
      end
    end 
  end

  def destroy
    if @membership.destroy
      render :update do |page|
        page << "$('member_#{@membership.user_id}').remove();"
      end
    else
      render :update do |page|
        page << "error('发生错误');"
      end
    end
  end

  def search
		if params[:type].to_i == 0
      @memberships = @guild.veteran_characters
    elsif params[:type].to_i == 1
      @memberships = @guild.member_characters
    elsif params[:type].to_i == 2
      @memberships = @guild.invite_characters
    elsif params[:type].to_i == 3
      @memberships = @guild.request_characters
    end 
		@memberships = @memberships.find_all {|c| c.name.starts_with?(params[:key]) }.paginate :page => params[:page], :per_page => 10, :order => 'login ASC'
    @remote = {:update => 'members', :url => search_guild_memberships_url(@guild, :type => params[:type], :key => params[:key])}
    if params[:type].to_i == 2
			render :partial => 'invitees', :locals => {:memberships => @memberships}
    elsif params[:type].to_i == 3
			render :partial => 'requestors', :locals => {:memberships => @memberships}
    else
			render :partial => 'members', :locals => {:memberships => @memberships}
    end
	end
 
protected

  def setup
    if ['index', 'search'].include? params[:action]
      @guild = Guild.find(params[:guild_id])
      @user = @guild.president
    elsif ['edit', 'update', 'destroy'].include? params[:action]
      @guild = current_user.guilds.find(params[:guild_id])
      @membership = @guild.memberships.find(params[:id])
    end
  rescue
    not_found
  end

end