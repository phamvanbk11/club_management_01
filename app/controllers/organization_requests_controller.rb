class OrganizationRequestsController < ApplicationController
  before_action :authenticate_user!

  def index
    @requests = current_user.organization_requests
    respond_to do |format|
      format.js
    end
  end

  def new
    @request = OrganizationRequest.new
  end

  def create
    request = OrganizationRequest.new request_params
    if request.save
      flash[:success] = t("success_create")
      redirect_to root_path
    else
      flash_error request
      redirect_back fallback_location: new_user_organization_request_path(user_id: current_user.id)
    end
  end

  def destroy
    request = OrganizationRequest.find_by id: params[:id]
    if request
      @request_id = request.id
      if request.destroy
        respond_to do |format|
          format.js
        end
      end
    end
  end

  private
  def request_params
    params.require(:organization_request).permit(:name, :logo,
      :description, :email, :phone, :location,
      :organization_id).merge! user_id: current_user.id
  end
end
