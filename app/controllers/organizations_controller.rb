class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization, only: [:show, :edit, :update]
  authorize_resource

  def index
    @q = Organization.search(params[:q])
    @organizations = @q.result.newest.page(params[:page])
      .per Settings.club_per_page
  end

  def show
    @user_organization = current_user.user_organizations
      .find_by organization_id: @organization.id
    @q = @organization.clubs.search(params[:q])
    @clubs = @q.result.page(params[:page]).per Settings.club_per_page
    @add_user_club = User.without_user_ids(@organization.user_organizations.map(&:user_id))
    @organization_event = @organization.events.includes(:club).status_public(true)
      .newest.page(params[:page]).per Settings.club_per_page
  end

  def edit; end

  def update
    set_crop
    if @organization.update_attributes organization_params
      flash[:success] = t("update_organization_success")
    else
      flash[:danger] = t "error_update"
    end
    redirect_to organization_path(@organization)
  end

  private
  def load_organization
    @organization = Organization.friendly.find_by slug: params[:id]
    return if @organization
    flash[:danger] = t("organization_not_found")
    redirect_to root_url
  end

  def set_crop
    if crop_params_logo[:bgr_crop_x]
      @organization.set_attr_crop_logo_org crop_params_logo[:bgr_crop_x], crop_params_logo[:bgr_crop_y],
        crop_params_logo[:bgr_crop_h], crop_params_logo[:bgr_crop_w]
    end
  end

  def crop_params_logo
    params.require(:organization).permit :bgr_crop_x, :bgr_crop_y, :bgr_crop_w, :bgr_crop_h
  end

  def organization_params
    status = params[:organization][:status].to_i
    params.require(:organization).permit(:name, :description, :phone,
      :email, :location, :logo).merge! status: status
  end
end
