module NotificationsHelper
  def notifications_result
    if current_user.user_organizations.are_admin
      notification_ids = notification_club_manager + notification_member +
        notification_organization_manager
      Activity.includes(:trackable, :owner, :container)
        .activity_ids(notification_ids).oder_by_read
    elsif current_user.user_clubs.manager
      notification_ids = notification_club_manager + notification_member
      Activity.includes(:trackable, :owner, :container)
        .activity_ids(notification_ids).oder_by_read
    else
      Activity.includes(:trackable, :owner, :container)
        .activity_ids(notification_member).oder_by_read
    end
  end

  def option_image notification
    img = set_img notification
    image_tag img, class: "img-responsive centered-and-cropped" if img
  end

  def url_notification notification
    case notification.trackable_type
    when Settings.notification_event
      club_event_path(id: notification.trackable_id, club_id: notification.container)
    when Settings.notification_club
      club_path(id: notification.container)
    when Settings.notification_report
      url_notification_report notification
    when Settings.notification_sponsor
      organization_club_path(organization_id: notification.trackable.club.organization,
        id: notification.trackable.club)
    else
      club_album_path(club_id: notification.container, id: notification.trackable_id)
    end
  end

  def option_class read
    if read.present? && read.include?(current_user.id)
      Settings.notifications.read
    else
      Settings.notifications.un_read
    end
  end

  def size_notification notifications
    un_read = notifications.size
    notifications.each do |notification|
      if notification.user_read.present? && notification.user_read.include?(current_user.id)
        un_read -= Settings.notifications.notification_read
      end
    end
    un_read
  end

  def check_user_club_joined? notification
    if @current_user_clubs.of_club(notification.container_id).present?
      @current_user_clubs.of_club(notification.container_id).joined?
    else
      @current_user_clubs.of_club(notification.trackable_id).joined?
    end
  end

  def check_notification_reject_approve_report notification
    notification.key == Settings.approve_report || notification.key == Settings.reject_report
  end

  def check_notification_create_update_report notification
    notification.key == Settings.create_report || notification.key == Settings.update_report
  end

  def check_notification_create_update_sponsor notification
    notification.key == Settings.create_sponsor || notification.key == Settings.update_sponsor
  end

  def check_notification_accept_reject_sponsor notification
    notification.key == Settings.accept_sponsor || notification.key == Settings.reject_sponsor
  end

  def check_notification_remind_system notification
    notification.report_month_key? || notification.report_quarter_key?
  end

  def set_content_by_trackable notification
    if notification.report_month_trackable_style?
      t("month") + " " + notification.trackable.time.to_s
    elsif notification.report_quarter_trackable_style?
      t("quarter") + " " + notification.trackable.time.to_s
    end
  end

  def set_content_notification_by_key notification
    if notification.report_month_key?
      t "of_manager_not_report_month", time: Date.current.month
    elsif notification.report_quarter_key?
      t "of_manager_not_report_quarter", time: current_quarter
    end
  end

  private
  def notification_club_manager
    Activity.notification_user(current_user.id)
      .of_user_clubs(current_user.user_clubs.manager.pluck(:club_id)).pluck(:id)
  end

  def notification_member
    Activity.notification_user(current_user.id).of_user_clubs(current_user.user_clubs
      .are_member.joined.pluck(:club_id)).type_receive(Activity.type_receives[:club_member]).pluck(:id)
  end

  def notification_organization_manager
    Activity.notification_user(current_user.id)
      .of_user_organizations(current_user.user_organizations.are_admin.pluck(:organization_id))
      .type_receive(Activity.type_receives[:organization_manager]).pluck(:id)
  end

  def url_notification_report notification
    if check_notification_reject_approve_report(notification) ||
      check_notification_remind_system(notification)
      club_path(id: notification.container)
    elsif check_notification_create_update_report notification
      organization_path(id: notification.container)
    end
  end

  def set_img notification
    case notification.trackable_type
    when Club.name
      notification.trackable.logo
    when Event.name
      notification.trackable.image
    when Organization.name
      notification.trackable.logo
    when Image.name
      notification.trackable.url
    else
      if notification.report_month_key? || notification.report_quarter_key?
        notification.container.organization.logo
      elsif notification.owner
        notification.owner.avatar
      end
    end
  end

  def current_quarter
    month = Date.current.month
    (month - Settings.one) / Settings.month_per_quarter + Settings.one
  end
end
