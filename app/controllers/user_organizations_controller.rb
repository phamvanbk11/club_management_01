class UserOrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_user, only: [:index, :show]
  before_action :load_organization, only: [:show, :destroy, :create]
  before_action :load_user_organiation, only: :destroy

  def index
    @user_organizations = @user.user_organizations.joined.page(params[:page]).per(Settings.organization_per_page)
    @organizations = Organization.page(params[:page]).per(Settings.organization_per_page)
  end

  def show; end

  def create
    user_organization = @organization.user_organizations.new user_id: current_user.id
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
  def load_user
    @user = User.find_by id: params[:user_id]
    return if @user
    flash[:danger] = t "flash_not_found.user"
    redirect_back fallback_location: root_path
  end

  def load_organization
    @organization = Organization.find_by id: params[:id]
    return if @organization
    flash[:danger] = t("organization_not_found")
    redirect_back fallback_location: organizations_path
  end

  def load_user_organiation
    @user_organization = @organization.user_organizations.find_by user_id: current_user.id
    unless @user_organization
      flash[:danger] = t("flash_not_found.user_org")
      redirect_back fallback_location: organizations_path
    end
    if @user_organization && @user_organization.is_admin
      if @organization.user_organizations.are_admin.size == Settings.user_club.manager
        flash[:danger] = t("user_organization_not_remove")
        redirect_to organization_path @organization
      end
    end
  end
end
