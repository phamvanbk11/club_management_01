class ExportReportsController < ApplicationController
  include ExportReportsHelper
  include ReportDetailsHelper

  before_action :authenticate_user!
  before_action :load_club
  before_action :load_report

  def index
    export_service = ExportReportService.new @club, @report
    export_service.create_xlsx_report
    tmp_file_path = export_service.get_xlsx_file
    filename = "#{t ".report_time", time: time_report(@report), year: @report.year, club: @report.club.name}.xlsx"
    file_content = File.read tmp_file_path
    send_data file_content, filename: filename
    File.delete tmp_file_path
  end

  private
  def load_report
    @report = StatisticReport.find_by id: params[:report_id]
    return if @report
    flash[:danger] = t ".cant_find_report"
    redirect_to @club
  end

  def load_club
    @club = Club.find_by id: params[:club_id]
    return if @club
    flash[:danger] = t ".cant_find_club"
    redirect_to root_url
  end
end
