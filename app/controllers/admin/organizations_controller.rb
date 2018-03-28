class Admin::OrganizationsController < Admin::AdminController
  before_action :load_organization, except: [:new, :index, :create]
  before_action :all_user, only: [:new, :create]

  def index
    @q = Organization.search params[:q]
    @organizations = @q.result
      .newest.page(params[:page]).per Settings.per_page_user
  end

  def show
    @q = User.search params[:q]
    @support = Support::OrganizationSupport.new @organization, Settings.one, @q
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new organization_params
    ActiveRecord::Base.transaction do
      if @organization.save!
        add_manager_organization
        flash.now[:success] = t "admin_manage.org.create_success"
      end
    end
  rescue
    flash.now[:danger] = t "admin_manage.org.errors"
  end

  def edit; end

  def update
    if @organization && @organization.update_attributes(organization_params)
      flash.now[:success] = t "admin_manage.org.update_success"
    elsif @organization
      flash.now[:danger] = t "admin_manage.errors"
    end
  end

  def destroy
    if @organization && @organization.destroy
      flash.now[:success] = t "admin_manage.org.destroy_success"
    elsif @organization
      flash.now[:danger] = t "admin_manage.org.errors"
    end
  end

  private
  def organization_params
    params.require(:organization).permit :name, :email, :phone, :logo,
      :location, :description
  end

  def load_organization
    @organization = Organization.find_by slug: params[:id]
    return if @organization
    flash.now[:danger] = t "admin_manage.org.not_find_org"
  end

  def add_manager_organization
    if params[:user_id].is_a? Array
      user_organizations = []
      params[:user_id].each do |id|
        user_organizations << @organization.user_organizations.new(user_id: id,
          status: :joined, is_admin: true)
      end
    end
    UserOrganization.import user_organizations if user_organizations.present?
  end

  def all_user
    @users = User.all
  end
end
