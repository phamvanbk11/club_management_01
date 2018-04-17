class SetStaticReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  before_action :report_categories

  def index
    @statistic_report = @club.statistic_reports.build
    @statistic_report.report_details.build
    @statistic_report.style = params[:q][:style].to_i
    if @statistic_report.quarterly?
      @statistic_report.time = params[:q][:quarter]
    else
      @statistic_report.time = params[:q][:month]
    end
    @statistic_report.year = params[:q][:date_year]
    load_events_for_report @report_categories, @statistic_report
  end

  private
  def load_club
    @club = Club.find_by id: params[:club_id]
    unless @club
      flash[:danger] = t "not_found"
      redirect_to root_url
    end
  end

  def report_categories
    @report_categories = @club.organization.report_categories.active
  end
end
