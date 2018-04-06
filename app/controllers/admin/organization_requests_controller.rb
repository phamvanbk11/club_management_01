class Admin::OrganizationRequestsController < Admin::AdminController
  before_action :load_organization_request, except: :index
  before_action :load_unapprove

  def index
  end

  def edit
  end

  def update
    ActiveRecord::Base.transaction do
      service = ApproveOrganizationService.new @organization_request
      service.approve_request
      @organization = service.create_organization @organization_request
      service.create_user_organization @organization.id
      send_mail_respond @organization_request
      flash[:success] = t("approve_success")
      redirect_to admin_organization_requests_path
    end
  rescue
    flash[:danger] = t("cant_approve")
    redirect_to redirect_back fallback_location: admin_path
  end

  def destroy
    if @organization_request.destroy
      flash[:success] = t("deleted_successfull")
    else
      flash[:danger] = t("delete_unsuccessfull")
    end
    render :index
  end

  private
  def load_unapprove
    @organization_requests = OrganizationRequest.pending
    unless @organization_requests
      flash_error @organization_requests
      redirect_back fallback_location: admin_path
    end
  end

  def load_organization_request
    @organization_request = OrganizationRequest.find_by id: params[:id]
    unless @organization_request
      flash[:danger] = t("not_found_request")
      redirect_to root_path
    end
  end

  def send_mail_respond organization
    @user = User.find_by id: organization.user_id
    unless @user
      flash[:danger] = t("can_not_found_user")
      redirect_back fallback_location: admin_path
    end
    AdminMailer.mail_to_user_request(@user, organization).deliver_later
  end
end
