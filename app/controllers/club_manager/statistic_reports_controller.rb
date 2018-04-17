class ClubManager::StatisticReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  before_action :new_statistic, only: :create
  before_action :load_report, only: %i(show edit update)
  before_action :load_report_categories, only: %i(index edit new)
  before_action :load_static_report, only: :destroy
  authorize_resource

  def index
    gon_variable
    if @club
      @statistic_report = current_user.statistic_reports.build club_id: @club.id
      @statistic_report.report_details.build
      all_report
    end
  end

  def show; end

  def edit
    gon_variable
    @report_categories = @club.organization.report_categories.active.all
    load_events_for_report @report_categories, @report
  end

  def destroy
    if @static_report && (@static_report.pending? || @static_report.rejected?)
      if @static_report.destroy
        flash[:success] = t "success_process"
      else
        flash[:danger] = t "error_process"
      end
    end
  end

  def update
    ActiveRecord::Base.transaction do
      @report.report_details.delete_all
      @report.update_attributes! report_params
      send_notification
      create_detail_report @report
      flash.now[:success] = t "update_report_success"
      create_acivity @report, Settings.create_report,
        @club.organization, current_user, Activity.type_receives[:organization_manager]
    end
  rescue
    flash.now[:danger] = t ".error_process"
  end

  def new
    @statistic_report = current_user.statistic_reports.build club_id: @club.id
    @statistic_report.report_details.build
    @statistic_report.style = :monthly
    all_report
    load_events_for_report @report_categories, @statistic_report
  end

  def create
    ActiveRecord::Base.transaction do
      if @statistic_report.save!
        create_detail_report @statistic_report
        flash.now[:success] = t "create_statistic_report_success"
        create_acivity @statistic_report, Settings.create_report,
          @club.organization, current_user, Activity.type_receives[:organization_manager]
      else
        flash.now[:danger] = t "create_statistic_report_fail"
      end
    end
  rescue
    flash.now[:danger] = t "create_statistic_report_fail"
  end

  private
  def report_params
    params.require(:statistic_report).permit(:item_report, :detail_report,
      :plan_next_month, :note, :year, :others, report_details_attributes:
      [:report_category_id, :detail, :id, :_destroy])
      .merge!(status: :pending, reason_reject: nil)
  end

  def load_report
    @report = @club.statistic_reports.find_by id: params[:id] if @club
    @report_details = @report.report_details.includes(:report_category)
      .group_by(&:report_category_id) if @report
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
    if request.xhr?
      flash.now[:danger] = t "error_load_club"
    else
      flash[:danger] = t "error_load_club"
      redirect_back fallback_location: root_path
    end
  end

  def gon_variable
    gon.month = StatisticReport.styles[:monthly]
    gon.quarter = StatisticReport.styles[:quarterly]
  end

  def send_notification
    if @report && @report.rejected?
      create_acivity @report, Settings.update_report,
        @club.organization, current_user, Activity.type_receives[:organization_manager]
    end
  end

  def load_report_categories
    @report_categories = @club.organization.report_categories.active if @club
  end

  def load_static_report
    if @club
      @static_report = StatisticReport.find_by(id: params[:id])
      return if @static_report
      flash.now[:danger] = t "error_find_report"
    end
  end

  def create_detail_report static_report
    report_categories = ReportCategory.load_category.active.by_category(@club.organization_id)
    if report_categories
      service = CreateReportService.new report_categories, static_report, @club
      ReportDetail.import service.create_report
    end
  end

  def new_statistic
    if @club
      @statistic_report = current_user.statistic_reports.new statistic_report_params
      case params[:statistic_report][:style]
      when Settings.style_statistic.month
        @statistic_report.time = params[:month]
      when Settings.style_statistic.quarter
        @statistic_report.time = params[:quarter]
      end
      @statistic_report.fund = @club.money
      @statistic_report.members = @club.member
      @statistic_report.status = :pending
    end
  end

  def statistic_report_params
    params.require(:statistic_report).permit(:time,
      :item_report, :detail_report, :plan_next_month, :note, :others,
      report_details_attributes: [:report_category_id, :detail, :style])
      .merge! style: params_style, club_id: @club.id, year: params_date
  end

  def params_style
    if params[:statistic_report] && params[:statistic_report][:style]
      params[:statistic_report][:style].to_i
    end
  end

  def params_date
    if params[:date] && params[:date][:year]
      params[:date][:year].to_i
    end
  end
end
