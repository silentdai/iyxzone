class User::DigsController < UserBaseController

  def create
    @dig = Dig.new((params[:dig] || {}).merge(:poster_id => current_user.id))
    if @dig.save
      render :update do |page|
        page << "tip('成功')"
        page << "$('dig_#{params[:dig][:diggable_type].underscore}_#{params[:dig][:diggable_id]}').innerHTML = #{@dig.diggable.digs_count + 1}"
      end
    else
      render :update do |page|
        page << "tip('你只能挖一次');"
      end
    end
  end

end