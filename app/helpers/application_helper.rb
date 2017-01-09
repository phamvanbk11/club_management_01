module ApplicationHelper
  def devise_error_messages!
    resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
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

  def admin_verify
    unless current_user.role == :admin
      flash[:danger] = t("require_admin")
      redirect_to root_url
    end
  end

  def manager_club club
    user_club = club.user_clubs.find_by is_manager: true
    if user_club
      user_club.user
      return
    end
    nil
  end
end
