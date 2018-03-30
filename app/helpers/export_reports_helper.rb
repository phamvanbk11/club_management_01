module ExportReportsHelper
  def content_by_style_money report_detail, style
    text = "\n#{I18n.t ".detail"}"
    if report_detail.detail.is_a? Hash
      report_detail.detail.each do |key, value|
        if value[:style] == style
          text += "\n- " + value[:name] + ": " + (number_to_currency value[:money], locals: :vi)
        end
      end
    end
    text
  end

  def content_colum_by_key report_detail, key
    count_money_details(report_detail, key) +
      content_by_style_money(report_detail, key)
  end

  def member_join_in_report_activity report_detail
    list = ""
    report_detail.user_events.each do |name|
      list += name + "\n"
    end
    list
  end

  def time_report report
    if report.monthly?
      I18n.t "export_reports.month", time: report.time
    else
      I18n.t "export_reports.quater", time: report.time
    end
  end

  def size_event report_detail
    if report_detail.member.first && report_detail.member.first.detail.is_a?(Hash)
      report_detail.member.first.detail[:count_event]
    end
  end

  def count_money_details report_detail, style
    total = Settings.default_money
    if report_detail.detail.is_a? Hash
      report_detail.detail.each do |key, value|
        total += value[:money].to_i if value[:style] == style
      end
    else
      total = report_detail.money
    end
    I18n.t("sum_label") + number_to_currency(total, locale: :vi).to_s
  end
end
