class WarningReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_warning_report, only: :update
  before_action :load_user_club, only: :edit

  def index
    @warnings = @warning.page(params[:page]).per Settings.notification_per_page
  end

  def create
    club_ids = params[:club_id].split(" ")
    warning_report = []
    ActiveRecord::Base.transaction do
      club_ids.each do |club_id|
        warning_report << WarningReport.new(club_id: club_id, time: params[:report_type],
          year: params[:report_year], style: params[:report_style],
          deadline: params[:date_deadline])
      end
      WarningReport.import! warning_report
      flash.now[:success] = t ".messenger_report_success"
    end
  rescue
    flash.now[:danger] = t ".errors"
  end

  def edit
    if @user_club && @warning
      @warning.each do |warning_report|
        arr_read_all = warning_report.user_read
        if arr_read_all.blank?
          arr_read_all = [current_user.id]
        elsif !arr_read_all.include?(current_user.id)
          arr_read_all << arr_read_all.push(current_user.id)
        end
        warning_report.update_attributes user_read: arr_read_all
      end
    end
  end

  def update
    if @warning_report.user_read.blank?
      arr_read = [current_user.id]
    else
      arr_read = @warning_report.user_read
      unless arr_read.include?(current_user.id)
        arr_read = arr_read.push(current_user.id)
      end
    end
    @warning_report.update_attributes user_read: arr_read
  end

  private
  def load_warning_report
    @warning_report = WarningReport.find_by id: params[:id]
    return if @warning_report
    flash[:danger] = t("not_foud_activity")
    redirect_to root_url
  end

  def load_user_club
    @user_club = current_user.user_clubs.joined
    return if @user_club.present?
    flash.now[:danger] = t "no_notification"
  end
end
