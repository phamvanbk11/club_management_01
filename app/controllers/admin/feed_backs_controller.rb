class Admin::FeedBacksController < ApplicationController
  layout "admin_layout"
  before_action :admin_signed_in

  def index
    @feed_backs = FeedBack.includes(:user).newest.page(params[:page]).per Settings.per_page_criteria
  end
end
