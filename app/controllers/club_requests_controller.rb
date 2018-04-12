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
    @request = ClubRequest.new
    @organizations = current_user.user_organizations.includes(:organization).joined
    if params[:organization_id]
      @user_organizations = UserOrganization.load_user_organization(
        params[:organization_id]
      ).except_me(current_user.id).includes :user
      @club_types = ClubType.of_organization params[:organization_id]
      html = render_to_string partial: "add_user",
        locals: {user_clubs: @user_organizations}
      respond_to do |format|
        format.json{render json: {data: @club_types, html: html}}
      end
    else
      organization_id = current_user.organizations.first.id
      @user_organizations = UserOrganization.load_user_organization(organization_id)
        .except_me(current_user.id).includes :user
      @club_types = ClubType.of_organization organization_id
    end
  end

  def create
    request = ClubRequest.new request_params
    if request.save
      save_user_club_request request
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
      :plan, :goal, time_activity: []).merge! user_id: current_user.id
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
