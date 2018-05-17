class Admin::UserOrganizationsController < Admin::AdminController
  before_action :load_organization
  before_action :load_user_organization, only: [:update, :destroy, :create]

  def create
    if params[:user_ids]
      import_member
    elsif @member
      load_user_organization
      unless @member.joined!
        flash.now[:danger] = t "namespace_admin.errors_in_process"
      end
    end
  end

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

  def import_member
    user_organization = []
    params[:user_ids].each do |user_id|
      user_org = @organization.user_organizations.new user_id: user_id, status: :joined, is_admin: false
      user_organization << user_org
    end
    if UserOrganization.import user_organization
      flash[:success] = t "import_success"
    else
      flash[:success] = t "namespace_admin.errors_in_process"
    end
    redirect_to admin_organization_path(@organization)
  end
end
