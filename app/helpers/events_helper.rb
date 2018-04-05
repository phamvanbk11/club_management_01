module EventsHelper
  def number_to_vnd amount
    html_safe? "#{amount} <sup>vnđ</sup>"
  end

  def view_case_money_after event
    if event.subsidy?
      event.amount.to_i + event.expense.to_i
    elsif event.pay_money?
      event.amount.to_i - event.expense.to_i
    elsif event.get_money?
      event.amount.to_i + (@members_done.size.to_i * event.expense.to_i)
    end
  end

  def view_notification event
    case event.event_category
    when Settings.get_money
      t("after_get_money")
    when Settings.pay_money
      t("after_pay_money")
    when Settings.subsidy
      t("after_receive_money")
    else
      t("notification_event")
    end
  end

  def view_case_money_event_after event, club
    members_done = User.done_by_ids(event.budgets.pluck :user_id)
    case event.event_category
    when Settings.get_money_member
      after_money = event.amount.to_i + (members_done.size.to_i * event.expense.to_i)
    when Settings.money, Settings.activity_money, Settings.subsidy, Settings.donate
      after_money = event.amount.to_i + event.expense.to_i
    else
      after_money = nil
    end
    after_money
  end

  def view_class event
    event.activity_money? || event.money? ? "text-primary" : "text-success"
  end

  def view_icon event
    if event.expense < Settings.default_money
      content_tag(:i, "", class: "fa fa-minus get-money-icon")
    else
      content_tag(:i, "", class: "fa fa-plus pay-money-icon")
    end
  end

  def count_member_done event, club
    members_done = club.users.done_by_ids(event.budgets.map(&:user_id))
    content_tag(members_done.size, :i, class: "fa fa-user-o")
  end

  def get_money_expense event, _club
    event.expense * event.budgets.size
  end

  def category_event
    [[t("money"), Event.event_categories[:money]],
    [t("get_money_member"), Event.event_categories[:get_money_member]],
    [t("donate.donate"), Event.event_categories[:donate]],
    [t("subsidy"), Event.event_categories[:subsidy]]]
  end

  def confirm_donate donate, club
    if donate.accept?
      content_tag(:span, t("donate.confirmed"), class: "btn btn-success")
    elsif club.is_admin? current_user
      link_to t("donate.wait_confirmation"),
        edit_club_event_donate_path(club, donate.event_id, donate, status: :accept),
        remote: :true, class: "btn btn-warning", title: t("confirm")
    else
      content_tag(:span, t("donate.wait_confirmation"), class: "btn btn-warning")
    end
  end

  def check_event_category category_id
    event_category_ids = Event.event_categories.except(:notification, :activity_money).keys
    event_category_ids.include? category_id
  end

  def check_albums event
    event.albums.present?
  end

  def check_action_and_albums action, event
    action == Settings.action_edit && check_albums(event)
  end

  def check_event_have_details event
    Event.event_categories.key(Settings.value_pay_money) == event.event_category ||
      Event.event_categories.key(Settings.value_receive_money) == event.event_category
  end

  def format_date date
    date.strftime(t("date.formats.short")) if date
  end

  def check_date date
    if date.present?
      date
    else
      Date.current
    end
  end

  def count_money_event_details event, style
    total = Settings.default_money
    event.event_details.each do |detail|
      total += detail.money if detail.style == style
    end
    number_to_currency(total, locale: :vi).to_s
  end

  def get_style_row event, style_red, style_default
    if event.expense < Settings.default_money
      style_red
    else
      style_default
    end
  end

  def label_money event
    if event.money?
      t("event_notifications.amount_for")
    elsif event.get_money_member?
      t("amount_member")
    else
      t("amount_for")
    end
  end

  def is_member_of_club? club
    current_user.user_clubs.joined.of_club(club)
  end

  def description_share event
    ActionView::Base.full_sanitizer.sanitize(event.description)
  end
end
