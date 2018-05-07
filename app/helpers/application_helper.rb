module ApplicationHelper
  def devise_error_messages!
    resource.errors.full_messages.map{|msg| content_tag(:li, msg)}.join
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def index_continue object, index, per_page
    (object.to_i - 1) * per_page.to_i + index + 1
  end

  def flash_error object
    flash[:danger] = object.errors.full_messages
  end

  def flash_error_ajax object
    flash.now[:danger] = object.errors.full_messages
  end

  def manager_of_club user
    @user_clubs = user.user_clubs.manager
  end

  def image_holder album
    album.images.first.url
  end

  def status_user_club user, club
    user_club = user.user_clubs.find_by club_id: club.id
    user_club.present? ? user_club.joined? : nil
  end

  def count_request variable
    variable.club.user_clubs.unactive.count
  end

  def sort_suggest array_club
    h = Hash.new(0)
    array_club.each{|v| h.store(v, h[v] + 1)}
    h = Hash[h.sort_by{|_, v| -v}]
    h.map(&:flatten)
  end

  def club_suggest_user_tag
    clubs = []
    sort_suggest(current_user.tags_clubs).each do |club, _s|
      clubs << club unless current_user.user_clubs.of_club(club)
    end
    clubs
  end

  def active_class link_path
    current_page?(link_path) ? "active" : ""
  end

  def format_date date
    date.strftime(Settings.date_format)
  end

  def correctmanager organization
    current_user.user_organizations.load_user_organization(organization.id).are_admin
  end

  def url_approve_user_organization object
    link_to user_request_organization_path(id: object[:id], status: object[:status]),
      method: :put, remote: true, data: {confirm: object[:confirm]}, title: object[:name],
      class: "btn btn-sm btn-#{object[:button]} aprove-user pull-right" do
      simple_format(object[:icon])
    end
  end

  def url_approve_club_organization object
    link_to object[:name], club_request_organization_path(id: object[:id],
      status: object[:status], organization_id: object[:organization_id]),
      method: :put, class: "btn btn-sm btn-#{object[:button]} pull-right",
      data: {confirm: object[:confirm]}, remote: true
  end

  def type_report data
    case data.style.to_i
    when StatisticReport.styles[:monthly]
      t StatisticReport.months.key(data.time.to_i).to_s
    when StatisticReport.styles[:quarterly]
      t StatisticReport.quarters.key(data.time.to_i).to_s
    else
      t "errors_style_not_exist"
    end
  end

  def get_class_checkbox data_boolean
    if data_boolean
      Settings.class_check_box_checked
    end
  end

  def option_select_custom options, selected
    options_for_select(options.map{|k, v| [t("." + k.to_s), v]}, selected)
  end
end
