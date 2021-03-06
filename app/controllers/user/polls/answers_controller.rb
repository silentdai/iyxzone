class User::Polls::AnswersController < UserBaseController

  def new
  end
 
  def create
    if @poll.update_attributes(:answers => params[:poll][:answers])
      render :update do |page|
        page << "facebox.close();"
        page.redirect_to poll_url(@poll)
      end
    else
      render_js_error
    end
  end

protected

  def setup
    @poll = Poll.find(params[:poll_id])
    require_verified @poll
    require_owner @poll.poster
  end

end
