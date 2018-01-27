module EventNotificationsHelper
  def category_event_notification
    [[t("notification"), Event.event_categories[:notification]]]
  end

  def url_form_new_and_edit action, club
    if action == Settings.action_edit
      club_event_notification_path(club)
    else
      club_event_notifications_path(club)
    end
  end
end
