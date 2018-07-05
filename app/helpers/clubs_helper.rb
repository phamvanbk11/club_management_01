module ClubsHelper
  def get_day_view days
    days.join("-")
  end

  def get_field_club field
    html_safe?(field) if field.present?
  end

  def check_date_club days, day
    days.include? day
  end

  def view_detail_club content_view
    if content_view.blank?
      content_tag(:h5, content_tag(:strong, t("content_empty")), class: "text-center")
    else
      simple_format(content_view)
    end
  end

  def check_view_manager club
    if current_user.user_clubs.manager.find_by(club_id: club.id).present?
      link_to t("view_more"), dashboard_club_path(club.id), class: "btn btn-success"
    else
      link_to t("view_more"), "javascript:void(0)", title: t("club_is_lock"),
        class: "btn btn-default"
    end
  end

  def albums_club album
    album.images.first.url
  end

  def user_role_club
    [[t("members"), Settings.user_club.member],
    [t("manager"), Settings.user_club.manager]]
  end

  def check_role_club user_club
    if user_club.is_manager?
      Settings.user_club.manager
    else
      Settings.user_club.member
    end
  end

  def set_image_in_list_club club
    if club && club.image.thumb.file && club.image.thumb.file.exists?
      image_tag club.image_url(:thumb), class: "centered-and-cropped list-club-image"
    elsif club
      image_tag club.image_url, class: "centered-and-cropped list-club-image"
    end
  end

  def set_image_background_club club
    if club && club.image.thumb.file && club.image.thumb.file.exists?
      image_tag club.image_url(:thumb), class: "img-cover", title: t("image_cover")
    elsif club
      image_tag club.image_url, class: "img-cover", title: t("image_cover")
    end
  end

  def set_logo_club club
    if club && club.logo.thumb.file && club.logo.thumb.file.exists?
      image_tag club.logo_url(:thumb), class: "img-cover", title: t("logo_club")
    elsif club
      image_tag club.logo_url, class: "img-cover", title: t("logo_club")
    end
  end

  def is_in_organization_of_club? club
    club.organization.user_organizations.joined.pluck(:user_id).include?(current_user.id)
  end

  def is_manager_organization? club, user
    club.organization.user_organizations.are_admin.pluck(:user_id).include?(user.id)
  end

  def select_active
    array_option = Settings.filters_active.map{|k, v| [t("page_my_clubs.#{k}"), v]}
        .unshift([t("page_my_clubs.filters_active_temp"), nil])
    filter_left_sidebar 'is_active', array_option, "active_clubs"
  end

  def select_sort
    array_option = Settings.sort_clubs.map{|k, v| [t("#{k}"), v]}
      .unshift([t("sort_clubs"), nil])
    filter_left_sidebar 'sort_clubs', array_option, "sort-other-clubs"
  end

  def select_stype_club
    array_option = @club_types.map{|u|
      ["#{u.name}"+" (#{u.organization_name})", u.id]}
      .unshift([t("style_filter"), nil])
    filter_left_sidebar 'stype_clubs', array_option, "stype-other-clubs"
  end

  def select_stype_organizations
    array_option = @organizations.map{|organization|
      [organization.name, organization.id]}
      .unshift([t("organization_filter"), nil])
    filter_left_sidebar 'stype_organizations', array_option, "stype-organizations-other-clubs"
  end

  def filter_left_sidebar tag, options, className
    select_tag tag,
      options_for_select(options, include_blank: true),
      {class: "select_custom form-control #{className}"}
  end
end
