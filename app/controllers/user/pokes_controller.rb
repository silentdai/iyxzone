class User::PokesController < UserBaseController

	layout 'app'

  def index
    @deliveries = current_user.poke_deliveries.paginate :page => params[:page], :per_page => 10, :include => [:sender]
  end

  def new
    @recipient = User.find(params[:recipient_id])
    render :action => 'new', :layout => false
  end

  def create
    @delivery = PokeDelivery.new((params[:delivery] || {}).merge({:sender_id => current_user.id}))

    if @delivery.save
      render_js_tip '发送成功' 
    else
      render_js_error '你没有权限'
    end
  end

  def destroy
    if @delivery.destroy
      render :update do |page|
        page << "$('poke_delivery_#{@delivery.id}').remove();"
      end
    else
      render_js_error
    end
  end

  def destroy_all
		PokeDelivery.destroy_all(:recipient_id => current_user.id)
    render :update do |page|
      flash[:notice] = "删除成功"
      page.redirect_to pokes_url
    end
  end

protected

	def setup
		if ["destroy"].include? params[:action]
			@delivery = PokeDelivery.find(params[:id])
      require_owner @delivery.recipient
		end
	end

end
