class User::MailSettingController < UserBaseController

  layout 'app'

  def edit
  end

  def update
    if @setting.update_attributes(params[:setting])
      flash[:notice] = "设置保存成功"
      redirect_to :action => 'edit'
    else
			flash[:notice] = "设置保存失败"
      render :action => 'edit'
    end
  end

protected

  def setup
    @setting = current_user.mail_setting
  end

end
