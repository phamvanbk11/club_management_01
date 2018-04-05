class Dashboard::OrganizationsController < ApplicationController
  before_action :load_organization, only: :update
  before_action :verify_manager_organization, only: :update

  def update
    set_crop
    if @organization.update_attributes organization_parmas
      flash[:success] = t("update_organization_success")
    else
      flash[:danger] = t "error_update"
    end
    redirect_to organization_path(@organization)
  end

  private
  def load_organization
    @organization = Organization.friendly.find params[:id]
    unless @organization
      flash[:danger] = t("organization_not_found")
      redirect_to dashboard_path
    end
  end

  def organization_parmas
    status = params["organization"]["status"].to_i
    params.require(:organization).permit(:name, :description, :phone,
      :email, :location, :logo).merge! status: status
  end

  def verify_manager_organization
    @admin = @organization.user_organizations.are_admin.find_by user_id: current_user
    unless @admin
      flash[:danger] = t "not_authorities_to_access"
      redirect_to dashboard_path
    end
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
end
