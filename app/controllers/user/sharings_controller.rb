class User::SharingsController < UserBaseController

  def new
    if SITE_URL =~ /#{@host}/
      # in site url
      @shareable_type = @path.split('/')[1].singularize.camelize
      @shareable_id = @path.split('/')[2]
      @shareable = @shareable_type.constantize.find(@shareable_id)
      @title = @shareable.default_share_title
    else
      if Youku.identify_url(@my_url)
        @video = Video.new
      else
        @link = Link.new 
      end
      @title = (params[:at] == 'outside')? params[:title] : get_page_title
    end
    
    if params[:at] == 'outside'
      render :action => 'new_from_outside'
    else
      render :action => 'new'
    end
  end

  def create
    if SITE_URL =~ /#{@host}/
      # in site url
      @shareable_type = @path.split('/')[1].singularize.camelize
      @shareable_id = @path.split('/')[2]
      @shareable = @shareable_type.constantize.find(@shareable_id)
    else
      if Youku.identify_url(@my_url)
        video_params = (params[:video] || {}).merge({:title => params[:title], :description => params[:reason], :poster_id => current_user.id})
        @shareable = Video.create(video_params)
      else
        @shareable = Link.create(params[:link])
      end
    end
    
    if @shareable.share_by current_user, params[:title], params[:reason]
      render :update do |page|
        if params[:at] == 'outside'
          page << "window.close();"
        elsif params[:at] == 'shares'
          page.redirect_to shares_url(:uid => current_user.id)
        else
          page << "tip('分享成功');"
        end
      end       
    else
      render :update do |page|
        page << "error('同一个资源只能分享一次');"
      end
    end 
  end

  def show
    @link = @share.shareable
    render :action => 'show', :layout => false
  end

protected

  def setup
    if ["show"].include? params[:action]
      @sharing = Sharing.find(params[:id])
      @share = @sharing.share 
      require_external_link @share
    elsif ["new", "create"].include? params[:action]
      @my_url = params[:url]
      if !@my_url.starts_with? 'http://' and !@my_url.starts_with? 'https'
        @my_url = "http://#{@my_url}"
      end
      @uri = URI.parse(@my_url)
      @host = @uri.host
      @path = @uri.path
    end
  end

  def require_external_link share
    share.shareable_type == 'Link' || render_not_found
  end

  def get_page_title
    require 'iconv'
    @query = @uri.query
    http = Net::HTTP.new(@host, @uri.port)
    if @uri.scheme.downcase == 'https'
      http.use_ssl = true
    end
    if @path.blank?
      resp, body = http.get('/')
    else
      if @query.blank?
        resp, body = http.get(@path)
      else
        resp, body = http.get("#{@path}/#{@query}")
      end
    end
    if resp.is_a? Net::HTTPSuccess
      body =~ /<title>(.*?)<\/title>/
      title = $1
      content_type = resp['Content-Type']
      content_type =~ /charset=(.*)/
      charset = $1
      Iconv.iconv('utf8', charset, title)
    else
      @my_url
    end
  end

end
