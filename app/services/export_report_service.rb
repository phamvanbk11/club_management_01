class ExportReportService
  require "axlsx"
  include ActionView::Helpers::NumberHelper
  include ExportReportsHelper
  include ReportDetailsHelper

  def initialize club, report
    @club = club
    @report = report
    @report_details = report.report_details
    init_worksheet
    init_style_row @wb
    init_width_columns
  end

  def create_xlsx_report
    if @report_details.money.present?
      sheet_report_money @wb
    end
    if @report_details.active.present?
      sheet_report_activity @wb
    end
    if @report_details.member.present?
      sheet_report_member @wb
    end
    if @report_details.other.present?
      sheet_report_other @wb
    end
    if @report.plan_next_month.present? || @report.note.present? || @report.others.present?
      sheet_plan_and_note @wb
    end
  end

  def get_xlsx_file
    tmp_file_path = "#{Rails.root}/tmp/#{rand(36**10).to_s(36)}.xlsx"
    @package.serialize tmp_file_path
    tmp_file_path
  end

  private

  def init_worksheet
    @package = Axlsx::Package.new
    @package.use_shared_strings = true
    @wb = @package.workbook
  end

  def sheet_report_money wb
    wb.add_worksheet(name: I18n.t("export_reports.spent_report")) do |sheet|
      sheet.merge_cells Settings.export_report_money.marge_cell_head
      sheet.add_row [I18n.t("export_reports.detail_money", time: time_report(@report), year: @report.year)], style: @title
      sheet.add_row ["", "", "", ""]
      sheet.add_row [I18n.t("stt"), I18n.t("export_reports.date"), I18n.t("export_reports.pay"),
        I18n.t("export_reports.get"), I18n.t("export_reports.has"),
        I18n.t("export_reports.content")], style: @head
      @report_details.money.each.with_index do |detail, index|
        sheet.add_row [index, (I18n.l detail.date_event, format: :short),
          content_colum_by_key(detail, EventDetail.styles.key(Settings.style_event_detail.value_enum_pay)),
          content_colum_by_key(detail, EventDetail.styles.key(Settings.style_event_detail.value_enum_get)),
          number_to_currency(last_money_of_event(detail), locals: :vi),
          detail.name_event], style: @row_money, height: Settings.export_report_money.height
      end
      sheet.column_widths *@col_width_money
    end
  end

  def sheet_report_activity wb
    wb.add_worksheet(name: I18n.t("export_reports.activity_report")) do |sheet|
      sheet.merge_cells Settings.export_report_activity.marge_cell_head
      sheet.add_row [I18n.t("export_reports.detail_activity", time: time_report(@report),
        year: @report.year)], style: @title
      sheet.add_row ["", "", "", ""]
      sheet.add_row [I18n.t("stt"), I18n.t("export_reports.date"), I18n.t("export_reports.name"),
        I18n.t("export_reports.content"), I18n.t("export_reports.member")], style: @head
      @report_details.active.each.with_index do |detail, index|
        sheet.add_row [index, (I18n.l detail.date_event, format: :short), detail.name_event,
          ActionView::Base.full_sanitizer.sanitize(detail.detail),
          member_join_in_report_activity(detail)], style: @row_money,
          height: Settings.export_report_activity.height
      end
      sheet.column_widths *@col_width_activity
    end
  end

  def sheet_report_member wb
    wb.add_worksheet(name: I18n.t("export_reports.member_report")) do |sheet|
      sheet.merge_cells Settings.export_report_member.marge_cell_head
      sheet.add_row [I18n.t("export_reports.detail_member", time: time_report(@report),
        year: @report.year)], style: @title
      sheet.add_row ["", "", "", ""]
      sheet.add_row ["", I18n.t("total_event"), size_event(@report_details)],
      style: @important
      sheet.add_row [I18n.t("stt"), I18n.t("export_reports.full_name"),
        I18n.t("export_reports.size_activity_join")], style: @head
        @report_details.member.first.detail.each_with_index do |(key, value), index|
          if value.is_a? Hash
            sheet.add_row [index, value[:name], value[:size]], style: @row_money
          end
        end
      sheet.column_widths *@col_width_member
    end
  end

  def sheet_report_other wb
    wb.add_worksheet(name: I18n.t("export_reports.other")) do |sheet|
      @report_details.other.each.with_index do |detail, index|
        sheet.merge_cells Settings.export_report_other.marge_cell_head
        sheet.add_row [I18n.t("export_reports.detail_other", time: time_report(@report),
          year: @report.year)], style: @title
        sheet.add_row ["", "", "", ""]
        sheet.add_row [I18n.t("stt"), I18n.t("export_reports.name_category"),
          I18n.t("export_reports.content_report")], style: @head
        sheet.add_row [index, detail.report_category.name, detail.detail], style: @row_money,
          height: Settings.export_report_other.height
        sheet.column_widths *@col_width_other
      end
    end
  end

  def sheet_plan_and_note wb
    wb.add_worksheet(name: I18n.t("export_reports.plan_and_note")) do |sheet|
      sheet.merge_cells Settings.export_plan.marge_cell_head
        sheet.add_row [I18n.t("export_reports.plan_and_note")], style: @title
        sheet.add_row ["", ""]
      sheet.add_row [I18n.t("export_reports.plan"), @report.plan_next_month], style: @row_money, height: Settings.export_plan.height
      sheet.add_row [I18n.t("export_reports.note"), @report.note], style: @row_money, height: Settings.export_plan.height
      sheet.add_row [I18n.t("export_reports.other"), @report.others], style: @row_money, height: Settings.export_plan.height
      sheet.column_widths *@col_width_plan
    end
  end

  def init_style_row wb
    @title = wb.styles.add_style(
      bg_color: Settings.export_report.bg_title, fg_color: Settings.export_report.fg_title,
      sz: Settings.export_report.sz_title, border: Axlsx::STYLE_THIN_BORDER,
      alignment: {horizontal: :center})
    @percent = wb.styles.add_style(
      border: Axlsx::STYLE_THIN_BORDER, alignment: {horizontal: :left, vertical: :center})
    @important = wb.styles.add_style(
      border: Axlsx::STYLE_THIN_BORDER, fg_color: Settings.export_report.fg_manager,
      alignment: {horizontal: :center}, sz: 13)
    @head = wb.styles.add_style(
      fg_color: Settings.export_report.fg_title, sz: Settings.export_report.sz_head,
      border: Axlsx::STYLE_THIN_BORDER, alignment: {horizontal: :center})
    @row_money = wb.styles.add_style(
      border: Axlsx::STYLE_THIN_BORDER, sz: 11,
      alignment: {horizontal: :left, vertical: :center, wrap_text: true})
  end

  def init_width_columns
    @col_width_money = [Settings.export_report_money.width_colums.a, Settings.export_report_money.width_colums.b,
      Settings.export_report_money.width_colums.c, Settings.export_report_money.width_colums.d,
      Settings.export_report_money.width_colums.e, Settings.export_report_money.width_colums.f]
    @col_width_activity = [Settings.export_report_activity.width_colums.a,
      Settings.export_report_activity.width_colums.b,
      Settings.export_report_activity.width_colums.c, Settings.export_report_activity.width_colums.d,
      Settings.export_report_activity.width_colums.e]
    @col_width_member = [Settings.export_report_member.width_colums.a,
      Settings.export_report_member.width_colums.b,
      Settings.export_report_member.width_colums.c, Settings.export_report_member.width_colums.d,
      Settings.export_report_member.width_colums.e]
    @col_width_other = [Settings.export_report_other.width_colums.a,
      Settings.export_report_other.width_colums.b,
      Settings.export_report_other.width_colums.c]
    @col_width_plan = [Settings.export_plan.width_colums.a,
      Settings.export_plan.width_colums.b]
  end
end
