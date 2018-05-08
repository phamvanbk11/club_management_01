class ClubRequestsController < ApplicationController
  before_action :authenticate_user!
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

  private

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
    if params[:user_club_request] && params[:user_club_request][:user_ids]
      params[:user_club_request][:user_ids].each do |user_id|
        unless user_id && request.user_club_requests.create(user_id: user_id)
          user = organizations.users.find_by id: user_id
          msg += "#{user.full_name}, " if user
        end
      end
      flash[:warning] = t "add_member_error", msg: msg if msg.present?
    end
  end
end
