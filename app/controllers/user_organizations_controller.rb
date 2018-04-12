class UserOrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_organization, only: [:show, :destroy]
  before_action :load_user_organiation, only: :destroy

  def index
    @organizations = Organization.page(params[:page]).per(Settings.organization_per_page)
  end

  def show
    respond_to do |format|
      format.js
    end
  end

  def create
    user_organization = UserOrganization.new organization_params
    if user_organization.save
      flash[:success] = t("success_create_user_organization")
    else
      flash[:danger] = t("cant_create_user_organization")
    end
    redirect_back fallback_location: organizations_path
  end

  def destroy
    if @user_organization.destroy
      flash[:success] = t("cancel_success")
    else
      flash[:danger] = t("cancel_error")
    end
    redirect_to organization_path(@organization)
  end

  private
  def load_organization
    @organization = Organization.find_by id: params[:id]
    return if @organization
    flash[:danger] = t("organization_not_found")
    redirect_back fallback_location: organizations_path
  end

  def organization_params
    params.require(:user_organization).permit(:organization_id).merge! user_id: current_user.id
  end

  def load_user_organiation
    @user_organization = @organization.user_organizations
      .find_by user_id: current_user.id
    if @user_organization.is_admin
      if @organization.user_organizations.are_admin.size == Settings.user_club.manager
        flash[:danger] = t("user_organization_not_remove")
        redirect_to organization_path @organization
      end
    end
  end
end
