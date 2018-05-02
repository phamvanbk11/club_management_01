module MoneySupportsHelper
  def get_range_string range_support
    if range_support.range?
      range_support.value_from.to_s + " ~< " + range_support.value_to.to_s
    else
      t("." + range_support.operator.to_s) + " " + range_support.value_from.to_s
    end
  end

  def by_style_range range_supports, style
    range_supports.select{|range| range.style == style}
  end
end
