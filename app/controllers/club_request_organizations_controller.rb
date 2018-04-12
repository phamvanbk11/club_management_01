class ClubRequestOrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization
  authorize_resource class: false, through: :organization
  before_action :load_request, only: [:update, :edit]

  def index
    @requests = @organization.club_requests.pending.order_date_desc if @organization
  end

  def edit; end

  def update
    if @request && @request.update_attributes(status: params[:status].to_i)
      flash.now[:success] = t("success_process")
    elsif @request
      flash.now[:danger] = t("error_process")
    end
  end

  private
  def load_organization
    @organization = Organization.find_by slug: params[:organization_id]
    return if @organization
    flash.now[:danger] = t("organization_not_found")
  end

  def load_request
    if @organization
      @request = ClubRequest.find_by id: params[:id]
      return if @request
      flash.now[:danger] = t "not_found_request"
    end
  end
end
