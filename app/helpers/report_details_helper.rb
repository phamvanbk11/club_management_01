module ReportDetailsHelper
  def total_money details
    number_to_currency details.sum(&:money), locale: :vi
  end

  def count_money_detail report_detail, style
    total = Settings.default_money
    if report_detail.detail.is_a? Hash
      report_detail.detail.each do |key, value|
        total += value[:money].to_i if value[:style] == style
      end
    elsif is_report_detail_money_and_style_get_money?(style, report_detail)
      style == EventDetail.styles.key(Settings.style_event_detail.value_enum_get)
      total = report_detail.money
    end
    t("sum_label") + number_to_currency(total, locale: :vi).to_s
  end

  def view_total_pay_get_money array_detail
    array_pay_get = total_pay_get_money array_detail
    content_tag(:td, number_to_currency(array_pay_get.first, locale: :vi)) <<
      content_tag(:td, number_to_currency(array_pay_get.second, locale: :vi))
  end

  def last_money_of_event report_detail
    money = report_detail.first_money
    if report_detail.detail.is_a? Hash
      report_detail.detail.each do |key, value|
        if value[:style] == EventDetail.styles.key(Settings.style_event_detail.value_enum_pay)
          money -= value[:money].to_i
        elsif value[:style] == EventDetail.styles.key(Settings.style_event_detail.value_enum_get)
          money += value[:money].to_i
        end
      end
    else
      money += report_detail.money
    end
    money
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

  def view_by_style_details report_detail, style
    content_tag(:ul, class: "collapse", id: "detail-#{style}-#{report_detail.id}") do
      if report_detail.detail.is_a? Hash
        report_detail.detail.each do |key, value|
          if value[:style] == style
            concat content_tag(:li, format_date_dd_mm_yy(value[:date]) + value[:name] + ": " +
              number_to_currency(value[:money], locals: :vi) )
          end
        end
      end
    end
  end

  def is_present_details? report_detail, style
    if report_detail.detail.is_a? Hash
      report_detail.detail.each do |key, value|
        return true if(value[:style] == style)
      end
    end
    false
  end

  def is_size_more_eight? detail
    detail.user_events.size > Settings.number_view_user_event
  end

  private

  def total_pay_get_money array_detail
    pay_total = Settings.default_money
    get_total = Settings.default_money
    array_detail.each do |report_detail|
      if report_detail && report_detail.detail.is_a?(Hash)
        report_detail.detail.each do |key, value|
          if value[:style] == EventDetail.styles.key(Settings.style_event_detail.value_enum_pay)
            pay_total += value[:money].to_i
          elsif value[:style] == EventDetail.styles.key(Settings.style_event_detail.value_enum_get)
            get_total += value[:money].to_i
          end
        end
      elsif report_detail && report_detail.money
        get_total += report_detail.money
      end
    end
    [pay_total, get_total]
  end

  def format_date_dd_mm_yy date
    if date
      (l date, format: :short) + " | "
    else
      ""
    end
  end

  def is_report_detail_money_and_style_get_money? style, report_detail
    report_detail.money? && style == EventDetail.styles.key(
      Settings.style_event_detail.value_enum_get)
  end
end
