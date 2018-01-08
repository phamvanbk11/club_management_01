class ClubManager::StatisticReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  before_action :load_report, only: %i(show edit update)
  authorize_resource

  def index
    gon_variable
    @statistic_report = current_user.statistic_reports.build club_id: @club.id
    all_report if @club
    respond_to do |format|
      format.js
    end
  end

  def show; end

  def edit
    gon_variable
  end

  def update
    if @report && @report.update_attributes(params_with_check_style)
      flash.now[:success] = t "update_report_success"
    elsif @report
      flash.now[:danger] = t "update_report_error"
    end
    respond_to do |format|
      format.js
    end
  end

  private
  def report_params
    params.require(:statistic_report).permit(:item_report, :detail_report,
      :plan_next_month, :note, :year).merge! style: params[:statistic_report][:style].to_i
  end

  def params_with_check_style
    params_with_check_style = report_params
    case params_with_check_style[:style]
    when Settings.style_month
      params_with_check_style.merge! time: params[:month].to_i
    when Settings.style_quater
      params_with_check_style.merge! time: params[:quarter].to_i
    end
  end

  def load_report
    @report = @club.statistic_reports.find_by id: params[:id] if @club
    return if @report
    flash.now[:danger] = t "error_find_report"
  end

  def all_report
    reports = @club.statistic_reports
    @q = reports.search params[:q]
    if params[:q]
      @params_q = params[:q]
      @reports = @q.result.order_by_created_at.page(params[:page]).per Settings.per_page_report
    else
      @reports = reports.order_by_created_at.page(params[:page])
        .per Settings.per_page_report
    end
  end

  def load_club
    @club = Club.friendly.find_by slug: params[:club_id]
    return if @club
    flash.now[:danger] = t "error_load_club"
  end

  def gon_variable
    gon.month = StatisticReport.styles[:monthly]
    gon.quarter = StatisticReport.styles[:quarterly]
  end
end
