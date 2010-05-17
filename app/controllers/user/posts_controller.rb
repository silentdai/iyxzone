class User::PostsController < UserBaseController

  layout 'app'

  increment_viewing 'topic', 'topic_id', :only => [:index]

  PER_PAGE = 20

  def index
    if !params[:post_id].blank?
      @post = Post.find(params[:post_id])
      params[:page] = @topic.posts.index(@post) / PER_PAGE + 1
    end
    @random_topics = Topic.random :limit => 5, :except => [@topic], :conditions => {:forum_id => @forum.id}
    @posts = @topic.posts.nonblocked.paginate :page => params[:page], :per_page => PER_PAGE
    @cond = {:top => @topic.top}.merge Topic.nonblocked_cond
    @next = @topic.next @cond
    @prev = @topic.prev @cond
  end

  def create
    @post = @topic.posts.build(params[:post].merge({:poster_id => current_user.id, :forum_id => @forum.id}))

    if @post.save
      redirect_to forum_topic_posts_url(@forum, @topic, :page => (@topic.posts_count + 1)/20 + 1)     
    else
      flash[:error] = '保存出错'
      redirect_to forum_topic_posts_url(@forum, @topic)
    end
  end

  def destroy
    if @post.destroy
      render_js_code  "$('post_#{@post.id}').remove();alert('成功')"
    else
      render_js_error
    end 
  end

protected
 
	def setup
		if ["index", "create"].include? params[:action]
			@forum = Forum.find(params[:forum_id])
			@topic = @forum.topics.find(params[:topic_id])
      @guild = @forum.guild
		elsif ["destroy"].include? params[:action]
			@forum = Forum.find(params[:forum_id])
      @topic = @forum.topics.find(params[:topic_id])
			@post = @topic.posts.find(params[:id])
      @guild = @forum.guild
      @guild.president == current_user || render_not_found
		end
	end

end
