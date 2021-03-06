class User::ReportsController < UserBaseController

  def new
  end

  def create
    @report = @reportable.reports.build((params[:report] || {}).merge({:poster_id => current_user.id}))
    if @report.save
      render :update do |page|
        page << "facebox.close();"
      end
    else
      render_js_error
    end
  end

protected

  def setup
    @reportable = params[:reportable_type].camelize.constantize.find(params[:reportable_id])
  end

end
