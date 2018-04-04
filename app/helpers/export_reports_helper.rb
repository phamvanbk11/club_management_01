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
    if report_detail.detail.is_a? Hash
      count_money_details(report_detail, key) +
        content_by_style_money(report_detail, key)
    else
      count_money_details(report_detail, key)
    end
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
    elsif style == EventDetail.styles.key(Settings.style_event_detail.value_enum_get)
      total = report_detail.money
    end
    I18n.t("sum_label") + number_to_currency(total, locale: :vi).to_s
  end

  def first_money array_detail
    number_to_currency array_detail.first.first_money, locale: :vi
  end

  def last_money array_detail
    first_money = array_detail.first.first_money
    array_detail.each do |detail|
      first_money += detail.money
    end
    number_to_currency first_money, locale: :vi
  end

  def pay_total details
    number_to_currency total_pay_get_money(details).first, locale: :vi
  end

  def get_total details
    number_to_currency total_pay_get_money(details).second, locale: :vi
  end
end
