class User::RatingsController < UserBaseController

  def create
    @rating = Rating.new((params[:rating] || {}).merge(:user_id => current_user.id))

    if @rating.save
      @rateable = @rating.rateable
      render :update do |page|
        page.replace_html "#{@rateable.class.name.underscore}_#{@rateable.id}_rating_form", :partial => 'show', :locals => {:rateable => @rateable}
      end
    else
      render :update do |page|
        page << "error('发生错误');"
      end
    end
  end

end
