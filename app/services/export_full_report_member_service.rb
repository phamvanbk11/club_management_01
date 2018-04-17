class ExportFullReportMemberService
  require "axlsx"
  include ActionView::Helpers::NumberHelper
  include ExportReportsHelper
  include ReportDetailsHelper

  def initialize organization, time, year, style
    @organization = organization
    @time = time
    @year = year
    @style = style
    init_worksheet
    init_style_row
    init_width_columns
  end

  def create_xlsx_report
    club_ids = @organization.clubs.ids
    report_ids = StatisticReport.search_club(club_ids).search_time(@time, @year).style(@style).ids
    report_details_members = ReportDetail.by_report_id(report_ids).member
    sheet_report_member report_details_members
  end

  def get_xlsx_file
    tmp_file_path = "#{Rails.root}/tmp/#{rand(Settings.rand_file_name.num**Settings.rand_file_name.xnum)
      .to_s(Settings.rand_file_name.num)}.xlsx"
    @package.serialize tmp_file_path
    tmp_file_path
  end

  private

  def init_worksheet
    @package = Axlsx::Package.new
    @package.use_shared_strings = true
    @wb = @package.workbook
  end

  def sheet_report_member report_details_members
    @wb.add_worksheet(name: I18n.t("export_reports.member_report")) do |sheet|
      sheet.merge_cells Settings.export_full_report_members.merge_cell_head
      sheet.add_row [I18n.t("export_report_members.report_time", time: time_report_title(@style, @time),
        year: @year, organization: @organization.name)], style: @title
      sheet.add_row ["", "", "", ""]
      sheet.add_row [I18n.t("stt"), I18n.t("club"), I18n.t("employee_code"), I18n.t("export_reports.full_name"),
        I18n.t("export_reports.size_activity_join")], style: @head
        index = 0
        report_details_members.each do |report_detail|
          report_detail.detail.each do |key, value|
            if value.is_a? Hash
              sheet.add_row [index, report_detail.statistic_report.club_name,
                value[:employee_code], value[:name], value[:size]], style: @row_money
              index = index + 1
            end
          end
          sheet.add_row ["", "", "", "", ""], style: @row_money
        end
      sheet.column_widths *@col_width_member
    end
  end

  def init_style_row
    @title = @wb.styles.add_style(
      bg_color: Settings.export_report.bg_title, fg_color: Settings.export_report.fg_title,
      sz: Settings.export_report.sz_title, border: Axlsx::STYLE_THIN_BORDER,
      alignment: {horizontal: :center, vertical: :center})
    @head = @wb.styles.add_style(
      fg_color: Settings.export_report.fg_title, sz: Settings.export_report.sz_head,
      border: Axlsx::STYLE_THIN_BORDER, alignment: {horizontal: :center})
    @row_money = @wb.styles.add_style(
      border: Axlsx::STYLE_THIN_BORDER, sz: 11,
      alignment: {horizontal: :left, vertical: :center, wrap_text: true})
  end

  def init_width_columns
    @col_width_member = [Settings.export_full_report_members.width_colums.a,
      Settings.export_full_report_members.width_colums.b,
      Settings.export_full_report_members.width_colums.c,
      Settings.export_full_report_members.width_colums.d,
      Settings.export_full_report_members.width_colums.e]
  end
end
