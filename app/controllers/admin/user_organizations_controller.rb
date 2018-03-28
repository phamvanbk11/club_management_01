class Admin::UserOrganizationsController < Admin::AdminController
  before_action :load_organization
  before_action :load_user_organization, only: [:update, :destroy]

  def index
    @q = User.search params[:q]
    @support = Support::OrganizationSupport.new @organization, params[:page], @q
  end

  def update
    if @member && @member.update_attributes(is_admin: status_params_add_admin?)
      flash.now[:success] = t "admin_manage.member.success"
    elsif @member
      flash.now[:danger] = t "admin_manage.member.errors"
    end
  end

  def destroy
    if @member && @member.destroy
      flash.now[:success] = t "admin_manage.member.success_destroy"
    elsif @member
      flash.now[:danger] = t "admin_manage.member.errors"
    end
  end

  private
  def load_organization
    @organization = Organization.find_by slug: params[:organization_id]
    return if @organization
    flash.now[:danger] = t "admin_manage.org.not_find_org"
  end

  def load_user_organization
    @member = UserOrganization.find_by(id: params[:id]) if @organization
    return if @member
    flash.now[:danger] = t "admin_manage.member.not_find_member"
  end

  def status_params_add_admin?
    params[:add_admin] == Settings.string_true
  end
end
