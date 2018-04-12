class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = notifications_result.page(params[:page]).per Settings.notification_per_page
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    @notifications = notifications_result
    @notifications.each do |notification|
      arr_read_all = notification.user_read
      if arr_read_all.blank?
        arr_read_all = [current_user.id]
        notification.update_attributes user_read: arr_read_all
      elsif !arr_read_all.include?(current_user.id)
        arr_read_all = arr_read_all.push(current_user.id)
        notification.update_attributes user_read: arr_read_all
      end
    end
  end
end
