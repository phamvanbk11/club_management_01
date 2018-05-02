class EventNotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_club
  authorize_resource class: false, through: :club
  before_action :load_event_notification, only: [:update, :destroy]
  before_action :replace_string_in_money
  before_action :set_gon_varible, only: :new

  def show
    if params[:category].to_i == Event.event_categories[:activity_money]
      if is_in_club? @club, current_user
        @events_activity = @club.events.newest
          .activity_money.page(params[:page]).per Settings.per_page
      else
        @events_activity = @club.events.event_public.newest
          .activity_money.page(params[:page]).per Settings.per_page
      end
    else
      @events_notification = @club.events.newest
        .notification.page(params[:page]).per Settings.per_page
    end
  end

  def new
    @event = @club.events.new
  end

  def create
    event = @club.events.new params_option
    event.amount = @club.money if event.activity_money?
    service_money = UpdateClubMoneyService.new event, @club, params_option
    ActiveRecord::Base.transaction do
      create_acivity event, Settings.create, event.club, current_user,
        Activity.type_receives[:club_member]
      service_money.save_event_and_plus_money_club_in_activity_event
      save_images_in_album event
      flash[:success] = t ".create_success"
      page_redirect event
    end
  rescue
    if event && event.errors.any?
      flash_error(event)
    else
      flash[:danger] = t ".error_in_process"
    end
    redirect_back fallback_location: new_club_event_notification_path(club_id: @club.slug)
  end

  def update
    service_money = UpdateClubMoneyService.new @event, @club, params_option
    ActiveRecord::Base.transaction do
      create_acivity @event, Settings.update, @event.club, current_user,
        Activity.type_receives[:club_member]
      service_money.update_first_money_of_event
      service_money.update_event_and_money_club_in_activity_event
      flash[:success] = t ".update_success"
      page_redirect @event
    end
  rescue
    if @event && @event.errors.any?
      flash_error @event
    else
      flash[:danger] = t ".error_process"
    end
    redirect_back fallback_location: edit_club_event_notification_path(club_id: @club.slug,
      event: @event)
  end

  def destroy
    if @event && @event.destroy
      flash.now[:success] = t ".success_process"
    else
      flash.now[:danger] = t ".error_in_process"
    end
    all_event_by_category
  end

  private
  def load_club
    @club = Club.find_by slug: params[:club_id]
    return if @club
    flash[:danger] = t ".error_find_club"
    redirect_back fallback_location: root_path
  end

  def event_notification_params
    event_category = params[:event][:event_category].to_i
    params.require(:event).permit(:club_id, :name, :date_start, :status,
      :date_end, :location, :description, :user_id, :is_public, :is_auto_create)
      .merge! event_category: event_category
  end

  def event_params_with_album
    if event_notification_params[:event_category] == Event.event_categories[:activity_money]
      event_notification_params.merge! albums_attributes: [name: params[:event][:name],
        club_id: @club.id]
    else
      event_notification_params
    end
  end

  def load_event_notification
    @event = Event.find_by id: params[:id]
    return if @event
    flash[:danger] = t ".error_find_event"
    redirect_back fallback_location: root_path
  end

  def params_option
    event_category = params[:event][:event_category].to_i
    case event_category
    when Event.event_categories[:notification]
      event_params_with_album
    else
      event_params_with_check_attributes.merge! albums_attributes: [name: params[:event][:name],
        club_id: @club.id]
    end
  end

  def event_params_with_check_attributes
    event_category = params[:event][:event_category].to_i
    count_money = CountMoney.new params[:event][:event_details_attributes]
    if is_present_params_attributes?
      params.require(:event).permit(:club_id, :name, :date_start, :status,
        :date_end, :location, :description, :image, :user_id, :is_public,
        event_details_attributes: [:description, :money, :id, :_destroy, :style, :spent_at])
        .merge! event_category: event_category, expense: count_money.money
    else
      params.require(:event).permit(:club_id, :name, :date_start, :status,
        :date_end, :location, :description, :image, :user_id, :is_public, :is_auto_create)
        .merge! event_category: event_category
    end
  end

  def replace_string_in_money
    if params[:event] && params[:event][:expense]
      params[:event][:expense].gsub!(",", "")
    end
    if params[:event] && params[:event][:event_details_attributes]
      params[:event][:event_details_attributes].each do |key, value|
        value[:money].gsub!(",", "") if value[:money]
        value[:style] = value[:style].to_i if value[:style]
      end
    end
  end

  def set_gon_varible
    gon.notification = Event.event_categories[:notification]
    gon.activity_money = Event.event_categories[:activity_money]
  end

  def all_event_by_category
    if params[:category].to_i == Event.event_categories[:activity_money]
      load_events_activity
    else
      load_events_notification
    end
  end

  def page_redirect event
    if event.notification?
      redirect_to @club
    else
      redirect_to club_event_path(club_id: @club.slug, id: event.id)
    end
  end

  def load_events_activity
    @events_activity = @club.events.newest
      .activity_money.page(params[:page]).per Settings.per_page
    if @events_activity.blank? && params[:page].to_i > Settings.one
      @events_activity = @club.events.newest
        .activity_money.page(params[:page].to_i - Settings.one).per Settings.per_page
    end
    @events = @club.events.newest.event_category_activity_money(Event.array_style_event_money_except_activity,
      Event.event_categories[:activity_money])
      .includes(:budgets, :event_details).page(Settings.page_default).per Settings.per_page
  end

  def load_events_notification
    @events_notification = @club.events.newest
      .notification.page(params[:page]).per Settings.per_page
    if @events_notification.blank? && params[:page].to_i > Settings.one
      @events_notification = @club.events.newest
        .notification.page(params[:page].to_i - Settings.one).per Settings.per_page
    end
  end

  def is_present_params_attributes?
    params[:event].present? && params[:event][:event_details_attributes].present? &&
    params[:event][:event_details_attributes]["0"].present? &&
    params[:event][:event_details_attributes]["0"][:description].present?
  end

  def save_images_in_album event
    if event.activity_money? && params[:images]
      params[:images][:urls].each do |img|
        event.albums.first.images.create! url: img
      end
    end
  end
end
