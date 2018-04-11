class Admin::FeedBacksController < Admin::AdminController
  def index
    @feed_backs = FeedBack.includes(:user).newest.page(params[:page]).per Settings.per_page_criteria
  end
end
