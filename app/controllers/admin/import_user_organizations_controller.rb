class Admin::ImportUserOrganizationsController < Admin::AdminController
  before_action :load_organization, only: :create

  def create
    if params[:file].present?
      check_file_and_import
    else
      flash[:danger] = t("import_file")
    end
    redirect_to :back
  end

  private
  def load_organization
    @organization = Organization.find_by slug: params[:organization_id]
    return if @organization
    flash.now[:danger] = t "admin_manage.org.not_find_org"
    redirect_to admin_organizations_path
  end

  def check_file_and_import
    if User.open_spreadsheet(params[:file]) == Settings.error_import
      flash[:danger] = t("errors_file_format")
    else
      if User.import_file(params[:file], @organization) == Settings.error_data
        flash[:danger] = t("errors_file_user")
      else
        flash[:success] = t("import_success")
      end
    end
  end
end
