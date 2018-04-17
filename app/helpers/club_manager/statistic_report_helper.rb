module ClubManager::StatisticReportHelper
  def option_select option
    option.map{|k, v| [t(k.to_s), v]}
  end

  def set_title_edit_report report
    if report.monthly?
      t "title_edit_report", time: month_report(report.time), year: report.year
    elsif report.quarterly?
      t "title_edit_report", time: quarter_report(report.time), year: report.year
    end
  end

  def option_select_with_status report_categories
    report_categories.map{|category| [category.name + set_status(category), category.id]}
  end

  def is_report_of_category_obligatory? report
    report.report_category.obligatory?
  end

  def count_event array_details
    array_details.first.detail[:count_event] if array_details.first.detail.is_a? Hash
  end

  def content_detail_member content_hash
    if content_hash.is_a?(Hash) && content_hash[:name] && content_hash[:size]
      content_tag(:td, content_hash[:employee_code]) <<
      content_tag(:td, content_hash[:name]) <<
      content_tag(:td, content_hash[:size])
    end
  end

  def is_manager_club? user, club
    club.user_clubs.manager.pluck(:user_id).include? user.id
  end

  private
  def set_status category
    case category.status
    when Settings.obligatory
      t "statistic_report_helper.important"
    else
      ""
    end
  end
end
