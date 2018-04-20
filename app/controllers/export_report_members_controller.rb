class ExportReportMembersController < ApplicationController
  include ExportReportsHelper
  before_action :authenticate_user!
  before_action :load_organization
  authorize_resource class: false, through: :organization

  def index
    export_service = ExportFullReportMemberService.new @organization, params[:time],
      params[:year], params[:style]
    export_service.create_xlsx_report
    tmp_file_path = export_service.get_xlsx_file
    filename = "#{t ".report_time", time: time_report_title(params[:style],
      params[:time]), year: params[:year], organization: @organization.name}.xlsx"
    file_content = File.read tmp_file_path
    send_data file_content, filename: filename
    File.delete tmp_file_path
  end

  def load_organization
    @organization = Organization.find_by slug: params[:organization_id]
    return if @organization
    flash[:danger] = t ".not_found_org"
    redirect_back fallback_location: root_path
  end
end
