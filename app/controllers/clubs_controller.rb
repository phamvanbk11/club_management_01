class ClubsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club, only: %i(show edit update)
  authorize_resource
  before_action :verify_club, only: :show
  before_action :load_user_organizations, only: :show
  before_action :load_organization, only: %i(new update create)
  before_action :load_event_tab_activity, only: :show

  def index
    organizations_joined = Organization.by_user_organizations(
      current_user.user_organizations.joined
    )
    @club_joined = Club.of_organizations(
      organizations_joined
    ).of_user_clubs(current_user.user_clubs.joined)
    clubs = Club.of_organizations(organizations_joined).without_clubs(
      @club_joined
    )
    @q = clubs.search(params[:q])
    @clubs = @q.result.includes(:organization).order_active.newest
      .page(params[:page]).per Settings.club_per_page
    @user_organizations = current_user.user_organizations.joined
    @organizations = Organization.by_user_organizations(
      current_user.user_organizations.joined
    )
    @club_types = ClubType.includes(:organization)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @statistic_report = current_user.statistic_reports.build club_id: @club.id
    @album = Album.new
    list_events = @club.events
    @q = list_events.search(params[:q])
    @events = @q.result.newest.event_category_activity_money(events_ids, Event.event_categories[:activity_money])
      .includes(:budgets, :event_details).page(params[:page]).per Settings.per_page
    @time_line_events = @events.by_current_year.group_by_quarter
    @message = Message.new
    @user_club = UserClub.new
    @infor_club = Support::ClubSupport.new(@club, params[:page], nil)
    @add_user_club = @user_organizations
      .user_not_joined(@club.user_clubs.map(&:user_id))
    @members_not_manager = @infor_club.members_not_manager.page(params[:page])
      .per Settings.page_member_not_manager
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    if can? :manager, @organization
      @club = Club.new
      @user_organizations = UserOrganization.includes(:user)
        .load_user_organization(params[:organization_id])
        .except_me current_user.id
      @club_types = ClubType.of_organization params[:organization_id]
    else
      flash[:danger] = t "not_authorities_to_access"
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    ActiveRecord::Base.transaction do
      club = @organization.clubs.build create_club_params
      club.is_active = true
      if club.save
        save_user_club club
        UserClub.create_admin_club current_user.id, club.id
        flash[:success] = t("success_create_club")
      else
        flash_error club
      end
      redirect_to request.referer || root_url
    end
  rescue
    flash[:danger] = t "error_in_process"
    redirect_to request.referer || root_url
  end

  def edit; end

  def update
    set_crop
    if @club.update_attributes params_merge_frequency
      create_acivity @club, Settings.update, @club, current_user,
        Activity.type_receives[:club_member]
      flash[:success] = t "club_manager.club.success_update"
    else
      flash_error @club
    end
    redirect_to organization_club_path(@club) unless request.xhr?
  end

  protected
  def verify_club
    if !@club.is_active? && !@club.is_admin?(current_user)
      flash[:danger] = t "club_not_active"
      redirect_to root_path
    end
  end

  def load_club
    @club = Club.find_by slug: params[:id]
    return if @club
    flash[:danger] = t("flash_not_found.club")
    redirect_to root_path
  end

  def load_user_organizations
    @user_organizations = @club.organization
      .user_organizations.joined.includes :user
    return if @user_organizations
    flash[:danger] = t "not_found"
    redirect_to clubs_url
  end

  def load_organization
    @organization = Organization.find_by(id: params[:organization_id])
    @organization ||= Organization.find_by(slug: params[:organization_id])
    unless @organization
      flash[:danger] = t "not_found_organization"
      redirect_to request.referer
    end
  end

  def params_merge_frequency
    if params[:frequency_id].present?
      club_params.merge! frequency_id: params[:frequency_id]
    else
      club_params
    end
  end

  def club_params
    params.require(:club).permit(:logo, :image, :name, :content, :goal, :logo, :rules,
      :rule_finance, :time_join, :image, :tag_list, :plan, :punishment, :member,
      :local, :activities_connect, time_activity: []) if params[:club].present?
  end

  def crop_params_logo
    params.require(:club).permit :logo_crop_x, :logo_crop_y, :logo_crop_w, :logo_crop_h
  end

  def crop_params_image
    params.require(:club).permit :image_crop_x, :image_crop_y, :image_crop_w, :image_crop_h
  end

  def set_crop
    if crop_params_logo[:logo_crop_x]
      @club.set_attr_crop_logo crop_params_logo[:logo_crop_x], crop_params_logo[:logo_crop_y],
        crop_params_logo[:logo_crop_h], crop_params_logo[:logo_crop_w]
    elsif crop_params_image[:image_crop_x]
      @club.set_attr_crop_image crop_params_image[:image_crop_x], crop_params_image[:image_crop_y],
        crop_params_image[:image_crop_h], crop_params_image[:image_crop_w]
    end
  end

  def create_club_params
    params.require(:club).permit(:name, :logo, :action, :club_type_id,
      :organization_id, :member, :goal, :local, :activities_connect,
      :content, :rules, :rule_finance, :time_join, :punishment,
      :plan, :goal, time_activity: [])
  end

  def save_user_club club
    msg = ""
    if params[:user_club] && params[:user_club][:user_ids]
      params[:user_club][:user_ids].each do |user_id|
        unless user_id && club.user_clubs.create(user_id: user_id, status: 1)
          user = @organization.users.find_by id: user_id
          msg += "#{user.full_name}, " if user
        end
      end
    end
    flash[:warning] = t "add_member_error", msg: msg if msg.present?
  end

  def events_ids
    [Event.event_categories[:money], Event.event_categories[:get_money_member],
      Event.event_categories[:donate], Event.event_categories[:subsidy]]
  end

  def load_event_tab_activity
    if is_in_club? @club, current_user
      @events_activity = @club.events.includes(:user).newest.in_categories(Event.money_event_keys)
        .page(params[:page]).per Settings.per_page
    else
      @events_activity = @club.events.includes(:user).event_public.newest
        .in_categories(Event.money_event_keys)
        .page(params[:page]).per Settings.per_page
    end
  end
end
