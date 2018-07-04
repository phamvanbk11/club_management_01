class ClubRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_club_request, only: [:update, :edit]
  protect_from_forgery except: :index

  def index
    @requests = current_user.club_requests
    if @requests
      respond_to do |format|
        format.js
      end
    end
  end

  def new
    @club_request_support = Support::ClubRequestSupport.new current_user, params
    return unless request.xhr?
    html_users = render_to_string partial: "add_user",
      locals: {user_clubs: @club_request_support.user_organizations}
    html_frequencies = render_to_string partial: "radio_frequency",
      locals: {frequencies: @club_request_support.frequencies,
      choose: @club_request_support.frequencies.first&.id}
    respond_to do |format|
      format.json{render json: {club_types: @club_request_support.club_types,
        html_users: html_users, html_frequencies: html_frequencies}}
    end
  end

  def create
    request = ClubRequest.new request_params
    if request.save
      save_user_club_request request
      create_acivity request, Settings.request_club,
        request.organization, current_user, Activity.type_receives[:organization_manager]
      flash[:success] = t "success_create"
      redirect_to root_path
    else
      flash_error request
      redirect_back fallback_location: new_user_club_request_path(user_id: current_user.id)
    end
  end

  def edit
    @club_request_support = Support::ClubRequestSupport.new current_user, params
    authorize! :edit, @club_request
  end

  def update
    authorize! :update, @club_request
    if @club_request.update request_params
      save_user_club_request @club_request
      create_acivity @club_request, Settings.update_request_club,
        @club_request.organization, current_user, Activity.type_receives[:organization_manager]
      flash[:success] = t "success_update"
      redirect_to edit_user_club_request_path(user_id: current_user.id)
    else
      flash_error @club_request
      redirect_back fallback_location: edit_user_club_request_path(user_id: current_user.id)
    end
  end

  private

  def set_club_request
    @club_request = ClubRequest.find_by id: params[:id]
    return if @club_request
    flash[:error] = t "club_request_not_found"
    redirect_to root_path
  end

  def request_params
    params.require(:club_request).permit(:name, :logo, :action,
      :organization_id, :member, :goal, :local, :activities_connect,
      :content, :rules, :rule_finance, :time_join, :punishment, :club_type_id,
      :plan, :goal, time_activity: []).merge! user_id: current_user.id,
      frequency_id: params[:frequency_id]
  end

  def save_user_club_request request
    organizations = Organization.find_by id: request_params[:organization_id]
    msg = ""
    user_add = [];
    user_remove = [];
    if params[:user_club_request] && params[:user_club_request][:user_ids]
      (params[:user_club_request][:user_ids] - request.user_club_requests.pluck(:user_id)).each do |user_id|
        user_add << {club_request_id: request.id, user_id: user_id}
      end
      user_remove = request.user_club_requests.pluck(:user_id) - params[:user_club_request][:user_ids]
      request.user_club_requests.by_user(user_remove).destroy_all
      UserClubRequest.import user_add
    end
  end
end
