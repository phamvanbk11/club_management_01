class FeedBacksController < ApplicationController
  before_action :authenticate_user!

  def new
    @feed_back = FeedBack.new
  end

  def create
    feed_back = FeedBack.new feed_back_params
    if feed_back.save
      flash[:success] = t "tks_for_feed_back"
      redirect_to root_url
    else
      flash[:danger] = t "error_create"
      redirect_back fallback_location: root_path
    end
  end

  private
  def feed_back_params
    params.require(:feed_back).permit(:content, :description)
      .merge!(user_id: current_user.id, type_feed_back: params[:type].to_i)
  end
end
