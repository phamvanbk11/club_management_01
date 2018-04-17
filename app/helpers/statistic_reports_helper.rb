module StatisticReportsHelper
  def option_select option
    option.map{|k, v| [t(k.to_s), v]}
  end

  def month_report data
    t StatisticReport.months.key(data).to_s
  end

  def quarter_report data
    t StatisticReport.quarters.key(data).to_s
  end

  def link_approve_report organization_slug, statistic_report
    link_to statistic_report_path(statistic_report, organization_slug: organization_slug,
      status: StatisticReport.statuses[:approved], q: params_reports,
      style_report: StatisticReport.styles[:monthly]), remote: :true, method: :patch,
      title: t("accept"), data: {confirm: t("confirm_approve")},
      class: "btn btn-sm btn-breez aprove-user" do
      content_tag(:i, "", class: "fa fa-check-square-o")
    end
  end

  def link_reject_report organization_slug, statistic_report
    link_to edit_statistic_report_path(statistic_report, organization_slug: organization_slug),
      title: t("reject"), remote: true,
      class: "btn btn-sm btn-danger aprove-user" do
      content_tag(:i, "", class: "fa fa-ban")
    end
  end

  def url_reject_report organization_slug, statistic_report
    statistic_report_path(statistic_report,
      organization_slug: organization_slug,
      status: StatisticReport.statuses[:rejected], q: params_reports,
      style_report: StatisticReport.styles[:monthly])
  end

  def money_expense event
    if event.get_money_member?
      event.expense * event.budgets.size
    else
      event.expense
    end
  end

  def option_select_time style, club
    if club.is_action_report?
      option_time_full style
    else
      option_time_limit style
    end
  end

  def current_quarter
    1 + (Date.current.month - 1) / 3
  end

  def get_month_from_quarter quarter
    case quarter
    when StatisticReport.quarters[:quarter_1]
      Settings.quarter_1
    when StatisticReport.quarters[:quarter_2]
      Settings.quarter_2
    when StatisticReport.quarters[:quarter_3]
      Settings.quarter_3
    else
      Settings.quarter_4
    end
  end

  def option_time_full style
    case style
    when :monthly
      option_select(StatisticReport.months)
    when :quarterly
      option_select(StatisticReport.quarters)
    else
      Settings.year_ago.years.ago.year
    end
  end

  def option_time_limit style
    case style
    when :monthly
      option_select(StatisticReport.months.select{|k ,v| v >= Date.current.month})
    when :quarterly
      option_select(StatisticReport.quarters.select{|k ,v| v >= current_quarter})
    else
      Date.current.year
    end
  end
end
