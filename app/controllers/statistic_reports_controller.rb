class StatisticReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization, except: %i(new destroy)
  before_action :check_user_organization, only: :index
  before_action :load_statistic, only: %i(show update edit)
  authorize_resource

  def index
    if @organization
      @q = StatisticReport.search params[:q]
      club_ids = @organization.clubs.pluck :id
      @statistic_reports = Support::StatisticReportSupport
        .new club_ids, params[:page], params[:q]
      id_clubs_report = @statistic_reports.club_is_not_report.search(params[:q])
        .result.map(&:club_id)
      @clubs_not_report = Club.not_report(club_ids - id_clubs_report)
    end
  end

  def show; end

  def edit; end

  def update
    if params[:status].to_i == StatisticReport.statuses[:approved]
      approve_report
    elsif params[:status].to_i == StatisticReport.statuses[:rejected]
      reject_report
    end
    all_report
  end

  private
  def reject_report_params
    params.require(:statistic_report).permit(:reason_reject)
      .merge! status: params[:status].to_i
  end

  def check_user_organization
    return if can? :manager, @organization
    flash[:warning] = t "manager_require"
  end

  def load_organization
    @organization = Organization.friendly.find_by slug: params[:organization_slug]
    return if @organization
    flash[:danger] = t "not_found_organization"
  end

  def load_statistic
    @statistic_report = StatisticReport.find_by id: params[:id]
    @report_details = @statistic_report.report_details.includes(:report_category)
      .group_by(&:report_category_id) if @statistic_report
    return if @statistic_report
    flash.now[:danger] = t "not_found_statistic"
  end

  def approve_report
    if @statistic_report.approved!
      flash.now[:success] = t "approve_success"
      create_acivity @statistic_report, Settings.approve_report,
        @statistic_report.club, current_user, Activity.type_receives[:club_manager]
    else
      flash.now[:danger] = t "approve_error"
    end
  end

  def reject_report
    if @statistic_report.update_attributes reject_report_params
      SendEmailJob.perform_now @statistic_report.user, @statistic_report.club,
        @statistic_report
      flash.now[:success] = t "reject_success"
      create_acivity @statistic_report, Settings.reject_report,
        @statistic_report.club, current_user, Activity.type_receives[:club_manager]
    else
      flash.now[:danger] = t "reject_error"
    end
  end

  def all_report
    @q = StatisticReport.search params[:q]
    club_ids = @organization.clubs.pluck :id
    @statistic_reports = Support::StatisticReportSupport
      .new club_ids, params[:page], params[:q]
    id_clubs_report = @statistic_reports.club_is_not_report.search(params[:q])
      .result.map(&:club_id)
    @clubs_not_report = Club.not_report(club_ids - id_clubs_report)
  end
end
